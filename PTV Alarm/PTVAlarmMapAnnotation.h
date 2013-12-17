//
//  PTVAlarmMapAnnotation.h
//  PTV Alarm
//
//  Created by Kangbo Mo on 25/11/2013.
//  Copyright (c) 2013 Kangbo Mo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface PTVAlarmMapAnnotation : NSObject   <MKAnnotation>
@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *address;
@property (nonatomic, assign) CLLocationCoordinate2D theCoordinate;

@end
