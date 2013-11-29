//
//  PTVAlarmMapAnnotation.m
//  PTV Alarm
//
//  Created by Kangbo Mo on 25/11/2013.
//  Copyright (c) 2013 Kangbo Mo. All rights reserved.
//

#import "PTVAlarmMapAnnotation.h"

@interface PTVAlarmMapAnnotation()


@end


@implementation PTVAlarmMapAnnotation

- (NSString *)title {
    return _name;
}

- (NSString *)subtitle {
    return _address;
}

- (CLLocationCoordinate2D)coordinate {
    return _theCoordinate;
}



@end

