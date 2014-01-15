//
//  Line.h
//  Stop Alarm
//
//  Created by Kangbo Mo on 14/01/2014.
//  Copyright (c) 2014 Kangbo Mo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Stations;

@interface Line : NSManagedObject

@property (nonatomic, retain) NSString * link;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSSet *composedOf;
@end

@interface Line (CoreDataGeneratedAccessors)

- (void)addComposedOfObject:(Stations *)value;
- (void)removeComposedOfObject:(Stations *)value;
- (void)addComposedOf:(NSSet *)values;
- (void)removeComposedOf:(NSSet *)values;

@end
