//
//  PTVAlarmDefine.h
//  PTV Alarm
//
//  Created by Kangbo Mo on 28/11/2013.
//  Copyright (c) 2013 Kangbo Mo. All rights reserved.
//

#import <Foundation/Foundation.h>
#define ENTITY_ALARM @"Alarms"
#define ENTITY_STATION @"Stations"
#define OFFSTATE 0
#define ONSTATE 1
#define IMG_TRAIN @"TrainIcon30px.gif"
#define IMG_TRAM @"TramIcon30px.gif"
#define IMG_METROBUS @"BusIcon30px.gif"
#define FILE_TRAIN @"train.csv"
#define FILE_VLINE @"vline.csv"
#define FILE_TRAM @"tram.csv"
#define FILE_BUS @"bus.csv"
#define ALARM_DISTANCE 300 //When this far away, may triger the alarm.
#define DELAY_TIMES 2 //Triger the alarm only when this many times of location updates within ALARM_DISTANCE.

typedef  enum{
    Train=0,Bus=1,Tram=2,Vline=3
} TransportType;

@interface PTVAlarmDefine : NSObject
@property NSURL * STATIONFILEURL;

+ (PTVAlarmDefine *) globalVariables;
+ (TransportType) filenameToStationType:(NSString *) filename;
@end
