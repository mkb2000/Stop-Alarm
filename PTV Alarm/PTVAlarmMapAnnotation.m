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
- (NSUInteger)hash
{
    NSString *toHash = [NSString stringWithFormat:@"%@%@%.5F%.5F",self.title,self.subtitle, self.coordinate.latitude, self.coordinate.longitude];
    return [toHash hash];
}

- (BOOL)isEqual:(id)object
{
    return [self hash] == [object hash];
}


@end

