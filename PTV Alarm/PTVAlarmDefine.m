//
//  PTVAlarmDefine.m
//  PTV Alarm
//
//  Created by Kangbo Mo on 28/11/2013.
//  Copyright (c) 2013 Kangbo Mo. All rights reserved.
//

#import "PTVAlarmDefine.h"

@interface PTVAlarmDefine()

@end

@implementation PTVAlarmDefine

+(PTVAlarmDefine *) globalVariables{
    static PTVAlarmDefine * instance=nil;
    
    if (instance==nil) {
        instance=[[PTVAlarmDefine alloc] init];
        NSURL * url=[[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
        instance.STATIONFILEURL =[url URLByAppendingPathComponent:@"alarmedStations"];
    }
    return instance;
}
+ (TransportType) filenameToStationType:(NSString *) filename{
    if ([filename isEqualToString:FILE_TRAIN]) {
        return Train;
    }
    if ([filename isEqualToString:FILE_TRAM]) {
        return Tram;
    }
    if ([filename isEqualToString:FILE_BUS]) {
        return Bus;
    }
    if ([filename isEqualToString:FILE_VLINE]) {
        return Vline;
    }
    return Train;
}

+ (NSString *) typeToImgFile:(TransportType) type{
    NSString *imgstr;
    switch (type) {
        case Tram:
            imgstr=IMG_TRAM;
            break;
        case Train:
            imgstr=IMG_TRAIN;
            break;
        case Bus:
            imgstr=IMG_METROBUS;
            break;
        case Vline:
            imgstr=IMG_VLINE;
            break;
        default:
            imgstr=IMG_TRAM;
            break;
    }
    return imgstr;
}
+ (void) alertOfLocationServiceUnavailable:(id) delegate{
    UIAlertView * alertview=[[UIAlertView alloc] initWithTitle:@"Location Service Unavailable" message:@"This app requires Location Service to function. Please go Settings>Privacy>Location Services and authorise Location Service for this app." delegate:delegate cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    [alertview show];
}

+ (int)alertDistanceForType:(TransportType)type{
    switch (type) {
        case Bus:
            return ALARM_DISTANCE_BUS;
            break;
        case Train:
            return ALARM_DISTANCE_TRAIN;
            break;
        case Tram:
            return ALARM_DISTANCE_TRAM;
            break;
        default:
            return ALARM_DISTANCE;
            break;
    }
}

static PTVAlarmDefine * sharedObj=nil;
- (id) init{
    if (sharedObj) {
        return self=sharedObj;
    }
    if (self=[super init]) {
    }
    return self;
}

+ (id) sharedInstance{
    if (sharedObj) {
        return sharedObj;
    }
    else{
        static dispatch_once_t pred;
        dispatch_once(&pred,^{
            sharedObj=[[PTVAlarmDefine alloc] init];
        });
        return sharedObj;
    }
}

@end
