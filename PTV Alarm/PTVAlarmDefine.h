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
#define IMG_TRAIN @"TrainIcon30px.gif"
#define IMG_TRAM @"TramIcon30px.gif"
#define IMG_METROBUS @"BusIcon30px.gif"

typedef  enum{
    Train,Metrobus,Tram,Vline
} TransportType;

@interface PTVAlarmDefine : NSObject
@property NSURL * STATIONFILEURL;

+ (PTVAlarmDefine *) globalVariables;
@end
