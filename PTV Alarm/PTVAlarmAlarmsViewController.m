//
//  PTVAlarmFavoriteViewController.m
//  PTV Alarm
//
//  Created by Kangbo Mo on 15/11/2013.
//  Copyright (c) 2013 Kangbo Mo. All rights reserved.
//

#import "PTVAlarmAlarmsViewController.h"
#import "PTVAlarmDetailViewController.h"
#import "Alarms.h"
#import "PTVAlarmAppDelegate.h"

@interface PTVAlarmAlarmsViewController ()
@property (nonatomic) NSFetchedResultsController* fetchedResultsController;
@property (nonatomic)NSManagedObjectContext * managedObjectContext;
//@property (nonatomic,strong) NSFetchRequest * fetchRequest;
//@property (nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;
//@property (nonatomic) NSManagedObjectModel *managedObjectModel;
@end

@implementation PTVAlarmAlarmsViewController


- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller{
    [self.tableView reloadData];
}

- (NSFetchedResultsController *)fetchedResultsController
{
    if (_fetchedResultsController != nil)
    {
        return _fetchedResultsController;
    }
    
    /*
     Set up the fetched results controller.
     */
    PTVAlarmAppDelegate * delegate=[[UIApplication sharedApplication] delegate];
    self.managedObjectContext=delegate.managedObjectContext;
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    // Edit the entity name as appropriate.
    NSEntityDescription *entity = [NSEntityDescription entityForName:ALARMSFILE
                                              inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    
    // Set the batch size to a suitable number.
    [fetchRequest setFetchBatchSize:20];
    
    // Sort using the timeStamp property.
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"addDate" ascending:YES];
    [fetchRequest setSortDescriptors:@[sortDescriptor ]];
    _fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
                                                                    managedObjectContext:self.managedObjectContext
                                                                      sectionNameKeyPath:nil
                                                                               cacheName:nil];
    _fetchedResultsController.delegate = self;
    
    return _fetchedResultsController;
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	NSInteger count = [[self.fetchedResultsController sections] count];
	return count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	id <NSFetchedResultsSectionInfo> sectionInfo = [[self.fetchedResultsController sections] objectAtIndex:section];
    
	NSInteger count = [sectionInfo numberOfObjects];
	return count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"alarmCell";
    
    /*
     Use a default table view cell to display the event's title.
     */
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
	Alarms *event = [self.fetchedResultsController objectAtIndexPath:indexPath];
	cell.textLabel.text = event.name;
    
    return cell;
}



- (void)viewDidLoad
{
    [super viewDidLoad];
	NSError *error;
    
	if (![self.fetchedResultsController performFetch:&error])
    {
        /*
         Replace this implementation with code to handle the error appropriately.
         
         abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. If it is not possible to recover from the error, display an alert panel that instructs the user to quit the application by pressing the Home button.
         */
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
		abort();
	}
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
