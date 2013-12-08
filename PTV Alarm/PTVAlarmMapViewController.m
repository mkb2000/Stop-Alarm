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
@property BOOL firstShow;
@property (strong,nonatomic) CLLocation * lastLocation;
@end

@implementation PTVAlarmMapViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    NSLog(@"view load!!");
    
    self.firstShow=TRUE;
    self.mapView.delegate=self;
    self.mapView.showsUserLocation=YES;
    [self.mapView setUserTrackingMode:MKUserTrackingModeFollow animated:YES];
    
    [self activeAlarmsDidChange];
    [self putDestinationsOnMap];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(activeAlarmsDidChange) name:NSManagedObjectContextObjectsDidChangeNotification object:nil];
}

//triggered when change of alarm
- (void)viewWillAppear:(BOOL)animated{
    if (self.firstShow) {
        [self putDestinationsOnMap];
        self.firstShow=false;
        if (self.lastLocation) {
            [self setMapViewVisiblePortion:self.lastLocation];
        }
    }
    NSLog(@"veiw will load!!! with firstshow? %d, %@",self.firstShow,self.lastLocation);
    //        NSLog(@"veiw will load!!!");
}

- (void) activeAlarmsDidChange{
    self.firstShow=TRUE;
    [self.mapView removeAnnotations:self.mapView.annotations];
    [self.mapView removeOverlays:self.mapView.overlays];
    
    PTVAlarmAppDelegate * appdelegate=[[UIApplication sharedApplication] delegate];
    self.lastLocation=appdelegate.ptvalarmmanager.lastLocation;
    self.activeAlarms=[[appdelegate activeAlarms] copy];
}

- (void) putDestinationsOnMap{

    for (Alarms * a in self.activeAlarms) {
        //pin
        PTVAlarmMapAnnotation * mapPin=[[PTVAlarmMapAnnotation alloc] init];
        mapPin.theCoordinate=CLLocationCoordinate2DMake(a.toWhich.latitude.doubleValue, a.toWhich.longitude.doubleValue);
        mapPin.name=a.toWhich.name;
        mapPin.address=a.toWhich.address;
        [self.mapView addAnnotation:mapPin];
        
        //alert region overlay
        CLLocationCoordinate2D centre;
        centre.latitude=a.toWhich.latitude.doubleValue;
        centre.longitude=a.toWhich.longitude.doubleValue;
        MKCircle * region=[MKCircle circleWithCenterCoordinate:centre radius:ALARM_DISTANCE];
        [self.mapView addOverlay:region];
    }
}

//Make the destination and user location visible in the map view.
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
//    else{
//        //if no active alarm.
//        [self.mapView setRegion:r animated:YES];
//    }
    
}

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
