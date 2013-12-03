//
//  PTVAlarmSelectOnMapViewController.m
//  PTV Alarm
//
//  Created by Kangbo Mo on 15/11/2013.
//  Copyright (c) 2013 Kangbo Mo. All rights reserved.
//

#import "PTVAlarmMapViewController.h"

@interface PTVAlarmMapViewController ()

@end

@implementation PTVAlarmMapViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.mapView.delegate=self;
	// Do any additional setup after loading the view.
    self.mapView.showsUserLocation=YES;
    
    CLLocationCoordinate2D centre;
    centre.latitude=-37.899382;
    centre.longitude=144.661116;
    MKCircle * region=[MKCircle circleWithCenterCoordinate:centre radius:300];
    [self.mapView addOverlay:region];
    
    MKCoordinateRegion r;
    MKCoordinateSpan span;
    span.latitudeDelta = 0.03;
    span.longitudeDelta = 0.03;
    r.span = span;
    CLLocationCoordinate2D c;
    c.longitude=144.676723;
    c.latitude=-37.893212;
    r.center = c;
    [self.mapView setRegion:r animated:NO];
//    [self.mapView setCenterCoordinate:self.mapView.userLocation.location.coordinate animated:YES];
}
- (MKOverlayView *)mapView:(MKMapView *)mapView viewForOverlay:(id
                                                                <MKOverlay>)overlay
{
    if ([overlay isKindOfClass:[MKCircle class]])
    {
        MKCircleView*    aView = [[MKCircleView alloc] initWithCircle:(MKCircle *)overlay ];
        aView.fillColor = [[UIColor cyanColor] colorWithAlphaComponent:0.2];
        aView.strokeColor = [[UIColor blueColor] colorWithAlphaComponent:0.7];
        aView.lineWidth = 3;
        return aView;
    }
    return nil; }

@end
