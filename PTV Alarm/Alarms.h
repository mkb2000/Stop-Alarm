//
//  Alarms.h
//  PTV Alarm
//
//  Created by Kangbo Mo on 1/12/2013.
//  Copyright (c) 2013 Kangbo Mo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "Stations.h"


@interface Alarms : Stations

@property (nonatomic, retain) NSDate * addDate;
@property (nonatomic, retain) NSDate * lastUse;
@property (nonatomic, retain) NSNumber * state;

@end
