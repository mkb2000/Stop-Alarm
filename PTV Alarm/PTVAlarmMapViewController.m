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

@interface PTVAlarmMapViewController ()
@property (strong,nonatomic) NSArray * activeAlarms;
@property (strong,nonatomic) CLLocation * lastLocation;
@property (strong,nonatomic) NSMutableDictionary * annotationDic;
@property (strong,nonatomic) PTVAlarmAppDelegate * appdelegate;
@property (nonatomic) BOOL activeView;
@property (strong,nonatomic) Alarms * lastArrived;
@property (strong,nonatomic) PTVAlarmMapAnnotation * lastArrivedAnno;
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
    NSLog(@"map view load!!");
    
    self.appdelegate=[[UIApplication sharedApplication] delegate];
    self.lastLocation=self.appdelegate.ptvalarmmanager.lastLocation;
    
    self.mapView.delegate=self;
    self.mapView.showsUserLocation=YES;
    [self.mapView setUserTrackingMode:MKUserTrackingModeFollow animated:YES];
    
    self.activeView=false;
    [self activeAlarmsDidChange];
    self.activeView=true;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(activeAlarmsDidChange) name:NSManagedObjectContextObjectsDidChangeNotification object:nil];
}


- (void)viewWillAppear:(BOOL)animated{
    self.activeView=true;
    NSLog(@"veiw will load!!!");
}

-(void)viewWillDisappear:(BOOL)animated{
    self.activeView=false;
    NSLog(@"veiw will disappear!!!");
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

@end
