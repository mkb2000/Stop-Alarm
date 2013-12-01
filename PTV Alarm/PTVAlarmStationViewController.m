//
//  PTVAlarmSelectFromStationViewController.m
//  PTV Alarm
//
//  Created by Kangbo Mo on 15/11/2013.
//  Copyright (c) 2013 Kangbo Mo. All rights reserved.
//

#import "PTVAlarmStationViewController.h"
#import "PTVAlarmDetailViewController.h"
#import "PTVAlarmAppDelegate.h"
#import "Stations.h"

@interface PTVAlarmStationViewController ()

@property (nonatomic) NSFetchedResultsController* fetchedResultsController;
@property (nonatomic)NSManagedObjectContext * managedObjectContext;
@end

@implementation PTVAlarmStationViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    NSError *error;
    if (![[self fetchedResultsController] performFetch:&error]) {
        /*
         Replace this implementation with code to handle the error appropriately.
         
         abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
         */
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source
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
    fetchRequest.predicate=[NSPredicate predicateWithFormat:@"type=%d",self.stationType];
    NSEntityDescription *entity = [NSEntityDescription entityForName:ENTITY_STATION
                                              inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    [fetchRequest setFetchBatchSize:20];
    
    // Sort using * property.
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES];
    NSSortDescriptor *initDescriptor=[[NSSortDescriptor alloc] initWithKey:@"initial" ascending:YES];
    [fetchRequest setSortDescriptors:@[sortDescriptor, initDescriptor]];
    _fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
                                                                    managedObjectContext:self.managedObjectContext
                                                                      sectionNameKeyPath:@"initial"
                                                                               cacheName:nil];
    _fetchedResultsController.delegate = self;
    
    return _fetchedResultsController;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    NSInteger n=[[self.fetchedResultsController sections] count];
    return n;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    id <NSFetchedResultsSectionInfo> sectionInfo = [[self.fetchedResultsController sections] objectAtIndex:section];
    
	return [sectionInfo numberOfObjects];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"stationCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    Stations * stationInfo=[self.fetchedResultsController objectAtIndexPath:indexPath];
    cell.textLabel.text=stationInfo.name;
    cell.detailTextLabel.text=stationInfo.suburb;
    
    UIImage * img=[UIImage imageNamed:self.imgname];
    cell.imageView.image=img;
    //    NSLog(@"%d,%d",indexPath.row,indexPath.section);
    
    //    cell.textLabel.text=
    // Configure the cell...
    
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if ([[self.fetchedResultsController sections] count] > 0) {
        id <NSFetchedResultsSectionInfo> sectionInfo = [[self.fetchedResultsController sections] objectAtIndex:section];
        return [sectionInfo name];
    } else
        return nil;
}

 //For sidebar navigation
- (NSArray *) sectionIndexTitlesForTableView:(UITableView *)tableView{
    return [self.fetchedResultsController sectionIndexTitles];
}
// For sidebar navigation
- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index{
    return [self.fetchedResultsController sectionForSectionIndexTitle:title atIndex:index];
}

/*
 // Override to support conditional editing of the table view.
 - (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
 {
 // Return NO if you do not want the specified item to be editable.
 return YES;
 }
 */

/*
 // Override to support editing the table view.
 - (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
 {
 if (editingStyle == UITableViewCellEditingStyleDelete) {
 // Delete the row from the data source
 [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
 }
 else if (editingStyle == UITableViewCellEditingStyleInsert) {
 // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
 }
 }
 */

/*
 // Override to support rearranging the table view.
 - (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
 {
 }
 */

/*
 // Override to support conditional rearranging of the table view.
 - (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
 {
 // Return NO if you do not want the item to be re-orderable.
 return YES;
 }
 */

#pragma mark - Navigation

// In a story board-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if ([[segue identifier] isEqualToString:@"stationDetail"]) {
        NSIndexPath * index=[self.tableView indexPathsForSelectedRows][0];
        PTVAlarmDetailViewController * dvController=[segue destinationViewController];
        Stations * station=[self.fetchedResultsController objectAtIndexPath:index];
        dvController.station=station;

    }
}


@end
