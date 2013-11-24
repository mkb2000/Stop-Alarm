//
//  PTVAlarmSelectFromStationViewController.m
//  PTV Alarm
//
//  Created by Kangbo Mo on 15/11/2013.
//  Copyright (c) 2013 Kangbo Mo. All rights reserved.
//

#import "PTVAlarmStationViewController.h"

@interface PTVAlarmStationViewController ()
@property (strong,nonatomic) NSMutableDictionary *stationdic; //stationName : stationInfo
@property (strong,nonatomic) NSMutableDictionary *alphaToStations;// 'alpha': list of stations whose name started with 'alpha'
@property (strong,atomic) NSArray * sortedAlpha;
@property (strong,atomic) NSArray * sortedkeysINstationdic;
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


- (NSComparisonResult) singleAlphaCompare:(id) obj1 with: (id) obj2{
    if ([obj1[0] isEqual:@""]) {
        return (NSComparisonResult)NSOrderedAscending;
    }
    else if([obj2[0] isEqual:@""]) {
        return (NSComparisonResult)NSOrderedDescending;
    }
    else{
        char a=[(NSString *)((NSArray *) obj1[0]) characterAtIndex:0];
        char b=[(NSString *)((NSArray *) obj2[0]) characterAtIndex:0];
        if (a>b) {
            return (NSComparisonResult)NSOrderedDescending;
        }
        
        if (a<b) {
            return (NSComparisonResult)NSOrderedAscending;
        }
        return (NSComparisonResult)NSOrderedSame;
    }}

//
- (void)initDataWithFile{
    NSString * fpath=self.filename;
    self.stationdic=[[NSMutableDictionary alloc] init];
    self.alphaToStations=[[NSMutableDictionary alloc] init];
    NSFileManager *filem=[NSFileManager defaultManager];
    
    //read file into dictionaries.
    NSString *filepath=[[NSBundle mainBundle] pathForResource:fpath ofType:@""];
    if ([filem fileExistsAtPath:filepath]) {
        NSString *filestr=[NSString stringWithContentsOfFile:filepath encoding:NSUTF8StringEncoding error:nil];
        NSArray *stations=[filestr componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]];
        for (NSString *station in stations) {
            NSArray *parts=[station componentsSeparatedByString:@";"];
            self.stationdic[parts[0]]=parts;
        }
        self.sortedkeysINstationdic=[self.stationdic keysSortedByValueUsingComparator:^(id obj1, id obj2) {
            if ([obj1[0] isEqual:@""]) {
                return (NSComparisonResult)NSOrderedAscending;
            }
            else if([obj2[0] isEqual:@""]) {
                return (NSComparisonResult)NSOrderedDescending;
            }
            else{
                char a=[(NSString *)((NSArray *) obj1[0]) characterAtIndex:0];
                char b=[(NSString *)((NSArray *) obj2[0]) characterAtIndex:0];
                if (a>b) {
                    return (NSComparisonResult)NSOrderedDescending;
                }
                
                if (a<b) {
                    return (NSComparisonResult)NSOrderedAscending;
                }
                return (NSComparisonResult)NSOrderedSame;
            }}];
        
        char f='A';
        NSMutableArray *tma=[[NSMutableArray alloc] init];
        for (NSString *k in self.sortedkeysINstationdic) {
            if ([k isEqual:@""]) {
                continue;
            }
            if ([k characterAtIndex:0]!=f) {
                [self.alphaToStations setObject:tma forKey:[NSString stringWithFormat:@"%c",f]];
                tma=[[NSMutableArray alloc]init];
                f=[k characterAtIndex:0];
            }
            [tma addObject:self.stationdic[k]];
        }
        
        self.sortedAlpha=[self.alphaToStations keysSortedByValueUsingComparator:^(id obj1, id obj2) {
            if ([obj1[0] isEqual:@""]) {
                return (NSComparisonResult)NSOrderedAscending;
            }
            else if([obj2[0] isEqual:@""]) {
                return (NSComparisonResult)NSOrderedDescending;
            }
            else{
                char a=[(NSString *)((NSArray *) obj1[0][0]) characterAtIndex:0];
                char b=[(NSString *)((NSArray *) obj2[0][0]) characterAtIndex:0];
                if (a>b) {
                    return (NSComparisonResult)NSOrderedDescending;
                }
                
                if (a<b) {
                    return (NSComparisonResult)NSOrderedAscending;
                }
                return (NSComparisonResult)NSOrderedSame;
            }}];
    }
    else{
        NSLog(@"file doesn't exist!");
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self initDataWithFile];
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

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return [self.alphaToStations count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [self.alphaToStations[self.sortedAlpha[section]] count];
}

- (NSArray *)statioAtRow:(NSInteger) row andSection:(NSInteger) section{
    NSArray *re=self.alphaToStations[self.sortedAlpha[section]][row];
    return re;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"stationCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    NSArray * stationInfo=[self statioAtRow:indexPath.row andSection:indexPath.section];
    cell.textLabel.text=stationInfo[0];
    cell.detailTextLabel.text=stationInfo[1];
    
    UIImage * img=[UIImage imageNamed:self.imgname];
    cell.imageView.image=img;
    //    NSLog(@"%d,%d",indexPath.row,indexPath.section);
    
    //    cell.textLabel.text=
    // Configure the cell...
    
    return cell;
}

- (NSArray *) sectionIndexTitlesForTableView:(UITableView *)tableView{
    return self.sortedAlpha;
}

- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index{
    return [self.sortedAlpha indexOfObject:title];
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

/*
#pragma mark - Navigation

// In a story board-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if ([segue.identifier isEqualToString:@"trainsegue"]) {
        [self initDataWithFile:@"train1.csv"];
        self.imgname=@"TrainIcon30px.gif";
    }
    if ([segue.identifier isEqualToString:@"tramsegue"]) {
        [self initDataWithFile:@"train.csv"];
        self.imgname=@"TramIcon30px.gif";
    }
    if ([segue.identifier isEqualToString:@"bussegue"]) {
        [self initDataWithFile:@"train.csv"];
        self.imgname=@"BusIcon30px.gif";
    }
}
*/


@end
