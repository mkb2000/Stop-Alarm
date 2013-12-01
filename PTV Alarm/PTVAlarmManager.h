//
//  PTVAlarmManager.h
//  PTV Alarm
//
//  Created by Kangbo Mo on 1/12/2013.
//  Copyright (c) 2013 Kangbo Mo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Alarms.h"
@interface PTVAlarmManager : NSObject
-(void) addAlarm:(Alarms *) newAlarm;
-(void) removeAlarm:(Alarms *) alarm;
@end
