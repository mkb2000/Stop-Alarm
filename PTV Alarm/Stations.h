//
//  Stations.h
//  PTV Alarm
//
//  Created by Kangbo Mo on 1/12/2013.
//  Copyright (c) 2013 Kangbo Mo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Stations : NSManagedObject

@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * address;
@property (nonatomic, retain) NSString * latitude;
@property (nonatomic, retain) NSString * longitude;
@property (nonatomic, retain) NSString * suburb;
@property (nonatomic, retain) NSNumber * type;
@property (nonatomic, retain) NSString * initial;
@property (nonatomic, retain) NSNumber * stationID;

@end
