//
//  PTVAlarmManager.m
//  PTV Alarm
//
//  Created by Kangbo Mo on 1/12/2013.
//  Copyright (c) 2013 Kangbo Mo. All rights reserved.
//
//  Manage alive alarms. Alert when destination is arrived.

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

//init CLLocationManager and add activeAlarms to be monitored.
//- (void) startMonitorRegions{
//    
//    if ([self.activeAlarms count]>0&&self.cllmng==nil) {
//        [self initCLLocationManager];
//        
//        for (Alarms * al in self.activeAlarms) {
//            [self addMonitoredRegion:al];
//        }
//    }
//}

- (void) initCLLocationManager{
    self.cllmng=[[CLLocationManager alloc]init];
    self.cllmng.delegate=self;
    self.cllmng.desiredAccuracy=kCLLocationAccuracyBest;
    self.cllmng.distanceFilter=10;
    [self.cllmng startMonitoringSignificantLocationChanges];
}

-(void) addMonitoredRegion:(Alarms *) alarm{

    if ([self.activeAlarms count]>0&&self.cllmng==nil) {
        [self initCLLocationManager];
    }
    
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

- (void) finishMonitor:(CLRegion *) region{
    //remove from activeAlarms.
//    for (Alarms * a in self.activeAlarms) {
//        if ([region.identifier isEqualToString:a.toWhich.name]) {
//            [self.activeAlarms removeObject:a];
//        }
//    }
    //remove from monitored regions.
    [self.cllmng stopMonitoringForRegion:region];
}

- (void)locationManager:(CLLocationManager *)manager didDetermineState:(CLRegionState)state forRegion:(CLRegion *)region{
    if (state==CLRegionStateInside) {
        [self startHighAccuracy];
        [self finishMonitor:region];
        
        NSLog(@"You'v already in the region!");
        [self.delegate updateTextField:@"You'v already in the region!"];
    }
}

- (void)locationManager:(CLLocationManager *)manager didEnterRegion:(CLRegion *)region{
    [self startHighAccuracy];
    [self finishMonitor:region];
    
    [self.delegate updateTextField:@"Enter region!"];
    NSLog(@"Enter region!");
}

- (void) startHighAccuracy{
    if (!self.isHighAccuracy) {
        [self.cllmng stopMonitoringSignificantLocationChanges];
        [self.cllmng startUpdatingLocation];
        self.isHighAccuracy=true;
    }
}

- (void) updateInfo:(NSString *) msg{
    NSLog(@"%@",msg);
    [self.delegate updateTextField:msg];
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
        }
    }
    
    NSString *str=[NSString stringWithFormat:@"aalocation update:lat:%f,%f",currentLocation.coordinate.latitude,currentLocation.coordinate.longitude];
    [self updateInfo:str];
}

-(void) closeEnoughToTarget:(Alarms *) destination{
    if ([[self.delayDict objectForKey:destination.toWhich.name] isEqualToNumber:[NSNumber numberWithInt:DELAY_TIMES]]) {
        //reach destination

        destination.state=0;
        //remove the destination/alarm.
        [self.activeAlarms removeObject:destination];
        UIAlertView * alertview=[[UIAlertView alloc] initWithTitle:@"Arrival" message:@"Your destination is around the corner!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alertview show];
        
    }
    else{
        NSNumber * newnum=[NSNumber numberWithInt:([[self.delayDict objectForKey:destination.toWhich.name] intValue]+1)];
        [self.delayDict setObject:newnum forKey:destination.toWhich.name];
    }
    [self updateInfo:[NSString stringWithFormat:@"You are close to target!!!"]];
}



//- (void)addAlarm:(Alarms *)newAlarm{
//    [self.activeAlarms addObject:newAlarm];
//    [self addMonitoredRegion:newAlarm];
//    //TODO: when new alarm is added, set up Core Location functions.
//
//}

//- (void)removeAlarm:(Alarms *)alarm{
//    [self.activeAlarms removeObject:alarm];
//
//    CLLocationDegrees radius = 100;
//    CLLocationCoordinate2D coordinate;
//    coordinate.latitude=alarm.toWhich.latitude.doubleValue;
//    coordinate.longitude=alarm.toWhich.longitude.doubleValue;
//
//
//
//    if (radius > self.cllmng.maximumRegionMonitoringDistance) {
//        radius = self.cllmng.maximumRegionMonitoringDistance;
//    }
//    // Create the geographic region to be monitored.
//    CLCircularRegion *geoRegion = [[CLCircularRegion alloc]
//                                   initWithCenter:coordinate
//                                   radius:radius
//                                   identifier:alarm.toWhich.name];
//    [self.cllmng stopMonitoringForRegion:geoRegion];
//
//    if ([self.activeAlarms count]==0) {
//        [self.cllmng stopMonitoringSignificantLocationChanges];
//        [self.cllmng stopUpdatingLocation];
//    }
//}

-(void)activeAlarmsChange:(NSArray *)activealarms{
    self.isHighAccuracy=false;
    
    
    for (CLRegion * r in [self.cllmng monitoredRegions]) {
        [self.cllmng stopMonitoringForRegion:r];
    }
    self.activeAlarms=[NSMutableArray arrayWithArray:activealarms];
    for (Alarms * al in self.activeAlarms) {
        [self addMonitoredRegion:al];
    }
    //    if ([self.activeAlarms count]==0) {
    //        [self.cllmng stopMonitoringSignificantLocationChanges];
    //        [self.cllmng stopUpdatingLocation];
    //    }
    
    //test
    //    for (Alarms *a in activealarms) {
    //        NSLog(@"momo: %@",a.toWhich.name);
    //    }
    //    NSLog(@"111111");
    //    sleep(2);
    //    for (CLRegion * r in [self.cllmng monitoredRegions]) {
    //        NSString *str=[NSString stringWithFormat:@"Monitored region: %@!",r.identifier];
    //        NSLog(@"Monitored region: %@!",r.identifier);
    //        [self.delegate updateTextField:str];
    //    }
}

@end
