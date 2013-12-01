//
//  Alarms.h
//  PTV Alarm
//
//  Created by Kangbo Mo on 1/12/2013.
//  Copyright (c) 2013 Kangbo Mo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Stations;

@interface Alarms : NSManagedObject

@property (nonatomic, retain) NSDate * addDate;
@property (nonatomic, retain) NSDate * lastUse;
@property (nonatomic, retain) NSNumber * state;
@property (nonatomic, retain) Stations *toWhich;

@end
