//
//  PTVAlarmDetailViewController.m
//  PTV Alarm
//
//  Created by Kangbo Mo on 24/11/2013.
//  Copyright (c) 2013 Kangbo Mo. All rights reserved.
//

#import "PTVAlarmDetailViewController.h"
#import "PTVAlarmMapAnnotation.h"
#import "PTVAlarmAppDelegate.h"
#import "Stations.h"
#import "Alarms.h"

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
    if (!self.result||[self.result count]==0||!((Stations *)self.result[0]).alarm) {
        _isOn=FALSE;
    }
    else{
        _isOn= ((Stations*)self.result[0]).alarm.state==[NSNumber numberWithInt:ONSTATE]? true: false;
    }
    return _isOn;
}

- (IBAction)switchAction:(UISwitch *)sender{
    [self fetchResult];
    if (self.setAlarm.on) {
        //add this station to Alarms view. If existed, turn on this alarm.
        if (((Stations *)self.result[0]).alarm) {
            ((Stations *)self.result[0]).alarm.state=[NSNumber numberWithInt:ONSTATE];
        }
        else if (!((Stations *)self.result[0]).alarm){
            Alarms * alarm=[NSEntityDescription insertNewObjectForEntityForName:ENTITY_ALARM inManagedObjectContext:self.managedObjectContext];
//            alarm.address=self.address;
//            alarm.addDate=[NSDate date];
//            alarm.name=self.stationName;
//            alarm.longitude=self.longitude;
//            alarm.latitude=self.latitude;
//            alarm.lastUse=[NSDate date];
//            alarm.state=[NSNumber numberWithInt:ONSTATE];
//            alarm.type=[NSNumber numberWithInt:self.stationType];
//            alarm.address=self.station.address;
            alarm.addDate=[NSDate date];
//            alarm.name=self.station.name;
//            alarm.latitude=self.station.latitude;
//            alarm.longitude=self.station.longitude;
            alarm.lastUse=[NSDate date];
            alarm.toWhich=self.station;
            alarm.state=[NSNumber numberWithInt:ONSTATE];
            self.station.alarm=alarm;
            
//            alarm.type=self.station.type;
        }
        else{
            NSLog(@"Fail to add alarm");
        }
    }
    else{
        if ([self.result count]==0) {}
        else{
            ((Stations *)self.result[0]).alarm.state=[NSNumber numberWithInt:OFFSTATE];
        }
        //turn off this alarm.
    }
    [self.managedObjectContext save:nil];
    
}

//Fetch this station from stored alarms. May not exist.
- (void) fetchResult{
    PTVAlarmAppDelegate * delegate=[[UIApplication sharedApplication] delegate];
    self.managedObjectContext=delegate.managedObjectContext;
    NSFetchRequest * request=[NSFetchRequest fetchRequestWithEntityName:ENTITY_STATION];
    request.predicate=[NSPredicate predicateWithFormat:@"name=%@",self.station.name];
    self.result=[self.managedObjectContext executeFetchRequest:request error:nil];
}

- (void)setSwitchState{
    self.setAlarm.on=self.isOn;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    
    self.uiname.text=self.station.name;
    self.uiaddress.text=self.station.address;
    self.uiMapView.delegate=self;
    
    CLLocationCoordinate2D coordinate;
    coordinate.latitude=self.station.latitude.doubleValue;
    coordinate.longitude=self.station.longitude.doubleValue;
    PTVAlarmMapAnnotation * mapPin=[[PTVAlarmMapAnnotation alloc] init];
    mapPin.theCoordinate=coordinate;
    mapPin.name=[NSString stringWithFormat:@"%@ Station",self.station.name];
    mapPin.address=self.station.address;
    
    [self.uiMapView addAnnotation:mapPin];
    MKCoordinateRegion region;
    MKCoordinateSpan span;
    span.latitudeDelta = 0.003;
    span.longitudeDelta = 0.003;
    region.span = span;
    region.center = coordinate;
    [self.uiMapView setRegion:region animated:NO];
    
    [self setSwitchState];
    
    
    //Del in PTVAarmAlarmsViewController set the state OFF.
    //TODO: only listen to PTVAarmAlarmsViewController. Find a way to get the instance.
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(setSwitchState) name:NSManagedObjectContextObjectsDidChangeNotification object:nil];
}

@end
