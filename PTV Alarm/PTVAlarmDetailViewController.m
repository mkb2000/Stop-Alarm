//
//  PTVAlarmDetailViewController.m
//  PTV Alarm
//
//  Created by Kangbo Mo on 24/11/2013.
//  Copyright (c) 2013 Kangbo Mo. All rights reserved.
//

#import "PTVAlarmDetailViewController.h"
#import "PTVAlarmMapAnnotation.h"
#import "Alarms+Alarm.h"
#import "PTVAlarmAppDelegate.h"


@interface PTVAlarmDetailViewController ()
@property (weak, nonatomic) IBOutlet UILabel *uiname;
@property (weak, nonatomic) IBOutlet UILabel *uiaddress;
@property (weak, nonatomic) IBOutlet MKMapView *uiMapView;
@property (weak, nonatomic) IBOutlet UISwitch *setAlarm;
@property (strong) NSManagedObjectContext *managedObjectContext;
@property (strong,nonatomic) NSArray * result;
@property (nonatomic) BOOL isOn;
@end

@implementation PTVAlarmDetailViewController

- (BOOL)isOn{
    [self fetchResult];
    if (!self.result||[self.result count]==0) {
        _isOn=FALSE;
    }
    else{
        _isOn= ((Alarms*)self.result[0]).state==[NSNumber numberWithInt:ONSTATE]? true: false;
    }
    return _isOn;
}

- (IBAction)switchAction:(UISwitch *)sender{
    
    if (self.setAlarm.on) {
        //add this station to Alarms view. If existed, turn on this alarm.
        if ([self.result count]==1) {
            ((Alarms *)self.result[0]).state=[NSNumber numberWithInt:ONSTATE];
        }
        else if ([self.result count]==0){
            Alarms * alarm=[NSEntityDescription insertNewObjectForEntityForName:@"Alarms" inManagedObjectContext:self.managedObjectContext];
            alarm.address=self.address;
            alarm.addDate=[NSDate date];
            alarm.name=self.stationName;
            alarm.longitude=self.longitude;
            alarm.latitude=self.latitude;
            alarm.lastUse=[NSDate date];
            alarm.state=[NSNumber numberWithInt:ONSTATE];
            [self.managedObjectContext save:nil];
        }
        else{
            NSLog(@"Fail to add alarm");
        }
    }
    else{
        if ([self.result count]==0) {
            
        }
        else{
            ((Alarms *)self.result[0]).state=[NSNumber numberWithInt:OFFSTATE];
            [self.managedObjectContext save:nil];
        }
        //turn off this alarm.
    }
    [self fetchResult];
}

- (void) fetchResult{
    PTVAlarmAppDelegate * delegate=[[UIApplication sharedApplication] delegate];
    self.managedObjectContext=delegate.managedObjectContext;
    NSFetchRequest * request=[NSFetchRequest fetchRequestWithEntityName:ALARMSFILE];
    request.predicate=[NSPredicate predicateWithFormat:@"name=%@",self.stationName];
    self.result=[self.managedObjectContext executeFetchRequest:request error:nil];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    
    self.uiname.text=self.stationName;
    self.uiaddress.text=self.address;
    self.uiMapView.delegate=self;
    
    CLLocationCoordinate2D coordinate;
    coordinate.latitude=self.latitude.doubleValue;
    coordinate.longitude=self.longitude.doubleValue;
    PTVAlarmMapAnnotation * mapPin=[[PTVAlarmMapAnnotation alloc] init];
    mapPin.theCoordinate=coordinate;
    mapPin.name=[NSString stringWithFormat:@"%@ Station",self.stationName];
    mapPin.address=self.address;
    
    [self.uiMapView addAnnotation:mapPin];
    MKCoordinateRegion region;
    MKCoordinateSpan span;
    span.latitudeDelta = 0.003;
    span.longitudeDelta = 0.003;
    region.span = span;
    region.center = coordinate;
    [self.uiMapView setRegion:region animated:NO];
    
    self.setAlarm.on=self.isOn;
}

@end
