//
//  PTVAlarmAppDelegate.m
//  PTV Alarm
//
//  Created by Kangbo Mo on 15/11/2013.
//  Copyright (c) 2013 Kangbo Mo. All rights reserved.
//

#import "PTVAlarmAppDelegate.h"
#import "Stations.h"
#import "Line.h"
#import "FileReader.h"


@implementation PTVAlarmAppDelegate
@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;



- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
    
    //if core data is empty, read station info from files and store to core data.
    if ([self stationIsEmpty]) {
        [self loadStations];
    }
    self.ptvalarmmanager=[[PTVAlarmManager alloc] init];
    [self.ptvalarmmanager activeAlarmsChange:[self activeAlarms]];
    //Any change to alarm state will be observed.
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(activeAlarmsChange) name:NSManagedObjectContextObjectsDidChangeNotification object:nil];
    
    return YES;
}
							
- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    if (IS_DEBUG) {
            NSLog(@"enter background model");
    }
    [self.managedObjectContext save:Nil];
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    self.ptvalarmmanager.backgroundMode=false;
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    if (IS_DEBUG) {
        NSLog(@"enter terminate model");
    }
    [self.managedObjectContext save:Nil];
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

- (void) applicationDidReceiveMemoryWarning:(UIApplication *)application{
    
}

#pragma mark - Core data preparations
// 1
- (NSManagedObjectContext *) managedObjectContext {
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
        _managedObjectContext = [[NSManagedObjectContext alloc] init];
        [_managedObjectContext setPersistentStoreCoordinator: coordinator];
    }
    
    return _managedObjectContext;
}

//2
- (NSManagedObjectModel *)managedObjectModel {
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    _managedObjectModel = [NSManagedObjectModel mergedModelFromBundles:nil];
    
    return _managedObjectModel;
}

//3
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    NSURL *storeUrl = [NSURL fileURLWithPath: [[self applicationDocumentsDirectory]
                                               stringByAppendingPathComponent: @"Alarms.sqlite"]];
    NSError *error = nil;
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc]
                                   initWithManagedObjectModel:[self managedObjectModel]];
    if(![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType
                                                  configuration:nil URL:storeUrl options:nil error:&error]) {
        /*Error for store creation should be handled in here*/
    }
    
    return _persistentStoreCoordinator;
}

- (NSString *)applicationDocumentsDirectory {
    return [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
}

#pragma mark - initialize core data of stations from files
- (BOOL) stationIsEmpty{
    if ([[self fetchStation] count]==0) {
        return true;
    }
    return false;
}

- (NSArray *) fetchStation{
    NSFetchRequest * request=[NSFetchRequest fetchRequestWithEntityName:ENTITY_STATION];
    return [self.managedObjectContext executeFetchRequest:request error:nil];
}

//read files and put entries into core data
- (void) loadStations{
//    NSArray * files=@[FILE_TRAIN,FILE_TRAM];//,FILE_TRAIN,FILE_TRAIN,FILE_TRAIN];
    NSArray * files=@[FILE_TRAIN,FILE_TRAM,FILE_BUS,FILE_VLINE];
    
    for (NSString * filename in files) {
        NSFileManager *filem=[NSFileManager defaultManager];
        NSString *filepath=[[NSBundle mainBundle] pathForResource:filename ofType:@""];
        if ([filem fileExistsAtPath:filepath]) {
            FileReader * reader=[[FileReader alloc] initWithFile:filepath];
            NSString * line = nil;
            int lnum=0;
            NSMutableDictionary * existedLine=[NSMutableDictionary dictionary];//cache new created Line
            while ((line = [reader nextLine])) {
                lnum++;
                NSDictionary * stationInfo=[NSJSONSerialization JSONObjectWithData:[line dataUsingEncoding:NSMacOSRomanStringEncoding] options:kNilOptions error:nil];
                if (!stationInfo) {
                    NSLog(@"lien %d unable to deal with",lnum);
                    continue;
                }
                Stations *station=[NSEntityDescription insertNewObjectForEntityForName:ENTITY_STATION
                                                                inManagedObjectContext:self.managedObjectContext];
                station.name=[stationInfo objectForKey:@"name"];
                station.initial=[[ NSString stringWithString:[station.name substringToIndex:1] ]uppercaseString];
                station.suburb=[stationInfo objectForKey:@"suburb"];
                station.address= [stationInfo objectForKey:@"address"];
                NSArray * cor=[[stationInfo objectForKey:@"coordinate"] componentsSeparatedByString:@","];
                station.latitude=cor[0];
                station.longitude=cor[1];
                station.type=[NSNumber numberWithInt:[PTVAlarmDefine filenameToStationType:filename]];
                
                //link station with line; if line not existed,create it.
                NSString *linename;
                NSString *linkToLine;
                for (int i=0; i<[[stationInfo objectForKey:@"lines"] count]; i++) {
                    linename=[stationInfo objectForKey:@"lines"][i];
                    linkToLine=[stationInfo objectForKey:@"linksToLines"][i];
                    Line *templine=[existedLine objectForKey:linename];
                    if (!templine) {
                        //create new line.
                        templine=[NSEntityDescription insertNewObjectForEntityForName:ENTITY_LINE inManagedObjectContext:self.managedObjectContext];
                        templine.name=linename;
                        templine.link=linkToLine;
                        [existedLine setObject:templine forKey:linename];
                    }
                    //link station and line.
                    NSMutableSet *temLineSet=[NSMutableSet setWithSet:station.belongTo];
                    NSMutableSet *temStationSet=[NSMutableSet setWithSet:templine.composedOf];
                    [temLineSet addObject:templine];
                    [temStationSet addObject:station];
                    station.belongTo=temLineSet;
                    templine.composedOf=temStationSet;
                }
            }
            reader=Nil;
            existedLine=nil;
            NSLog(@"%d lines in file %@",lnum,filename);
        }
        else{
            NSLog(@"file:%@ not exit",filename);
        }
    }
    [self.managedObjectContext save:nil];
    NSLog(@"files loaded!");
}

// return the alarms that currently ON.
- (NSArray *)activeAlarms{
    NSFetchRequest * fetch=[NSFetchRequest fetchRequestWithEntityName:ENTITY_ALARM];
    NSPredicate *predicate=[NSPredicate predicateWithFormat:@"state=1"];
    fetch.predicate=predicate;
    NSArray * result;
    result=[self.managedObjectContext executeFetchRequest:fetch error:nil];
    NSLog(@"qactive alarm amount: %d", (int)[result count]);
    return result;
}

// called via Notification whenever alarm state changes.
- (void) activeAlarmsChange{
    [self.managedObjectContext save:nil];
    [self.ptvalarmmanager activeAlarmsChange:[self activeAlarms]];
}



@end
