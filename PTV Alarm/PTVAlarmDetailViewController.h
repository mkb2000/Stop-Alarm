//
//  PTVAlarmDetailViewController.h
//  PTV Alarm
//
//  Created by Kangbo Mo on 24/11/2013.
//  Copyright (c) 2013 Kangbo Mo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

@interface PTVAlarmDetailViewController : UIViewController <MKMapViewDelegate>
@property (nonatomic,strong) NSString * latitude;
@property (nonatomic,strong) NSString * longitude;
@property (nonatomic,strong) NSString * address;
@property (nonatomic,strong) NSString * stationName;
@property (nonatomic,strong) NSString * suburb;
@property int stationType;
@end
