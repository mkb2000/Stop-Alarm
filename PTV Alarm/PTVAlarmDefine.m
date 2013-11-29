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

@end
