//
//  PTVAlarmDefine.h
//  PTV Alarm
//
//  Created by Kangbo Mo on 28/11/2013.
//  Copyright (c) 2013 Kangbo Mo. All rights reserved.
//

#import <Foundation/Foundation.h>
#define ALARMSFILE @"Alarms"
#define OFFSTATE 0
#define ONSTATE 1

@interface PTVAlarmDefine : NSObject
@property NSURL * STATIONFILEURL;

+ (PTVAlarmDefine *) globalVariables;
@end
