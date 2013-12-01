//
//  PTVAlarmManager.m
//  PTV Alarm
//
//  Created by Kangbo Mo on 1/12/2013.
//  Copyright (c) 2013 Kangbo Mo. All rights reserved.
//
//  Manage alive alarms. Alert when destination is arrived.

#import "PTVAlarmManager.h"

@interface PTVAlarmManager()
@property (nonatomic,strong) NSMutableArray * aliveAlarms;

@end

@implementation PTVAlarmManager

- (void)addAlarm:(Alarms *)newAlarm{
    [self.aliveAlarms addObject:newAlarm];
    
    //TODO: when new alarm is added, set up Core Location functions.
    
}

- (void)removeAlarm:(Alarms *)alarm{
    [self.aliveAlarms removeObject:alarm];
}

@end
