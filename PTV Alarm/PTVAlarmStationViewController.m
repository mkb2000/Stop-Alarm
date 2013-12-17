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
//@property (nonatomic)NSManagedObjectContext * managedObjectContext;
@property (nonatomic, strong) NSFetchedResultsController *searchFetchedResultsController;
@property (nonatomic,strong)PTVAlarmAppDelegate * appdelegate;
@property (nonatomic) BOOL searching;
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
    self.appdelegate=[[UIApplication sharedApplication] delegate];
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
    self.fetchedResultsController=nil;
    self.searchFetchedResultsController=nil;
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
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    fetchRequest.predicate=[NSPredicate predicateWithFormat:@"type=%d",self.stationType];
    NSEntityDescription *entity = [NSEntityDescription entityForName:ENTITY_STATION
                                              inManagedObjectContext:self.appdelegate.managedObjectContext];
    [fetchRequest setEntity:entity];
    [fetchRequest setFetchBatchSize:20];
    
    // Sort using * property.
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES];
    NSSortDescriptor *initDescriptor=[[NSSortDescriptor alloc] initWithKey:@"initial" ascending:YES];
    [fetchRequest setSortDescriptors:@[sortDescriptor, initDescriptor]];
    _fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
                                                                    managedObjectContext:self.appdelegate.managedObjectContext
                                                                      sectionNameKeyPath:@"initial"
                                                                               cacheName:nil];
    _fetchedResultsController.delegate = self;
    
    return _fetchedResultsController;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    NSInteger n=[[[self fetchedResultsControllerForTableView:tableView] sections] count];
    return n;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    NSInteger numberOfRows = 0;
    NSFetchedResultsController *fetchController = [self fetchedResultsControllerForTableView:tableView];
    NSArray *sections = fetchController.sections;
    if(sections.count > 0)
    {
        id <NSFetchedResultsSectionInfo> sectionInfo = [sections objectAtIndex:section];
        numberOfRows = [sectionInfo numberOfObjects];
    }
    
    return numberOfRows;
//    id <NSFetchedResultsSectionInfo> sectionInfo = [[self.fetchedResultsController sections] objectAtIndex:section];
//    
//	return [sectionInfo numberOfObjects];
}

- (void)fetchedResultsController:(NSFetchedResultsController *)fetchedResultsController configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    // configure cell
    Stations * stationInfo=[fetchedResultsController objectAtIndexPath:indexPath];
    cell.textLabel.text=stationInfo.name;
    cell.detailTextLabel.text=stationInfo.suburb;
    if (stationInfo.type.intValue!=Train) {
        cell.textLabel.font=[cell.textLabel.font fontWithSize:16];
    }
    
    UIImage * img=[UIImage imageNamed:self.imgname];
    
//    CGSize itemSize = CGSizeMake(40, 40);
//    UIGraphicsBeginImageContext(itemSize);
//    CGRect imageRect = CGRectMake(0.0, 0.0, itemSize.width, itemSize.height);
//    [img drawInRect:imageRect];
//    cell.imageView.image = UIGraphicsGetImageFromCurrentImageContext();
//    UIGraphicsEndImageContext();

    cell.imageView.image=img;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"stationCell";
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    [self fetchedResultsController:[self fetchedResultsControllerForTableView:tableView] configureCell:cell atIndexPath:indexPath];
    
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    NSFetchedResultsController * frc=[self fetchedResultsControllerForTableView:tableView ];
    if ([[frc sections] count] > 0) {
        id <NSFetchedResultsSectionInfo> sectionInfo = [[frc sections] objectAtIndex:section];
        return [sectionInfo name];
    } else
        return nil;
}

#pragma mark - side bar navigation
 //For sidebar navigation
- (NSArray *) sectionIndexTitlesForTableView:(UITableView *)tableView{
    if (tableView!=self.searchDisplayController.searchResultsTableView) {
        return [self.fetchedResultsController sectionIndexTitles];
    }
    return nil;
}
// For sidebar navigation
- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index{
    if (tableView!=self.searchDisplayController.searchResultsTableView) {
         return [self.fetchedResultsController sectionForSectionIndexTitle:title atIndex:index];
    }
    return  0;
}

#pragma mark - Navigation

// In a story board-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    UITableView *tableview=self.searching? self.searchDisplayController.searchResultsTableView:self.tableView;
    
    if ([[segue identifier] isEqualToString:@"stationDetail"]) {
        NSIndexPath * index=[tableview indexPathsForSelectedRows][0];
        PTVAlarmDetailViewController * dvController=[segue destinationViewController];
        Stations * station=[[self fetchedResultsControllerForTableView:tableview] objectAtIndexPath:index];
        dvController.station=station;
        
    }
}

#pragma mark - search bar content
- (NSFetchedResultsController *)fetchedResultsControllerForTableView:(UITableView *)tableView
{
    return tableView == self.tableView ? self.fetchedResultsController : self.searchFetchedResultsController;
}

- (NSFetchedResultsController *)searchFetchedResultsController
{
    if (!_searchFetchedResultsController) {
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        fetchRequest.predicate=[NSPredicate predicateWithFormat:@"type=%d AND (name CONTAINS[cd] %@ or address CONTAINS[cd] %@)",self.stationType,self.searchDisplayController.searchBar.text,self.searchDisplayController.searchBar.text];
        NSEntityDescription *entity = [NSEntityDescription entityForName:ENTITY_STATION
                                                  inManagedObjectContext:self.appdelegate.managedObjectContext];
        [fetchRequest setEntity:entity];
        [fetchRequest setFetchBatchSize:20];
        
        // Sort using * property.
        NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES];
        NSSortDescriptor *initDescriptor=[[NSSortDescriptor alloc] initWithKey:@"initial" ascending:YES];
        [fetchRequest setSortDescriptors:@[sortDescriptor, initDescriptor]];
        _searchFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
                                                                        managedObjectContext:self.appdelegate.managedObjectContext
                                                                          sectionNameKeyPath:@"initial"
                                                                                   cacheName:nil];
        _searchFetchedResultsController.delegate = self;
        NSError *error;
        if (![_searchFetchedResultsController performFetch:&error]) {
            /*
             Replace this implementation with code to handle the error appropriately.
             
             abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
             */
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
        self.searching=true;
    }

    return _searchFetchedResultsController;
}

#pragma mark -
#pragma mark Search Bar
- (void)searchDisplayControllerDidEndSearch:(UISearchDisplayController *)controller{
    self.searching=false;
}

- (void)searchDisplayController:(UISearchDisplayController *)controller willUnloadSearchResultsTableView:(UITableView *)tableView;
{
    // search is done so get rid of the search FRC and reclaim memory
    self.searchFetchedResultsController.delegate = nil;
    self.searchFetchedResultsController = nil;
    self.searching=false;
}

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString
{
    [self filterContentForSearchText:searchString
                               scope:[self.searchDisplayController.searchBar selectedScopeButtonIndex]];
    
    // Return YES to cause the search result table view to be reloaded.
    return YES;
}


- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchScope:(NSInteger)searchOption
{
    [self filterContentForSearchText:[self.searchDisplayController.searchBar text]
                               scope:[self.searchDisplayController.searchBar selectedScopeButtonIndex]];
    
    // Return YES to cause the search result table view to be reloaded.
    return YES;
}
#pragma mark Content Filtering
- (void)filterContentForSearchText:(NSString*)searchText scope:(NSInteger)scope
{
    // update the filter, in this case just blow away the FRC and let lazy evaluation create another with the relevant search info
    self.searchFetchedResultsController.delegate = nil;
    self.searchFetchedResultsController = nil;
    // if you care about the scope save off the index to be used by the serchFetchedResultsController
    //self.savedScopeButtonIndex = scope;
}

@end
