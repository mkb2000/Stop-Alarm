//
//  PTVAlarmSelectOnMapViewController.m
//  PTV Alarm
//
//  Created by Kangbo Mo on 15/11/2013.
//  Copyright (c) 2013 Kangbo Mo. All rights reserved.
//

#import "PTVAlarmMapViewController.h"
#import "PTVAlarmAppDelegate.h"
#import "PTVAlarmMapAnnotation.h"
#import "PTVAlarmDetailViewController.h"

#import "TBCoordinateQuadTree.h"
#import "TBClusterAnnotationView.h"
#import "TBClusterAnnotation.h"

@interface PTVAlarmMapViewController ()
@property (weak, nonatomic) IBOutlet UISegmentedControl *segementedControl;
@property (strong,nonatomic) NSArray * activeAlarms;
@property (strong,nonatomic) CLLocation * lastUserLocation;
@property (strong,nonatomic) NSMutableDictionary * activeAlarmAnnotationDict;
@property (strong,nonatomic) PTVAlarmAppDelegate * appdelegate;
@property (nonatomic) BOOL isActiveView;
@property (strong,nonatomic) Alarms * lastArrived;
@property (strong,nonatomic) PTVAlarmMapAnnotation * lastArrivedAnno;//this annotation on mapview is red if there was a pin at its position. The updateMapViewAnnotationsWithAnnotations: treats the two classes equally, so retains the previous one.
@property (strong,nonatomic) NSArray * stationAnnotations;
@property (strong, nonatomic) TBCoordinateQuadTree *coordinateQuadTree;
@property (strong,nonatomic) id<MKAnnotation> selectedAnnotation;
@property (strong,nonatomic) NSMutableArray * permanentAnnotations; //Annotations won't change during scaling. active alarm, lastArrived, selected annotation
@property (strong,nonatomic) NSOperationQueue * opQueue;

@end

@implementation PTVAlarmMapViewController

- (NSOperationQueue *) opQueue{
    if (!_opQueue) {
        _opQueue=[[NSOperationQueue alloc] init];
        _opQueue.maxConcurrentOperationCount=1;
    }
    return _opQueue;
}

- (NSMutableArray *) permanentAnnotations{
    _permanentAnnotations=[NSMutableArray array];
    for (NSString * key in [self.activeAlarmAnnotationDict allKeys]) {
        [_permanentAnnotations addObject:[self.activeAlarmAnnotationDict objectForKey:key] ];
    }
    if (self.lastArrivedAnno) {
        [_permanentAnnotations addObject:self.lastArrivedAnno];
    }
    if (self.selectedAnnotation) {
        [_permanentAnnotations addObject:self.selectedAnnotation];
    }
    return _permanentAnnotations;
}

- (NSMutableDictionary *)activeAlarmAnnotationDict{
    if (!_activeAlarmAnnotationDict) {
        _activeAlarmAnnotationDict=[NSMutableDictionary dictionary];
    }
    return _activeAlarmAnnotationDict;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    if (IS_DEBUG) {
        NSLog(@"map view load!!");
    }
    
    self.appdelegate=[[UIApplication sharedApplication] delegate];
    self.lastUserLocation=self.appdelegate.ptvalarmmanager.lastLocation;
    
    self.coordinateQuadTree = [[TBCoordinateQuadTree alloc] init];
    [self.opQueue addOperationWithBlock:^{
        [self.coordinateQuadTree prepareTreeWithFile:@"bus.csv"];//this takes a while to execute, so do it here.
    }];
    
    [self.segementedControl setTitle:@"None" forSegmentAtIndex:0];
    [self.segementedControl setTitle:@"Train" forSegmentAtIndex:1];
    [self.segementedControl setTitle:@"Bus" forSegmentAtIndex:2];//:@"Bus" atIndex:2 animated:NO];
    [self.segementedControl setTitle:@"Tram" forSegmentAtIndex:3];//insertSegmentWithTitle:@"Tram" atIndex:3 animated:NO];
    [self.segementedControl setTitle:@"Vline" forSegmentAtIndex:4];//insertSegmentWithTitle:@"Vline" atIndex:4 animated:NO];
    
    self.mapView.delegate=self;
    [self.mapView setVisibleMapRect:MKMapRectMake(241657535.9625825, 163847807.9538832, 1310719.946412265, 1863679.845351934)];// victoria
    self.mapView.showsUserLocation=YES;
    //    [self.mapView setUserTrackingMode:MKUserTrackingModeFollow animated:YES];
    
    self.isActiveView=false;
    [self activeAlarmsDidChange];
    self.isActiveView=true;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(activeAlarmsDidChange) name:NSManagedObjectContextObjectsDidChangeNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appEnterBackground) name:UIApplicationDidBecomeActiveNotification object:nil];
}

- (void)viewWillAppear:(BOOL)animated{
    self.isActiveView=true;
    if (IS_DEBUG) {
        NSLog(@"veiw will load!!!");
    }
}

-(void)viewWillDisappear:(BOOL)animated{
    self.isActiveView=false;
    if (IS_DEBUG) {
        NSLog(@"veiw will disappear!!!");
    }
}

- (void) didReceiveMemoryWarning{
    if (IS_DEBUG) {
        NSLog(@"memory alarm in mapviewcontroller");
    }
    [self.coordinateQuadTree clearCache];
    [super didReceiveMemoryWarning];
}


// invoked by notification when app wakes from background model.
- (void) appEnterBackground{
    //remove the last arrived destination.
    if (self.lastArrivedAnno) {
        [self.mapView removeAnnotation:self.lastArrivedAnno];
        self.lastArrivedAnno=nil;
    }
}

// invoked by notification when alarm state changes, remove/add station annotation from map view.
- (void) activeAlarmsDidChange{
    NSMutableSet *old=[NSMutableSet setWithArray:self.activeAlarms];
    NSMutableSet *new=[NSMutableSet setWithArray:[[self.appdelegate activeAlarms] copy] ];
    NSMutableSet *difference;
    
    if ([old count]>[new count]) {
        //remove active alarm action
        difference=[NSMutableSet setWithSet:old];
        [difference minusSet:new];
        for (Alarms *dif in difference) {
            PTVAlarmMapAnnotation *alarmAnnotation=[self.activeAlarmAnnotationDict objectForKey:dif.toWhich.address];
            [self.mapView removeAnnotation:[self.activeAlarmAnnotationDict objectForKey:dif.toWhich.address]];
            [self.activeAlarmAnnotationDict removeObjectForKey:dif.toWhich.address];
            
            //change the annotation color to normal one.
            TBClusterAnnotation *stationAnnotation=[[TBClusterAnnotation alloc] init];
            stationAnnotation.title=alarmAnnotation.title;
            stationAnnotation.subtitle=alarmAnnotation.subtitle;
            stationAnnotation.coordinate=alarmAnnotation.coordinate;
            NSMutableSet *currAnno=[NSMutableSet setWithArray:self.stationAnnotations];
            if ([currAnno containsObject:stationAnnotation]) {
                [self.mapView addAnnotation:stationAnnotation];
            }
        }
    }
    else{
        //add new alarm action
        difference=[NSMutableSet setWithSet:new];
        [difference minusSet:old];
        for (Alarms *a in difference) {
            PTVAlarmMapAnnotation * mapPin=[[PTVAlarmMapAnnotation alloc] init];
            mapPin.theCoordinate=CLLocationCoordinate2DMake(a.toWhich.latitude.doubleValue, a.toWhich.longitude.doubleValue);
            mapPin.name=a.toWhich.name;
            mapPin.address=a.toWhich.address;
            for (id<MKAnnotation> anno in self.mapView.annotations) {
                if ([anno isEqual:mapPin]) {
                    [self.mapView removeAnnotation:anno];
                }
            }
            [self.activeAlarmAnnotationDict setObject:mapPin forKey:mapPin.address];
            [self.mapView addAnnotation:mapPin];
            
        }
    }
    
    //remove or add the last arrived destination.
    if (self.lastArrivedAnno) {
        [self.mapView removeAnnotation:self.lastArrivedAnno];
        self.lastArrivedAnno=nil;
    }
    if (self.appdelegate.ptvalarmmanager.lastArrived) {
        self.lastArrived=self.appdelegate.ptvalarmmanager.lastArrived;
        PTVAlarmMapAnnotation *lastArrivedAnnotation=[[PTVAlarmMapAnnotation alloc]init];
        lastArrivedAnnotation.theCoordinate=CLLocationCoordinate2DMake(self.lastArrived.toWhich.latitude.doubleValue, self.lastArrived.toWhich.longitude.doubleValue);
        lastArrivedAnnotation.name=self.lastArrived.toWhich.name;
        lastArrivedAnnotation.address=self.lastArrived.toWhich.address;
        [self.mapView addAnnotation:lastArrivedAnnotation];
        self.appdelegate.ptvalarmmanager.lastArrived=nil;
        self.lastArrivedAnno=lastArrivedAnnotation;
    }
    
    self.activeAlarms=[[self.appdelegate activeAlarms] copy];
    //reset the visiable rect of map view when userlocation is available and turn on/off an alarm.
    if (self.lastUserLocation&&!self.isActiveView) {
        [self setMapViewVisiblePortion:self.lastUserLocation];
    }
}


//Scale the map view to make the destination and user location visible in the map view.
- (void)setMapViewVisiblePortion:(CLLocation *) currentLoci{
    if ([self.activeAlarms count]&&currentLoci) {
        //find the nearest active destination, calculate the span to show both of desti and current location on map.
        Alarms * showThisAlarm;
        CLLocationDistance previous=-1;
        CLLocationDistance distance=0;
        
        for (Alarms * a in self.activeAlarms) {
            //            NSLog(@"%@",a.toWhich.name);
            CLLocation * toLoci=[[CLLocation alloc] initWithLatitude:a.toWhich.latitude.doubleValue longitude:a.toWhich.longitude.doubleValue];
            if (previous==-1) {
                previous=[currentLoci distanceFromLocation:toLoci];
                distance=previous;
                showThisAlarm=a;
            }
            else if ([currentLoci distanceFromLocation:toLoci]<previous) {
                showThisAlarm=a;
                distance=[currentLoci distanceFromLocation:toLoci];
                previous=distance;
            }
        }
        //TODO. use some formula to calculate the center and radius. This seems work ok...
        double cenlati=(currentLoci.coordinate.latitude+showThisAlarm.toWhich.latitude.doubleValue)/2;
        double cenlongi=(currentLoci.coordinate.longitude+showThisAlarm.toWhich.longitude.doubleValue)/2;
        double lenth=distance*1.5>400?distance*1.5:600;
        
        if (lenth<50000) {
            MKCoordinateRegion region=MKCoordinateRegionMakeWithDistance(CLLocationCoordinate2DMake(cenlati, cenlongi), lenth,lenth);
            [self.mapView setRegion:region animated:YES];
        }
        else{
            //if the current location is too too far away.
            [self.mapView setVisibleMapRect:MKMapRectMake(241657535.9625825, 163847807.9538832, 1310719.946412265, 1863679.845351934)];// victoria
        }
    }
}

/*
 // make a circle overlay. Not used
 - (MKOverlayView *)mapView:(MKMapView *)mapView viewForOverlay:(id <MKOverlay>)overlay
 {
 if ([overlay isKindOfClass:[MKCircle class]])
 {
 MKCircleView*    aView = [[MKCircleView alloc] initWithCircle:(MKCircle *)overlay ];
 aView.fillColor = [[UIColor cyanColor] colorWithAlphaComponent:0.2];
 aView.strokeColor = [[UIColor blueColor] colorWithAlphaComponent:0.7];
 aView.lineWidth = 3;
 return aView;
 }
 return nil;
 }
 */

#pragma mark - station annotations
- (void)addBounceAnnimationToView:(UIView *)view
{
    CAKeyframeAnimation *bounceAnimation = [CAKeyframeAnimation animationWithKeyPath:@"transform.scale"];
    
    bounceAnimation.values = @[@(0.05), @(1.1), @(0.9), @(1)];
    
    bounceAnimation.duration = 0.6;
    NSMutableArray *timingFunctions = [[NSMutableArray alloc] initWithCapacity:bounceAnimation.values.count];
    for (NSUInteger i = 0; i < bounceAnimation.values.count; i++) {
        [timingFunctions addObject:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
    }
    [bounceAnimation setTimingFunctions:timingFunctions.copy];
    bounceAnimation.removedOnCompletion = NO;
    
    [view.layer addAnimation:bounceAnimation forKey:@"bounce"];
}

- (void)updateMapViewAnnotationsWithAnnotations:(NSArray *)annotations
{
    NSMutableSet *before = [NSMutableSet setWithArray:self.mapView.annotations];
    [before removeObject:[self.mapView userLocation]];
    
    
    NSMutableSet *after = [NSMutableSet setWithArray:annotations];
    [after addObjectsFromArray:self.permanentAnnotations];
    //    for (NSString * key in [self.activeAlarmAnnotationDict allKeys]) {
    //        [after addObject:[self.activeAlarmAnnotationDict objectForKey:key] ];
    //    }
    //    if (self.lastArrivedAnno) {
    //        [after addObject:self.lastArrivedAnno];
    //    }
    //
    NSMutableSet *toKeep = [NSMutableSet setWithSet:before];
    [toKeep intersectSet:after];
    
    NSMutableSet *toAdd = [NSMutableSet setWithSet:after];
    [toAdd minusSet:toKeep];
    
    NSMutableSet *toRemove = [NSMutableSet setWithSet:before];
    [toRemove minusSet:after];
    
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        [self.mapView addAnnotations:[toAdd allObjects]];
        [self.mapView removeAnnotations:[toRemove allObjects]];
    }];
}

#pragma mark - MKMapViewDelegate

- (void) mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view{
    //do not remove the annoation if the selected annoation is a single station.
    if ([view.annotation isKindOfClass:[TBClusterAnnotation class]]&&((TBClusterAnnotation *)view.annotation).count==1) {
        self.selectedAnnotation=view.annotation;
    }
    if ([view.annotation isKindOfClass:[PTVAlarmMapAnnotation class]]) {
        self.selectedAnnotation=view.annotation;
    }
}

- (void) mapView:(MKMapView *)mapView didDeselectAnnotationView:(MKAnnotationView *)view{
    self.selectedAnnotation=nil;
}

- (void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated
{
    [[NSOperationQueue new] addOperationWithBlock:^{
        double scale = self.mapView.bounds.size.width / self.mapView.visibleMapRect.size.width;
        NSArray *annotations = [self.coordinateQuadTree clusteredAnnotationsWithinMapRect:mapView.visibleMapRect withZoomScale:scale];
        self.stationAnnotations=annotations;
        [self updateMapViewAnnotationsWithAnnotations:annotations];
    }];
}


- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation
{
    if ([annotation isKindOfClass:[MKUserLocation class]]){
        return nil;
    }
    static NSString *const TBAnnotatioViewReuseID = @"TBAnnotatioViewReuseID";
    static NSString *const AlaramAnnotationViewReuseID=@"AlaramAnnotationReuseID";
    
    if ([annotation isKindOfClass:[PTVAlarmMapAnnotation class]]) {
        MKPinAnnotationView *annotationView= (MKPinAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:AlaramAnnotationViewReuseID];
        if (!annotationView) {
            annotationView=[[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:AlaramAnnotationViewReuseID];
            annotationView.rightCalloutAccessoryView = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
        }
        [annotationView setPinColor:MKPinAnnotationColorPurple];
        annotationView.canShowCallout=YES;
        return annotationView;
    }
    else{
        MKPinAnnotationView *annotationView = (MKPinAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:TBAnnotatioViewReuseID];
        
        if (!annotationView) {
            annotationView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:TBAnnotatioViewReuseID];
        }
        if (((TBClusterAnnotation *)annotation).count==1) {
            annotationView.rightCalloutAccessoryView = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
        }
        else{
            annotationView.rightCalloutAccessoryView=nil;
        }
        annotationView.canShowCallout = YES;
        return annotationView;
    }
}

- (void)mapView:(MKMapView *)mapView didAddAnnotationViews:(NSArray *)views
{
    for (UIView *view in views) {
        [self addBounceAnnimationToView:view];
    }
}


#pragma mark - segmented control

- (IBAction)segmentValueChange:(id)sender {
    if (IS_DEBUG) {
        NSLog(@"selected at %ld",(long)self.segementedControl.selectedSegmentIndex);
    }
    if ([sender isKindOfClass:[UISegmentedControl class]]) {
        [self.opQueue addOperationWithBlock:^{
            [self doSegmentValueChange:(int)self.segementedControl.selectedSegmentIndex];
        }];
    }
}

- (void) doSegmentValueChange:(int) index{
    //segment index and its related file.
    switch (index) {
        case 0:
            [self.coordinateQuadTree buildTreeWithFile:@""];
            break;
        case 1:
            [self.coordinateQuadTree buildTreeWithFile:@"train.csv"];
            break;
        case 2:
            [self.coordinateQuadTree buildTreeWithFile:@"bus.csv"];
            break;
        case 3:
            [self.coordinateQuadTree buildTreeWithFile:@"tram.csv"];
            break;
        case 4:
            [self.coordinateQuadTree buildTreeWithFile:@"vline.csv"];
            break;
        default:
            break;
    }
    [self mapView:self.mapView regionDidChangeAnimated:NO];
}

#pragma mark - segue to station detail page
- (void) mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control{
    [self performSegueWithIdentifier:@"mapAnnotationSegue" sender:view];
}

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if ([segue.identifier isEqual:@"mapAnnotationSegue"]) {
        MKAnnotationView * view=sender;
        id<MKAnnotation> annotation=view.annotation;
        NSString * name=annotation.title;
        NSString * address=annotation.subtitle;
        CLLocationCoordinate2D coordinate=annotation.coordinate;
        NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Stations"];
        request.predicate = [NSPredicate predicateWithFormat:@"name=%@ AND address=%@",name,address,coordinate.latitude,coordinate.longitude];
        NSArray *stations = [self.appdelegate.managedObjectContext executeFetchRequest:request error:NULL];
        if ([segue.destinationViewController respondsToSelector:@selector(setStation:)]) {
            [segue.destinationViewController performSelector:@selector(setStation:) withObject:stations[0]];
        }
    }
}

@end
