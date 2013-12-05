//
//  PTVAlarmSelectOnMapViewController.h
//  PTV Alarm
//
//  Created by Kangbo Mo on 15/11/2013.
//  Copyright (c) 2013 Kangbo Mo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

@interface PTVAlarmMapViewController : UIViewController <MKMapViewDelegate,CLLocationManagerDelegate>
@property (nonatomic,strong) IBOutlet MKMapView *mapView;
@end
