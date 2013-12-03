//
//  PTVAlarmManager.h
//  PTV Alarm
//
//  Created by Kangbo Mo on 1/12/2013.
//  Copyright (c) 2013 Kangbo Mo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

#import "Alarms.h"
#import "Stations.h"
#import "PTVAlarmViewController.h"


@interface PTVAlarmManager : NSObject <CLLocationManagerDelegate>

@property (weak,nonatomic) PTVAlarmViewController * delegate;//for test

//-(void) addAlarm:(Alarms *) newAlarm;
//-(void) removeAlarm:(Alarms *) alarm;
//- (PTVAlarmManager *) initWithAlarms:(NSArray *) activealarms;
-(void) activeAlarmsChange:(NSArray *) activealarms;

@end
