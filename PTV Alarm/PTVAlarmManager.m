//
//  PTVAlarmManager.m
//  PTV Alarm
//
//  Created by Kangbo Mo on 1/12/2013.
//  Copyright (c) 2013 Kangbo Mo. All rights reserved.
//
//  Manage alive alarms. Alert when destination is arrived.

//TODO: 1.support ios6 2.when signal is unavailable.

#import "PTVAlarmManager.h"
#import <MapKit/MapKit.h>

@interface PTVAlarmManager()
@property (nonatomic,strong) NSMutableSet * activeAlarms;
@property (nonatomic,strong) CLLocationManager * cllmng;
@property (nonatomic,strong) NSMutableDictionary * delayDict;
@property (nonatomic) BOOL isHighAccuracy;
@property (nonatomic,strong)UILocalNotification* alarm;
@end

@implementation PTVAlarmManager

- (CLLocationManager *)cllmng{
    if (!_cllmng) {
        self.cllmng=[[CLLocationManager alloc]init];
        self.cllmng.delegate=self;
        self.cllmng.desiredAccuracy=kCLLocationAccuracyNearestTenMeters;
        self.cllmng.distanceFilter=20;
    }
    return  _cllmng;
}

- (NSMutableDictionary *)delayDict{
    if (!_delayDict) {
        _delayDict=[[NSMutableDictionary alloc]init];
    }
    return _delayDict;
}

- (PTVAlarmManager *)init{
    self=[super init];
    self.isHighAccuracy=false;
    self.backgroundMode=false;
    
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
        _alarm.soundName = UILocalNotificationDefaultSoundName;
        _alarm.alertBody = @"Time to wake up!";
    }
    return self;
}

//start point of this class.
/*
 1. Reach a destination when running in background: 1) if there is no active alarm, shut down location service. 2) if there are active alarms, start low accuracy mode.
 2. In foreground: 1) none active alarms, stop location service. (this does not clear up monitored region, so clear it when destroy location service 2) clear regions, add regions, start low accuracy mode.
 */
-(void)activeAlarmsChange:(NSArray *)activealarms{
    if ([activealarms count]==0&&self.backgroundMode) {
        //when app runs in background and reach destination.
        [self destroyLocationService];
    }
    else if([activealarms count]==0)
    {
        [self stopLocationService];
        self.activeAlarms=[NSMutableSet setWithArray:activealarms];
    }
    else{
        NSMutableSet * newalarms=[NSMutableSet setWithArray:activealarms];
        [newalarms minusSet:self.activeAlarms];
        
        for (CLRegion * r in [self.cllmng monitoredRegions]) {
            //clear monitored regions.
            [self.cllmng stopMonitoringForRegion:r];
//            int rInNewAa=0;
//            for (Alarms * a in activealarms) {
//                if ([r.identifier isEqualToString:a.toWhich.address]) {
//                    rInNewAa=1;
//                }
//            }
//            if (!rInNewAa) {
//                [self.cllmng stopMonitoringForRegion:r];
//            }
        }
        
        int i=0;
        for (Alarms * al in activealarms) {
            i++;
            [self addMonitoredRegion:al];
        }
        NSLog(@"this many alarms added:::::: %d",i);
        self.activeAlarms=[NSMutableSet setWithArray:activealarms];
        [self startLowAccuracy];
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(enterBackground) name:UIApplicationDidEnterBackgroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(enterForeground) name:UIApplicationDidBecomeActiveNotification object:Nil];
}
-(void) enterForeground{
    //TODO maybe, for each region check if in region
    NSLog(@"enter foreground");
    if (self.isHighAccuracy) {
        [self startHighAccuracy];
    }
    else{
        [self startLowAccuracy];
    }
}

-(void) enterBackground{
    self.backgroundMode=true;
    if ([self.activeAlarms count]==0&&_cllmng) {
        [self destroyLocationService];
    }
    else if(!self.isHighAccuracy&&_cllmng){
        [self startLowAccuracy];
    }
    [self updateInfo:[NSString stringWithFormat:@"High accuracy model: %d",self.isHighAccuracy]];
}

-(void) addMonitoredRegion:(Alarms *) alarm{
    [self.delayDict setObject:[NSNumber numberWithInt:0] forKey:alarm.toWhich.address];
    
    CLLocationCoordinate2D centre;
    centre.latitude=alarm.toWhich.latitude.doubleValue;
    centre.longitude=alarm.toWhich.longitude.doubleValue;
    
    CLLocationDegrees radius = 1000;
    radius=radius>self.cllmng.maximumRegionMonitoringDistance?self.cllmng.maximumRegionMonitoringDistance:radius;
    
    // Create the geographic region to be monitored.
    CLRegion *geoRegion = [[CLRegion alloc] initCircularRegionWithCenter:centre radius:radius identifier:alarm.toWhich.address];
    
    [self.cllmng startMonitoringForRegion:geoRegion];
    [self.cllmng requestStateForRegion:geoRegion];

    
}

- (void)locationManager:(CLLocationManager *)manager didDetermineState:(CLRegionState)state forRegion:(CLRegion *)region{
    NSLog(@"locationManagerdidDetermineState.............");
    if (state==CLRegionStateInside&&self.activeAlarms) {
        //if add alarm within the region, this method is delayed to call. so check if there is active alarm.
        [self startHighAccuracy];
        [self.cllmng stopMonitoringForRegion:region];
        
        [self updateInfo:@"You'v already in the region!"];
    }
    else{
        [self startLowAccuracy];
        [self.cllmng startMonitoringForRegion:region];
    }
}

- (void) locationManager:(CLLocationManager *)manager didExitRegion:(CLRegion *)region{
    [self startLowAccuracy];
    [self.cllmng startMonitoringForRegion:region];
}

- (void)locationManager:(CLLocationManager *)manager didEnterRegion:(CLRegion *)region{
    if (self.activeAlarms) {
        [self startHighAccuracy];
        [self.cllmng stopMonitoringForRegion:region];
        
        [self updateInfo:@"Enter region!"];
    }
}

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status{
    [self updateInfo:@"change authorization called"];
    if (status==kCLAuthorizationStatusDenied) {
        for (Alarms * a in self.activeAlarms) {
            a.state=OFFSTATE;
        }
        [PTVAlarmDefine alertOfLocationServiceUnavailable:self];
    }
}
- (void)locationManager:(CLLocationManager *)manager monitoringDidFailForRegion:(CLRegion *)region withError:(NSError *)error{
    NSLog(@"monitoringDidFailForRegion!!!!!!!!!!!!!err");
}
- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error{
    [self updateInfo:@"error call"];
}

- (void)locationManager:(CLLocationManager *)manager didStartMonitoringForRegion:(CLRegion *)region {
    NSLog(@"Started monitoring %@ region: %f,%f with R:%f", region.identifier,region.center.latitude,region.center.longitude, region.radius);
    [self updateInfo:[NSString stringWithFormat:@"%d monitored regions!",[[self.cllmng monitoredRegions] count]]];
}

-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations{
    CLLocation *currentLocation=[locations lastObject];
    self.lastLocation=currentLocation;
    for (Alarms * alarm in self.activeAlarms) {
        CLLocation *targetLocation=[[CLLocation alloc] initWithLatitude:alarm.toWhich.latitude.doubleValue longitude:alarm.toWhich.longitude.doubleValue];
        CLLocationDistance distance=[targetLocation distanceFromLocation:currentLocation];
        if (distance<ALARM_DISTANCE) {
            [self closeEnoughToTarget:alarm];
        }
    }
    
    NSString *str=[NSString stringWithFormat:@"location update:%f,%f",currentLocation.coordinate.latitude,currentLocation.coordinate.longitude];
    [self updateInfo:str];
}

-(void) closeEnoughToTarget:(Alarms *) destination{
    [self startHighAccuracy];
    if ([[self.delayDict objectForKey:destination.toWhich.name] isEqualToNumber:[NSNumber numberWithInt:DELAY_TIMES]]) {
        //reach destination
        
        
        [self stopLocationService];
        //alert when arrival
        if (UIApplication.sharedApplication.applicationState == UIApplicationStateActive) {
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
        //        self.activeAlarms=nil;
        [self.delayDict setObject:[NSNumber numberWithInt:0] forKey:destination.toWhich.address];
        
    }
    else{
        NSNumber * newnum=[NSNumber numberWithInt:([[self.delayDict objectForKey:destination.toWhich.name] intValue]+1)];
        [self.delayDict setObject:newnum forKey:destination.toWhich.name];
    }
    [self updateInfo:[NSString stringWithFormat:@"You are close to target!!!"]];
}


- (void) updateInfo:(NSString *) msg{
    NSLog(@"%@",msg);
    [self.delegate updateTextField:msg];
}
- (void) startHighAccuracy{
//    if (!self.isHighAccuracy) {
        [self.cllmng stopMonitoringSignificantLocationChanges];
        [self.cllmng startUpdatingLocation];
        self.isHighAccuracy=true;
    NSLog(@"start high mode");
//    }
}

- (void) startLowAccuracy{
    self.isHighAccuracy=false;
    [self.cllmng stopUpdatingLocation];
    [self.cllmng startMonitoringSignificantLocationChanges];
    NSLog(@"start low mode");
}

- (void) destroyLocationService{
    if (_cllmng) {
        for (CLRegion * r in self.cllmng.monitoredRegions) {
            [self.cllmng stopMonitoringForRegion:r];
        }
        self.isHighAccuracy=false;
        [self.cllmng stopUpdatingLocation];
        [self.cllmng stopMonitoringSignificantLocationChanges];
        self.cllmng=nil;
        NSLog(@"destory cllmng");
    }
}
- (void) stopLocationService{
    self.isHighAccuracy=false;
    [self.cllmng stopUpdatingLocation];
    [self.cllmng stopMonitoringSignificantLocationChanges];
    NSLog(@"stop location service");
}

@end
