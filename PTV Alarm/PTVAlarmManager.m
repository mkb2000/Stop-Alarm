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
@property (nonatomic,strong) NSMutableArray * activeAlarms;
@property (nonatomic,strong) CLLocationManager * cllmng;
@property (nonatomic,strong) NSMutableDictionary * delayDict;
@property (nonatomic) BOOL isHighAccuracy;
@end

@implementation PTVAlarmManager


- (NSMutableDictionary *)delayDict{
    if (!_delayDict) {
        _delayDict=[[NSMutableDictionary alloc]init];
    }
    return _delayDict;
}

//start point of this class.
-(void)activeAlarmsChange:(NSArray *)activealarms{
    for (CLRegion * r in [self.cllmng monitoredRegions]) {
        //clear monitored regions.
        [self.cllmng stopMonitoringForRegion:r];
    }
    [self stopClocationService];
    self.activeAlarms=[NSMutableArray arrayWithArray:activealarms];
    for (Alarms * al in self.activeAlarms) {
        [self addMonitoredRegion:al];
    }
    [self updateInfo:[NSString stringWithFormat:@"%d monitored regions!",[[self.cllmng monitoredRegions] count]]];
    [self updateInfo:[NSString stringWithFormat:@"cllmng obj:%@",self.cllmng]];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(enterBackground) name:UIApplicationDidEnterBackgroundNotification object:nil];
}

-(void) enterBackground{
    [self updateInfo:[NSString stringWithFormat:@"High accuracy model: %d",self.isHighAccuracy]];
}

- (void) initCLLocationManager{
    self.cllmng=[[CLLocationManager alloc]init];
    self.cllmng.delegate=self;
    self.cllmng.desiredAccuracy=kCLLocationAccuracyNearestTenMeters;
    self.cllmng.distanceFilter=20;
    [self.cllmng startMonitoringSignificantLocationChanges];
}

-(void) addMonitoredRegion:(Alarms *) alarm{
    
    if ([self.activeAlarms count]>0&&self.cllmng==nil) {
        [self initCLLocationManager];
    }
    
    //add the destination to monitored regions.
    if ([self.activeAlarms count]>0) {
        
        [self.delayDict setObject:[NSNumber numberWithInt:0] forKey:alarm.toWhich.name];
        
        CLLocationCoordinate2D centre;
        centre.latitude=alarm.toWhich.latitude.doubleValue;
        centre.longitude=alarm.toWhich.longitude.doubleValue;
        MKCircle * overlay=[MKCircle circleWithCenterCoordinate:centre radius:200];
        // If the overlay's radius is too large, registration fails automatically,
        // so clamp the radius to the max value.
        
        CLLocationDegrees radius = overlay.radius;
        if (radius > self.cllmng.maximumRegionMonitoringDistance) {
            radius = self.cllmng.maximumRegionMonitoringDistance;
        }
        
        //    NSLog(@"mo: %f,%f, %f",coordinate.latitude,coordinate.longitude, radius);
        // Create the geographic region to be monitored.
        
        CLCircularRegion *geoRegion = [[CLCircularRegion alloc]
                                       initWithCenter:overlay.coordinate
                                       radius:radius
                                       identifier:alarm.toWhich.name];
        
        [self.cllmng requestStateForRegion:geoRegion];
        
        [self.cllmng startMonitoringForRegion:geoRegion];
    }
}


- (void)locationManager:(CLLocationManager *)manager didDetermineState:(CLRegionState)state forRegion:(CLRegion *)region{
    if (state==CLRegionStateInside) {
        [self startHighAccuracy];
        [self.cllmng stopMonitoringForRegion:region];
        
        [self updateInfo:@"You'v already in the region!"];
    }
}

- (void)locationManager:(CLLocationManager *)manager didEnterRegion:(CLRegion *)region{
    [self startHighAccuracy];
    [self.cllmng stopMonitoringForRegion:region];
    
    [self updateInfo:@"Enter region!"];
}

- (void) startHighAccuracy{
    if (!self.isHighAccuracy) {
        //TODO background model.
        [self.cllmng stopMonitoringSignificantLocationChanges];
        [self.cllmng startUpdatingLocation];
        self.isHighAccuracy=true;
    }
}

- (void) stopClocationService{
    self.isHighAccuracy=false;
    [self.cllmng stopUpdatingLocation];
    [self.cllmng stopMonitoringSignificantLocationChanges];
    self.cllmng=nil;
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

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error{
    [self updateInfo:@"error call"];
}

- (void)locationManager:(CLLocationManager *)manager didStartMonitoringForRegion:(CLRegion *)region {
    NSLog(@"Started monitoring %@ region: %f,%f with R:%f", region.identifier,region.center.latitude,region.center.longitude, region.radius);
}

-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations{
    CLLocation *currentLocation=[locations lastObject];
    for (Alarms * alarm in self.activeAlarms) {
        CLLocation *targetLocation=[[CLLocation alloc] initWithLatitude:alarm.toWhich.latitude.doubleValue longitude:alarm.toWhich.longitude.doubleValue];
        CLLocationDistance distance=[targetLocation distanceFromLocation:currentLocation];
        if (distance<ALARM_DISTANCE) {
            [self closeEnoughToTarget:alarm];
            //            break;
        }
    }
    
    NSString *str=[NSString stringWithFormat:@"location update:%f,%f",currentLocation.coordinate.latitude,currentLocation.coordinate.longitude];
    [self updateInfo:str];
}

-(void) closeEnoughToTarget:(Alarms *) destination{
    [self startHighAccuracy];
    if ([[self.delayDict objectForKey:destination.toWhich.name] isEqualToNumber:[NSNumber numberWithInt:DELAY_TIMES]]) {
        //reach destination
        
        destination.state=0;
        self.activeAlarms=nil;
        self.delayDict=nil;
        
        [self.cllmng stopUpdatingLocation];
        [self.cllmng stopMonitoringSignificantLocationChanges];
        self.cllmng=nil;
        
        
        //alert when arrival
        if (UIApplication.sharedApplication.applicationState == UIApplicationStateActive) {
            UIAlertView * alertview=[[UIAlertView alloc] initWithTitle:[@"Arrival" stringByAppendingString:destination.toWhich.name] message:@"Your destination is around the corner!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alertview show];
        }
        else{
            // alert from bacground.
            
            UIApplication* app = [UIApplication sharedApplication];
            NSArray*    oldNotifications = [app scheduledLocalNotifications];
            // Clear out the old notification before scheduling a new one.
            if ([oldNotifications count] > 0)
                [app cancelAllLocalNotifications];
            // Create a new notification.
            UILocalNotification* alarm = [[UILocalNotification alloc] init];
            if (alarm)
            {
                
                alarm.timeZone = [NSTimeZone defaultTimeZone];
                alarm.repeatInterval = 0;
                alarm.soundName = UILocalNotificationDefaultSoundName;
                alarm.alertBody = @"Time to wake up!";
                //                [app scheduleLocalNotification:alarm];
                [app presentLocalNotificationNow:alarm];
            }
            
        }
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

//#pragma mark - alert view actions
//- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
//    switch (buttonIndex) {
//        case 0:
//            [[[UIApplication sharedApplication] delegate] application:<#(UIApplication *)#> openURL:<#(NSURL *)#> sourceApplication:<#(NSString *)#> annotation:<#(id)#>];
//            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"prefs:root=LOCATION_SERVICES"]];
//            break;
//        default:
//            break;
//    }
//}
@end
