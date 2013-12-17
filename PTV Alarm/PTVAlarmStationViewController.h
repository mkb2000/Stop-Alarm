//
//  PTVAlarmSelectFromStationViewController.h
//  PTV Alarm
//
//  Created by Kangbo Mo on 15/11/2013.
//  Copyright (c) 2013 Kangbo Mo. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PTVAlarmStationViewController : UITableViewController <NSFetchedResultsControllerDelegate,UISearchBarDelegate,UISearchDisplayDelegate>
@property (strong,nonatomic) NSString * imgname;
@property TransportType stationType;
@end
