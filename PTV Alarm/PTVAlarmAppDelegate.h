//
//  PTVAlarmAppDelegate.h
//  PTV Alarm
//
//  Created by Kangbo Mo on 15/11/2013.
//  Copyright (c) 2013 Kangbo Mo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PTVAlarmManager.h"

@interface PTVAlarmAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (atomic, readonly,strong) NSManagedObjectModel *managedObjectModel;
@property (atomic, readonly,strong) NSManagedObjectContext *managedObjectContext;
@property (atomic, readonly,strong) NSPersistentStoreCoordinator *persistentStoreCoordinator ;
@property (strong,nonatomic) PTVAlarmManager * ptvalarmmanager;

- (NSArray *) activeAlarms;

@end
