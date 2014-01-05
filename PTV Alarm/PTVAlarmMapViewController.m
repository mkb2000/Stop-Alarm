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

#import "TBCoordinateQuadTree.h"
#import "TBClusterAnnotationView.h"
#import "TBClusterAnnotation.h"

@interface PTVAlarmMapViewController ()
@property (weak, nonatomic) IBOutlet UISegmentedControl *segementedControl;

@property (strong,nonatomic) NSArray * activeAlarms;
@property (strong,nonatomic) CLLocation * lastLocation;
@property (strong,nonatomic) NSMutableDictionary * annotationDic;
@property (strong,nonatomic) PTVAlarmAppDelegate * appdelegate;
@property (nonatomic) BOOL activeView;
@property (strong,nonatomic) Alarms * lastArrived;
@property (strong,nonatomic) PTVAlarmMapAnnotation * lastArrivedAnno;

@property (strong, nonatomic) TBCoordinateQuadTree *coordinateQuadTree;
@end

@implementation PTVAlarmMapViewController

- (NSMutableDictionary *)annotationDic{
    if (!_annotationDic) {
        _annotationDic=[NSMutableDictionary dictionary];
    }
    return _annotationDic;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    if (IS_DEBUG) {
        NSLog(@"map view load!!");
    }
    
    self.appdelegate=[[UIApplication sharedApplication] delegate];
    self.lastLocation=self.appdelegate.ptvalarmmanager.lastLocation;
    
    
    //    self.coordinateQuadTree.mapView = self.mapView;
    //    [self.coordinateQuadTree buildTree];
    
    [self.segementedControl setTitle:@"Bus" forSegmentAtIndex:2];//:@"Bus" atIndex:2 animated:NO];
    [self.segementedControl setTitle:@"Tram" forSegmentAtIndex:3];//insertSegmentWithTitle:@"Tram" atIndex:3 animated:NO];
    [self.segementedControl setTitle:@"Vline" forSegmentAtIndex:4];//insertSegmentWithTitle:@"Vline" atIndex:4 animated:NO];
    
    self.mapView.delegate=self;
    [self.mapView setVisibleMapRect:MKMapRectMake(241657535.9625825, 163847807.9538832, 1310719.946412265, 1863679.845351934)];
    self.mapView.showsUserLocation=YES;
    [self.mapView setUserTrackingMode:MKUserTrackingModeFollow animated:YES];
    
    self.activeView=false;
    [self activeAlarmsDidChange];
    self.activeView=true;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(activeAlarmsDidChange) name:NSManagedObjectContextObjectsDidChangeNotification object:nil];
    
    
}


- (void)viewWillAppear:(BOOL)animated{
    self.activeView=true;
    if (IS_DEBUG) {
        NSLog(@"veiw will load!!!");
    }
    
}

-(void)viewWillDisappear:(BOOL)animated{
    self.activeView=false;
    if (IS_DEBUG) {
        NSLog(@"veiw will disappear!!!");
    }
}

// when alarm state changes, remove/add station annotation from map view.
- (void) activeAlarmsDidChange{
    NSMutableSet *old=[NSMutableSet setWithArray:self.activeAlarms];
    NSMutableSet *new=[NSMutableSet setWithArray:[[self.appdelegate activeAlarms] copy] ];
    NSMutableSet *difference;
    
    if ([old count]>[new count]) {
        //remove active alarm action
        difference=[NSMutableSet setWithSet:old];
        [difference minusSet:new];
        for (Alarms *dif in difference) {
            [self.mapView removeAnnotation:[self.annotationDic objectForKey:dif.toWhich.address]];
            [self.annotationDic removeObjectForKey:dif.toWhich.address];
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
            [self.mapView addAnnotation:mapPin];
            [self.annotationDic setObject:mapPin forKey:mapPin.address];
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
    if (self.lastLocation&&!self.activeView) {
        [self setMapViewVisiblePortion:self.lastLocation];
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
            MKCoordinateRegion r;
            MKCoordinateSpan span;
            span.latitudeDelta = 1;
            span.longitudeDelta = 1;
            r.span = span;
            CLLocationCoordinate2D c;
            c.longitude=currentLoci.coordinate.longitude;
            c.latitude=currentLoci.coordinate.latitude;
            r.center = c;
            [self.mapView setRegion:r animated:YES];
        }
    }
}

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
    NSSet *after = [NSSet setWithArray:annotations];
    
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

- (void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated
{
    if (self.segementedControl.selectedSegmentIndex!=0) {
        [[NSOperationQueue new] addOperationWithBlock:^{
            double scale = self.mapView.bounds.size.width / self.mapView.visibleMapRect.size.width;
            NSArray *annotations = [self.coordinateQuadTree clusteredAnnotationsWithinMapRect:mapView.visibleMapRect withZoomScale:scale];
            
            [self updateMapViewAnnotationsWithAnnotations:annotations];
        }];
    }
}

//- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation
//{
//    static NSString *const TBAnnotatioViewReuseID = @"TBAnnotatioViewReuseID";
//
//    TBClusterAnnotationView *annotationView = (TBClusterAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:TBAnnotatioViewReuseID];
//
//    if (!annotationView) {
//        annotationView = [[TBClusterAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:TBAnnotatioViewReuseID];
//    }
//
//    annotationView.canShowCallout = YES;
//    annotationView.count = [(TBClusterAnnotation *)annotation count];
//
//    return annotationView;
//}

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation
{
    static NSString *const TBAnnotatioViewReuseID = @"TBAnnotatioViewReuseID";
    
    MKPinAnnotationView *annotationView = (MKPinAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:TBAnnotatioViewReuseID];
    
    if (!annotationView) {
        annotationView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:TBAnnotatioViewReuseID];
    }
    
    annotationView.canShowCallout = YES;
    //    annotationView.count = [(TBClusterAnnotation *)annotation count];
    
    return annotationView;
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
        switch (self.segementedControl.selectedSegmentIndex) {
            case 0:
                if (self.coordinateQuadTree) {
                    self.coordinateQuadTree=NULL;
                }
                break;
            case 1:
                self.coordinateQuadTree = [[TBCoordinateQuadTree alloc] init];
                [self.coordinateQuadTree buildTreeWithFile:@"train.csv"];
                break;
            case 2:
                self.coordinateQuadTree = [[TBCoordinateQuadTree alloc] init];
                [self.coordinateQuadTree buildTreeWithFile:@"bus.csv"];
                break;
            case 3:
                self.coordinateQuadTree = [[TBCoordinateQuadTree alloc] init];
                [self.coordinateQuadTree buildTreeWithFile:@"tram.csv"];
                break;
            case 4:
                self.coordinateQuadTree = [[TBCoordinateQuadTree alloc] init];
                [self.coordinateQuadTree buildTreeWithFile:@"vline.csv"];
                break;
                
            default:
                break;
        }
        [self mapView:self.mapView regionDidChangeAnimated:NO];
    }
}



@end
