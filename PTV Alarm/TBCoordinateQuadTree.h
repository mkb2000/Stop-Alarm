//
//  TBCoordinateQuadTree.h
//  TBAnnotationClustering
//
//  Created by Theodore Calmes on 9/27/13.
//  Copyright (c) 2013 Theodore Calmes. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TBQuadTree.h"
#import <MapKit/MapKit.h>

@interface TBCoordinateQuadTree : NSObject

@property (assign, nonatomic) TBQuadTreeNode* root;
//@property (strong, nonatomic) MKMapView *mapView;

- (void)buildTreeWithFile:(NSString *) filename;
- (void)prepareTreeWithFile:(NSString *) filename;
- (NSArray *)clusteredAnnotationsWithinMapRect:(MKMapRect)rect withZoomScale:(double)zoomScale;
- (void)clearCache;
@end
