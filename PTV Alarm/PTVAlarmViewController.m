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
@property (weak, nonatomic) IBOutlet UITextView *textfield;

@end

@implementation PTVAlarmViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    PTVAlarmAppDelegate *dele=[[UIApplication sharedApplication] delegate];
    dele.ptvalarmmanager.delegate=self;
}

- (void) updateTextField:(NSString *)str{
    str=[str stringByAppendingString:@"\n"];
    self.textfield.text=[self.textfield.text stringByAppendingString:str];
    
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
        stationController.imgname=IMG_TRAIN;
        stationController.stationType=Train;
    }
    if ([segue.identifier isEqualToString:@"tramsegue"]) {
        stationController.imgname=IMG_TRAM;
        stationController.stationType=Tram;
    }
    if ([segue.identifier isEqualToString:@"bussegue"]) {
        stationController.imgname=IMG_METROBUS;
        stationController.stationType=Bus;
    }
}

@end
