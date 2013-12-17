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
#import "Alarms.h"


@interface PTVAlarmDetailViewController ()
@property (weak, nonatomic) IBOutlet UILabel *uiname;
@property (weak, nonatomic) IBOutlet UILabel *uiaddress;
@property (weak, nonatomic) IBOutlet MKMapView *uiMapView;
@property (weak, nonatomic) IBOutlet UISwitch *setAlarm;
@property (strong,nonatomic) NSManagedObjectContext *managedObjectContext;
@property (strong,nonatomic) NSArray * result;
@property (weak, nonatomic) IBOutlet UIImageView *iconImgView;
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
                alarm.addDate=[NSDate date];
                alarm.lastUse=[NSDate date];
                alarm.toWhich=self.station;
                alarm.state=[NSNumber numberWithInt:ONSTATE];
                self.station.alarm=alarm;
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
    request.predicate=[NSPredicate predicateWithFormat:@"name=%@ AND address=%@",self.station.name,self.station.address];
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
    if (self.station.type.intValue==Train) {
        self.uiname.text=[self.station.name stringByAppendingString:@" Railway Station"];
    }
    else{
        self.uiname.text=self.station.name;
    }
    self.uiaddress.text=self.station.address;
    self.uiMapView.delegate=self;
    self.iconImgView.image=[UIImage imageNamed:[PTVAlarmDefine typeToImgFile:self.station.type.intValue]];
    [self setSwitchState];
    
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
    span.latitudeDelta = 0.005;
    span.longitudeDelta = 0.005;
    region.span = span;
    region.center = coordinate;
    [self.uiMapView setRegion:region animated:NO];
    
    
    
    
    //TODO: only listen to PTVAarmAlarmsViewController. Find a way to get the instance.
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(setSwitchState) name:NSManagedObjectContextObjectsDidChangeNotification object:nil];
}

@end
