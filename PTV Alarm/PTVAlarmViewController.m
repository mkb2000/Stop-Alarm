//
//  PTVAlarmViewController.m
//  PTV Alarm
//
//  Created by Kangbo Mo on 15/11/2013.
//  Copyright (c) 2013 Kangbo Mo. All rights reserved.
//

#import "PTVAlarmViewController.h"
#import "PTVAlarmStationViewController.h"
#import "PTVAlarmAppDelegate.h"

@interface PTVAlarmViewController ()

@end

@implementation PTVAlarmViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
//    self.tableView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"train_metro_trans.png"]];
	// Do any additional setup after loading the view, typically from a nib.
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    PTVAlarmStationViewController *stationController=segue.destinationViewController;
    if ([segue.identifier isEqualToString:@"trainsegue"]) {
        stationController.imgname=ICON_TRAIN;
        stationController.stationType=Train;
    }
    if ([segue.identifier isEqualToString:@"tramsegue"]) {
        stationController.imgname=ICON_TRAM;
        stationController.stationType=Tram;
    }
    if ([segue.identifier isEqualToString:@"bussegue"]) {
        stationController.imgname=ICON_METROBUS;
        stationController.stationType=Bus;
    }
    if ([segue.identifier isEqualToString:@"vlinesegue"]) {
        stationController.imgname=ICON_VLINE;
        stationController.stationType=Vline;
    }
}

@end
