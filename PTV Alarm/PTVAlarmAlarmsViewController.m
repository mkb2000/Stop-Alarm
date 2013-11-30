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
#import "PTVAlarmTableViewCell.h"

@interface PTVAlarmAlarmsViewController ()
@property (nonatomic) NSFetchedResultsController* fetchedResultsController;
@property (nonatomic)NSManagedObjectContext * managedObjectContext;
//@property (nonatomic,strong) NSFetchRequest * fetchRequest;
//@property (nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;
//@property (nonatomic) NSManagedObjectModel *managedObjectModel;
@end

@implementation PTVAlarmAlarmsViewController



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

//Change background color at each even row.
-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row%2 == 0) {
        UIColor *altCellColor = [UIColor colorWithWhite:0.7 alpha:0.1];
        cell.backgroundColor = altCellColor;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"alarmCell";
    
    /*
     Use a default table view cell to display the event's title.
     */
    PTVAlarmTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	
    [self configureCell:cell atIndexPath:indexPath];
    
    return cell;
}

// Customize the appearance of table view cells.
- (void)configureCell:(PTVAlarmTableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    Alarms *event = [self.fetchedResultsController objectAtIndexPath:indexPath];
    cell.alarm=event;
    cell.mainlabel.text=event.name;
    cell.sublabel.text=event.address;
    NSString *imgstr;
        int etype=event.type.intValue;
        switch (etype) {
            case Tram:
                imgstr=IMG_TRAM;
                break;
           case Train:
               imgstr=IMG_TRAIN;
               break;
           case Metrobus:
            imgstr=IMG_METROBUS;
               break;

           default:
              imgstr=IMG_TRAM;
               break;
        }
    cell.img.image=[UIImage imageNamed:imgstr];
    cell.uiswitch.on=[event.state boolValue];
    
    //
//    Alarms *event = [self.fetchedResultsController objectAtIndexPath:indexPath];
//    
//    UILabel *label;
//    
//    label = (UILabel *)[cell viewWithTag:2];
//    label.text = event.name;
//    
//    label = (UILabel *)[cell viewWithTag:3];
//    label.text = event.address;
//    
//    NSString *imgstr;
//    int etype=event.type.intValue;
//    switch (etype) {
//        case Tram:
//            imgstr=IMG_TRAM;
//            break;
//        case Train:
//            imgstr=IMG_TRAIN;
//            break;
//        case Metrobus:
//            imgstr=IMG_METROBUS;
//            break;
//            
//        default:
//            imgstr=IMG_TRAM;
//            break;
//    }
//    UIImageView *imgview;
//    imgview=(UIImageView *)[cell viewWithTag:1];
//    imgview.image=[UIImage imageNamed:imgstr];
//    
//    UISwitch * stateSwitch;
//    stateSwitch=(UISwitch *)[cell viewWithTag:4];
//    stateSwitch.on=[event.state boolValue];
//    cell.detailTextLabel.text=([event.state intValue]!=0) ? @"ON": @"OFF";
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    // Set up the edit and add buttons.
    self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    NSError *error;
    if (![[self fetchedResultsController] performFetch:&error]) {
        /*
         Replace this implementation with code to handle the error appropriately.
         
         abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
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

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        
        // Delete the managed object.
        NSManagedObjectContext *context = [self.fetchedResultsController managedObjectContext];
        [context deleteObject:[self.fetchedResultsController objectAtIndexPath:indexPath]];
        
        NSError *error;
        if (![context save:&error]) {
            /*
             Replace this implementation with code to handle the error appropriately.
             
             abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
             */
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
}


#pragma mark - Table view editing

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    
    // The table view should not be re-orderable.
    return NO;
}




/*
 NSFetchedResultsController delegate methods to respond to additions, removals and so on.
 */
- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
    
    // The fetch controller is about to start sending change notifications, so prepare the table view for updates.
    [self.tableView beginUpdates];
}


- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath {
    
//    NSLog(@"changing");
    
    UITableView *tableView = self.tableView;
    
    switch(type) {
            
        case NSFetchedResultsChangeInsert:
            [tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
            break;
            
        case NSFetchedResultsChangeDelete:
            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
            break;
            
        case NSFetchedResultsChangeUpdate:
            [self configureCell:(PTVAlarmTableViewCell *)[tableView cellForRowAtIndexPath:indexPath] atIndexPath:indexPath];
            break;
            
        case NSFetchedResultsChangeMove:
            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
            [tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
            break;
    }
}


- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type
{
    switch(type) {
            
        case NSFetchedResultsChangeInsert:
            [self.tableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationAutomatic];
            break;
            
        case NSFetchedResultsChangeDelete:
            [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationAutomatic];
            break;
    }
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    //    [self.tableView reloadData];
    // The fetch controller has sent all current change notifications, so tell the table view to process all updates.
    [self.tableView endUpdates];
}

//- (IBAction)switchAction:(id)sender {
//    UISwitch * s=(UISwitch *) sender;
//    s.
//    NSIndexPath * path=[self.tableView indexPathForSelectedRow];
//    NSLog(@"row:%d section:%d",path.row,path.section);
//    NSLog(@"sate: %d",s.on);
//}

@end
