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
#define IMG_TRAIN @"train_metro_trans.png"
#define IMG_TRAM @"tram_trans.png"
#define IMG_METROBUS @"bus_trans.png"
#define IMG_VLINE @"train_region_trans.png"
#define ICON_TRAIN @"iconTrain.png"
#define ICON_TRAM @"iconTram.png"
#define ICON_METROBUS @"iconBus.png"
#define ICON_VLINE @"iconVline.png"
#define FILE_TRAIN @"train.csv"
#define FILE_VLINE @"vline.csv"
#define FILE_TRAM @"tram.csv"
#define FILE_BUS @"bus.csv"
#define ALARM_DISTANCE 300 //When this far away, may triger the alarm.
#define ALARM_DISTANCE_BUS 200
#define ALARM_DISTANCE_TRAIN 400
#define ALARM_DISTANCE_TRAM 200
#define DELAY_TIMES 1 //Triger the alarm only when this many times of location updates within ALARM_DISTANCE.
#define IS_DEBUG 1

typedef  enum{
    Train=0,Bus=1,Tram=2,Vline=3
} TransportType;

@interface PTVAlarmDefine : NSObject

@property NSURL * STATIONFILEURL;

+ (NSString *) typeToImgFile:(TransportType) type;
+ (PTVAlarmDefine *) globalVariables;
+ (TransportType) filenameToStationType:(NSString *) filename;
+ (void) alertOfLocationServiceUnavailable:(id) delegate;
+ (int) alertDistanceForType:(TransportType) type;

@end
