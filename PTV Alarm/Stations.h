//
//  Stations.h
//  Stop Alarm
//
//  Created by Kangbo Mo on 14/01/2014.
//  Copyright (c) 2014 Kangbo Mo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Alarms, Line;

@interface Stations : NSManagedObject

@property (nonatomic, retain) NSString * address;
@property (nonatomic, retain) NSString * initial;
@property (nonatomic, retain) NSString * latitude;
@property (nonatomic, retain) NSString * longitude;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSNumber * stationID;
@property (nonatomic, retain) NSString * suburb;
@property (nonatomic, retain) NSNumber * type;
@property (nonatomic, retain) Alarms *alarm;
@property (nonatomic, retain) NSSet *belongTo;
@end

@interface Stations (CoreDataGeneratedAccessors)

- (void)addBelongToObject:(Line *)value;
- (void)removeBelongToObject:(Line *)value;
- (void)addBelongTo:(NSSet *)values;
- (void)removeBelongTo:(NSSet *)values;

@end
