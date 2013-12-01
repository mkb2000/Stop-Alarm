//
//  PTVAlarmDetailViewController.h
//  PTV Alarm
//
//  Created by Kangbo Mo on 24/11/2013.
//  Copyright (c) 2013 Kangbo Mo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "Stations.h"
@interface PTVAlarmDetailViewController : UIViewController <MKMapViewDelegate>
@property (nonatomic,strong) Stations* station;
@end
