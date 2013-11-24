//
//  PTVAlarmViewController.m
//  PTV Alarm
//
//  Created by Kangbo Mo on 15/11/2013.
//  Copyright (c) 2013 Kangbo Mo. All rights reserved.
//

#import "PTVAlarmViewController.h"
#import "PTVAlarmStationViewController.h"
@interface PTVAlarmViewController ()

@end

@implementation PTVAlarmViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    PTVAlarmStationViewController *stationController=segue.destinationViewController;
    if ([segue.identifier isEqualToString:@"trainsegue"]) {
        stationController.filename= @"train1.csv";
        stationController.imgname=@"TrainIcon30px.gif";
    }
    if ([segue.identifier isEqualToString:@"tramsegue"]) {
        stationController.filename= @"train.csv";
        stationController.imgname=@"TramIcon30px.gif";
    }
    if ([segue.identifier isEqualToString:@"bussegue"]) {
        stationController.filename= @"train.csv";
        stationController.imgname=@"BusIcon30px.gif";
    }
}

@end
