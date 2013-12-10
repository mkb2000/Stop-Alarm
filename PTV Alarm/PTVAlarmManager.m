//
//  PTVAlarmManager.m
//  PTV Alarm
//
//  Created by Kangbo Mo on 1/12/2013.
//  Copyright (c) 2013 Kangbo Mo. All rights reserved.
//
//  Manage alive alarms. Alert when destination is arrived.
//  The change of active alarms is broadcast using notification, which is also adopt in other uiview.
//  There are three approach to assay the arrival of a destination:
//  1. use geoFencing. Set a region and use [CLLocationManager startMonitoringForRegion:] to monitor this region. When user enter this region, a short period of running from background is garranteed. Use this feature to give an alert.
//  2. use [CLLocationManger startUpdatingLocation] to continuously update user location, calculate the distance between current location and destinations. Give an alert when distance is less than a threshold. The app has to be grant the right to run background. The update of location is continous, thus cost much power. However, as test on train, device often became unable to deliver user location timely, and cause the alert fail.
//  3. startMonitoringSignificantLocationChanges/geofencing + startUpdatingLocation. Use the first two low power method to monitor a region. If user enter this region, start high accuracy monitor.
//  The accuracy of this app is largely depended on timely dilivery of user location by the device.


#import "PTVAlarmManager.h"
#import <MapKit/MapKit.h>
#import "PTVAlarmAppDelegate.h"

@interface PTVAlarmManager()
@property (nonatomic,strong) NSMutableSet * activeAlarms;
@property (nonatomic,strong) CLLocationManager * cllmng;
@property (nonatomic,strong)UILocalNotification* alarm;
@property (nonatomic) BOOL alertShowed;
@property CLAuthorizationStatus authState;
@property (nonatomic) BOOL highAccuracyMode;
@end

@implementation PTVAlarmManager


- (CLLocationManager *)cllmng{
    if (!_cllmng) {
        self.cllmng=[[CLLocationManager alloc]init];
        self.cllmng.delegate=self;
        //        self.cllmng.desiredAccuracy=kCLLocationAccuracyNearestTenMeters;
        //        self.cllmng.distanceFilter=20;
    }
    return  _cllmng;
}

- (PTVAlarmManager *)init{
    self=[super init];
    self.backgroundMode=false;
    self.authState=kCLAuthorizationStatusNotDetermined;
    
    UIApplication* app = [UIApplication sharedApplication];
    NSArray*    oldNotifications = [app scheduledLocalNotifications];
    // Clear out the old notification before scheduling a new one.
    if ([oldNotifications count] > 0)
        [app cancelAllLocalNotifications];
    // Create a new notification.
    _alarm = [[UILocalNotification alloc] init];
    if (_alarm)
    {
        _alarm.timeZone = [NSTimeZone defaultTimeZone];
        _alarm.repeatInterval = 0;
        _alarm.soundName = @"Alien.caf";
        _alarm.alertBody = @"Time to wake up! Your destination is around the corner!";
    }
    return self;
}

//start point of this class.
/*
 1. Reach a destination when running in background: 1) if there is no active alarm, shut down location service. 2) if there are active alarms, start low accuracy mode.
 2. In foreground: 1) none active alarms, stop location service. (this does not clear up monitored region, so clear it when destroy location service 2) clear regions, add regions, start low accuracy mode.
 */
-(void)activeAlarmsChange:(NSArray *)activealarms{
    if (self.authState==kCLAuthorizationStatusDenied&&[activealarms count]>[self.activeAlarms count]) {
        [PTVAlarmDefine alertOfLocationServiceUnavailable:self];
        ((Alarms *)[activealarms lastObject]).state=0;
        [self destroyLocationService];
    }
    else if(self.authState==kCLAuthorizationStatusDenied){}
    else
    {
        for (CLRegion * r in [self.cllmng monitoredRegions]) {
            //clear monitored regions.
            [self.cllmng stopMonitoringForRegion:r];
        }
        if ([activealarms count]==0&&self.backgroundMode) {
            //when app runs in background and reach destination.
            [self destroyLocationService];
            self.activeAlarms=nil;
        }
        else if([activealarms count]==0)
        {
            [self stopLocationService];
            self.activeAlarms=nil;
        }
        else{
            self.alertShowed=false;
            self.activeAlarms=[NSMutableSet setWithArray:activealarms];
            //            for (Alarms * alarm in self.activeAlarms) {
            //                    [self addMonitoredRegion:alarm];
            //            }
            //            [self.cllmng startUpdatingLocation];
            [self startLowAccuracyMode];
        }
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(enterBackground) name:UIApplicationDidEnterBackgroundNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(enterForeground) name:UIApplicationDidBecomeActiveNotification object:Nil];
    }
}
-(void) enterForeground{
    self.backgroundMode=false;
    
    NSLog(@"enter foreground");
}

-(void) enterBackground{
    self.backgroundMode=true;
    //    [self stopLocationService];
}

-(void) addMonitoredRegion:(Alarms *) alarm{
    CLLocationCoordinate2D centre;
    centre.latitude=alarm.toWhich.latitude.doubleValue;
    centre.longitude=alarm.toWhich.longitude.doubleValue;
    
    CLLocationDegrees radius = 2000;//ALARM_DISTANCE;
    radius=radius>self.cllmng.maximumRegionMonitoringDistance?self.cllmng.maximumRegionMonitoringDistance:radius;
    
    // Create the geographic region to be monitored.
    CLRegion *geoRegion = [[CLRegion alloc] initCircularRegionWithCenter:centre radius:radius identifier:alarm.toWhich.address];
    
    [self.cllmng startMonitoringForRegion:geoRegion];
    //    [self.cllmng requestStateForRegion:geoRegion];
    
}

- (void)locationManager:(CLLocationManager *)manager didEnterRegion:(CLRegion *)region{
    if (self.backgroundMode) {
        [self startHighAccuracyMode];
    }
    NSLog(@"enter region!");
    //    for (Alarms * a in self.activeAlarms) {
    //        if ([a.toWhich.address isEqualToString:region.identifier]) {
    //            [self closeEnoughToTarget:a];
    //        }
    //
    //        [self updateInfo:@"Enter region!"];
    //    }
}

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status{
    [self updateInfo:[NSString stringWithFormat:@"change authorization called  %d",status]];
    status=[CLLocationManager authorizationStatus];
    self.authState=status;
    if (status==kCLAuthorizationStatusDenied) {
        [PTVAlarmDefine alertOfLocationServiceUnavailable:self];
        for (Alarms * a in self.activeAlarms) {
            a.state=OFFSTATE;
        }
        self.activeAlarms=nil;
        [self destroyLocationService];
    }
}


- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations{
//    if (self.backgroundMode) {
//        [self startHighAccuracyMode];
//    }
    CLLocation* location = [locations lastObject];
    self.lastLocation=location;
    NSLog(@"%@ %@",self.highAccuracyMode?@"high mode":@"low mode",location);
    NSDate* eventDate = location.timestamp;
    NSTimeInterval howRecent = [eventDate timeIntervalSinceNow];
    if (abs(howRecent) < 15.0) {
        //New active alarms are passed in this class, this method is called once to determine if user location is in the region. If true, alart; otherwise start monitor the region.
        for (Alarms * alarm in self.activeAlarms) {
            CLLocation *targetLocation=[[CLLocation alloc] initWithLatitude:alarm.toWhich.latitude.doubleValue longitude:alarm.toWhich.longitude.doubleValue];
            CLLocationDistance distance=[targetLocation distanceFromLocation:location];
            int alarm_distance=[PTVAlarmDefine alertDistanceForType:alarm.toWhich.type.intValue];
            if (distance<alarm_distance) {
                [self closeEnoughToTarget:alarm];
            }
        }
        //        [self stopLocationService];
        NSLog(@"%@",location);
    }
}

-(void) closeEnoughToTarget:(Alarms *) destination{
    [self stopLocationService];
    //alert when arrival
    self.lastArrived=destination;
    if (UIApplication.sharedApplication.applicationState == UIApplicationStateActive&&!self.alertShowed) {
        self.alertShowed=true;
        UIAlertView * alertview=[[UIAlertView alloc] initWithTitle:[@"Arrival" stringByAppendingString:destination.toWhich.name] message:@"Your destination is around the corner!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alertview show];
    }
    else{
        // alert from bacground.
        NSLog(@"alert from background");
        UIApplication* app = [UIApplication sharedApplication];
        [app presentLocalNotificationNow:self.alarm];
    }
    destination.state=0;
    [self updateInfo:[NSString stringWithFormat:@"You are close to target!!!"]];
}


- (void) updateInfo:(NSString *) msg{
    NSLog(@"%@",msg);
    //    [self.delegate updateTextField:msg];
}


- (void) destroyLocationService{
    if (_cllmng) {
        for (CLRegion * r in self.cllmng.monitoredRegions) {
            [self.cllmng stopMonitoringForRegion:r];
        }
        [self.cllmng stopUpdatingLocation];
        [self.cllmng stopMonitoringSignificantLocationChanges];
        self.cllmng=nil;
    }
    NSLog(@"destory cllmng");
}

- (void) stopLocationService{
    [self.cllmng stopUpdatingLocation];
    [self.cllmng stopMonitoringSignificantLocationChanges];
    NSLog(@"stop location service");
}

- (void) startLowAccuracyMode{
        self.highAccuracyMode=false;
        //    [self.cllmng stopUpdatingLocation];
        //    [self.cllmng startMonitoringSignificantLocationChanges];
        self.cllmng.desiredAccuracy=kCLLocationAccuracyHundredMeters;
        self.cllmng.distanceFilter=200;
        [self.cllmng startUpdatingLocation];
        NSLog(@"start low mode");
}

-(void) startHighAccuracyMode{
    if (!self.highAccuracyMode) {
        self.highAccuracyMode=true;
        //    [self.cllmng stopMonitoringSignificantLocationChanges];
        self.cllmng.desiredAccuracy=kCLLocationAccuracyNearestTenMeters;
        self.cllmng.distanceFilter=50;
        [self.cllmng startUpdatingLocation];
        NSLog(@"start high mode");
    }
}

@end
