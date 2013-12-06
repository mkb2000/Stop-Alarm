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
@property (strong,nonatomic) CLLocationManager * cllmng;
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

    
    //init CLLocationManager
    self.cllmng=[[CLLocationManager alloc]init];
    self.cllmng.delegate=self;
    self.cllmng.desiredAccuracy=kCLLocationAccuracyNearestTenMeters;
    self.cllmng.distanceFilter=30;
    [self.cllmng startUpdatingLocation];
    
    [self putDestinationsOnMap];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(putDestinationsOnMap) name:NSManagedObjectContextObjectsDidChangeNotification object:nil];
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(enterBackground) name:UIApplicationDidEnterBackgroundNotification object:nil];
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(enterForeground) name:UIApplicationDidBecomeActiveNotification object:nil];
}

- (void)enterBackground{
    
}

- (void)enterForeground{

}

//triggered when change of alarm
- (void)viewWillAppear:(BOOL)animated{
    if (self.firstShow&&self.lastLocation) {
        self.firstShow=false;
        [self setMapViewVisiblePortion:self.lastLocation];
    }
        NSLog(@"veiw will load!!!");
}
//- (void)viewWillDisappear:(BOOL)animated{
//    NSLog(@"veiw unload!!!");
//    
//}

- (void) putDestinationsOnMap{
    self.firstShow=TRUE;
    [self.mapView removeAnnotations:self.mapView.annotations];
    [self.mapView removeOverlays:self.mapView.overlays];
    
    PTVAlarmAppDelegate * appdelegate=[[UIApplication sharedApplication] delegate];
    self.activeAlarms=[[appdelegate activeAlarms] copy];
    if ([self.activeAlarms count]) {
        for (Alarms * a in self.activeAlarms) {
            PTVAlarmMapAnnotation * mapPin=[[PTVAlarmMapAnnotation alloc] init];
            mapPin.theCoordinate=CLLocationCoordinate2DMake(a.toWhich.latitude.doubleValue, a.toWhich.longitude.doubleValue);
            mapPin.name=a.toWhich.name;
            mapPin.address=a.toWhich.address;
            [self.mapView addAnnotation:mapPin];
            
            //for test
            CLLocationCoordinate2D centre;
            centre.latitude=a.toWhich.latitude.doubleValue;
            centre.longitude=a.toWhich.longitude.doubleValue;
            MKCircle * region=[MKCircle circleWithCenterCoordinate:centre radius:ALARM_DISTANCE];
            [self.mapView addOverlay:region];
        }
    }
    else{
        [self.cllmng stopUpdatingLocation];
    }
}

- (void)setMapViewVisiblePortion:(CLLocation *) currentLoci{
    MKCoordinateRegion r;
    MKCoordinateSpan span;
    span.latitudeDelta = 1;
    span.longitudeDelta = 1;
    r.span = span;
    CLLocationCoordinate2D c;
    c.longitude=currentLoci.coordinate.longitude;
    c.latitude=currentLoci.coordinate.latitude;
    r.center = c;
    if ([self.activeAlarms count]&&currentLoci) {
        //find the nearest active destination, calculate the span to show both of desti and current location on map.
        Alarms * showThisAlarm;
        CLLocationDistance previous=-1;
        CLLocationDistance distance=0;
        
        for (Alarms * a in self.activeAlarms) {
            NSLog(@"%@",a.toWhich.name);
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
        //TODO. use some formula to calculate the center and radius. This seems works ok...
        double cenlati=(currentLoci.coordinate.latitude+showThisAlarm.toWhich.latitude.doubleValue)/2;
        double cenlongi=(currentLoci.coordinate.longitude+showThisAlarm.toWhich.longitude.doubleValue)/2;
        double lenth=distance*1.5>400?distance*1.5:600;
        
        if (lenth<50000) {

            MKCoordinateRegion region=MKCoordinateRegionMakeWithDistance(CLLocationCoordinate2DMake(cenlati, cenlongi), lenth,lenth);
            [self.mapView setRegion:region animated:YES];
        }
        else{
            //if the current location is too too far away.
            
            [self.mapView setRegion:r animated:YES];
        }
    }
    else{
        //if no active alarm.
        [self.mapView setRegion:r animated:YES];
    }

}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations{
    CLLocation * currentLoci=[locations lastObject];
    self.lastLocation=currentLoci;
    if (self.firstShow&&self.lastLocation) {
        self.firstShow=false;
        [self setMapViewVisiblePortion:self.lastLocation];
    }
    NSLog(@"loci changed!");
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
