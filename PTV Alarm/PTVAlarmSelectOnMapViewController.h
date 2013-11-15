//
//  PTVAlarmSelectOnMapViewController.h
//  PTV Alarm
//
//  Created by Kangbo Mo on 15/11/2013.
//  Copyright (c) 2013 Kangbo Mo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

@interface PTVAlarmSelectOnMapViewController : UIViewController <MKMapViewDelegate>
@property (nonatomic,strong) IBOutlet MKMapView *selectOnMapView;
@end
