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

@property (nonatomic, copy) dispatch_queue_t queue;
@property (nonatomic,strong) NSFetchedResultsController* fetchedResultsController;
@property (nonatomic,strong)PTVAlarmAppDelegate * appdelegate;
@property (nonatomic) BOOL searching;
@property (nonatomic,strong) NSArray * searchResultArray;
@property (nonatomic,strong) NSMutableArray * actionbuck;
@property (nonatomic) BOOL doing;
@end

@implementation PTVAlarmStationViewController

- (BOOL) doing{
    if (!_doing) {
        _doing=false;
    }
    return _doing;
}

- (NSMutableArray *) actionbuck{
    if (!_actionbuck) {
        _actionbuck=[NSMutableArray array];
    }
    return _actionbuck;
}

-(dispatch_queue_t) queue{
    if (!_queue) {
        _queue = dispatch_queue_create("com.ptvalarm.searchFilter", DISPATCH_QUEUE_SERIAL);
    }
    return _queue;
}

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
    //    self.searchFetchedResultsController=nil;
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
    [fetchRequest setFetchBatchSize:0];
    
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES];
    NSSortDescriptor *initDescriptor=[[NSSortDescriptor alloc] initWithKey:@"initial" ascending:YES];
    [fetchRequest setSortDescriptors:@[sortDescriptor, initDescriptor]];
    _fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
                                                                    managedObjectContext:self.appdelegate.managedObjectContext
                                                                      sectionNameKeyPath:@"initial"
                                                                               cacheName:[NSString stringWithFormat:@"fetchResultCache%d",self.stationType]];
    _fetchedResultsController.delegate = self;
    
    
    return _fetchedResultsController;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (self.searching) {
        return 1;
    }
    // Return the number of sections.
    NSInteger n=[[self.fetchedResultsController sections] count];
    return n;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    
    if (self.searching) {
        return  [self.searchResultArray count];
    }
    
    // Return the number of rows in the section.
    NSInteger numberOfRows = 0;
    NSArray *sections = self.fetchedResultsController.sections;
    if(sections.count > 0)
    {
        id <NSFetchedResultsSectionInfo> sectionInfo = [sections objectAtIndex:section];
        numberOfRows = [sectionInfo numberOfObjects];
    }
    
    return numberOfRows;
}

- (void)fetchedResultsController:(NSFetchedResultsController *)fetchedResultsController configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    Stations * stationInfo;
    if (self.searching) {
        stationInfo=[self.searchResultArray objectAtIndex:indexPath.row];
    }
    else{
        stationInfo=[fetchedResultsController objectAtIndexPath:indexPath];
    }
    
    // configure cell
    //    Stations * stationInfo=[fetchedResultsController objectAtIndexPath:indexPath];
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
    
    [self fetchedResultsController:self.fetchedResultsController configureCell:cell atIndexPath:indexPath];
    
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (self.searching) {
        return Nil;
    }
    NSFetchedResultsController * frc=self.fetchedResultsController;
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
        Stations * station;
        if (self.searching) {
            station=[self.searchResultArray objectAtIndex:index.row];
        }
        else{
            station=[self.fetchedResultsController objectAtIndexPath:index];
        }
        dvController.station=station;
    }
}


#pragma mark -
#pragma mark Search Bar
- (void)searchDisplayControllerDidEndSearch:(UISearchDisplayController *)controller{
    if (IS_DEBUG) {
        NSLog(@"finish searching");
    }
    self.searching=false;
    [self.tableView reloadData];
    self.searchResultArray=nil;
    //    self.queue=Nil;
}
- (void) searchDisplayControllerWillBeginSearch:(UISearchDisplayController *)controller{
    self.searching=true;
    if (IS_DEBUG) {
        NSLog(@"will begin search");
    }
}

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString
{
    [self filterContentForSearchText:searchString scope:[self.searchDisplayController.searchBar selectedScopeButtonIndex]];
    
    // Return YES to cause the search result table view to be reloaded.
    return NO;
}

#pragma mark Content fetching
/**
 During typing, a new searching action may called before the previous finish. Thus, put all actions in a bucket,
 only execute the last action in the bucket.
 */
- (void)filterContentForSearchText:(NSString*)searchText scope:(NSInteger)scope
{
    NSString * st=[searchText stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    [self.actionbuck addObject:st];
    if (!self.doing) {
        [self executeAction];
    }
    else{
        if ([self.actionbuck count]>1) {
            self.actionbuck=[NSMutableArray arrayWithObject:[self.actionbuck lastObject]];
        }
    }
}

- (void) executeAction{
    self.doing=true;
    NSString * str=[self.actionbuck objectAtIndex:0];
    if (str) {
        [self.actionbuck removeObjectAtIndex:0];
    }
    NSPredicate * searchPred=[NSPredicate predicateWithFormat:@"(name CONTAINS[cd] %@) OR (address CONTAINS[cd] %@)",str,str];
    NSArray *fetchedobj=self.fetchedResultsController.fetchedObjects;
    dispatch_queue_t q= dispatch_queue_create("com.ptvalarm.searchFilter", DISPATCH_QUEUE_SERIAL);
    dispatch_async(q, ^{
        self.searchResultArray=[fetchedobj filteredArrayUsingPredicate:searchPred];
        dispatch_async(dispatch_get_main_queue(), ^{
//            @synchronized(fetchedobj){
                [self.searchDisplayController.searchResultsTableView reloadData];
                [self nextAction];
//            }
            //if reloadData performs slowly, and meanwhile cacheArray's content been changed, it is possible to cause err.
        });
    });
}
- (void) nextAction{
    NSUInteger l=[self.actionbuck count];
    switch (l) {
        case 0:
            self.doing=false;
            break;
        case 1:
            [self executeAction];
            break;
        default:
            self.actionbuck=[NSMutableArray arrayWithObject:[self.actionbuck lastObject]];
            [self executeAction];
            break;
    }
}

@end
