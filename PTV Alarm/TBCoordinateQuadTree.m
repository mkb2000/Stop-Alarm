//
//  TBCoordinateQuadTree.m
//  TBAnnotationClustering
//
//  Created by Theodore Calmes on 9/27/13.
//  Copyright (c) 2013 Theodore Calmes. All rights reserved.
//

#import "TBCoordinateQuadTree.h"
#import "TBClusterAnnotation.h"

typedef struct TBStationInfo {
    char* name;
    char* address;
} TBStationInfo;

TBQuadTreeNodeData TBDataFromLine(NSString *line)
{
    NSArray *components = [line componentsSeparatedByString:@";"];
    NSString * location=components[3];
    NSArray * loci=[location componentsSeparatedByString:@","];
    double latitude = [loci[0] doubleValue];
    double longitude = [loci[1] doubleValue];
    
    TBStationInfo* stopInfo = malloc(sizeof(TBStationInfo));
    
    NSString *name = [components[0] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    stopInfo->name = malloc(sizeof(char) * name.length + 1);
    strncpy(stopInfo->name, [name cStringUsingEncoding:NSMacOSRomanStringEncoding], name.length + 1);
    
    NSString *address = [components[2] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    stopInfo->address = malloc(sizeof(char) * address.length + 1);
    strncpy(stopInfo->address, [address cStringUsingEncoding:NSMacOSRomanStringEncoding], address.length + 1);
    
    return TBQuadTreeNodeDataMake(latitude, longitude, stopInfo);
}

TBBoundingBox TBBoundingBoxForMapRect(MKMapRect mapRect)
{
    CLLocationCoordinate2D topLeft = MKCoordinateForMapPoint(mapRect.origin);
    CLLocationCoordinate2D botRight = MKCoordinateForMapPoint(MKMapPointMake(MKMapRectGetMaxX(mapRect), MKMapRectGetMaxY(mapRect)));
    
    CLLocationDegrees minLat = botRight.latitude;
    CLLocationDegrees maxLat = topLeft.latitude;
    
    CLLocationDegrees minLon = topLeft.longitude;
    CLLocationDegrees maxLon = botRight.longitude;
    
    return TBBoundingBoxMake(minLat, minLon, maxLat, maxLon);
}

MKMapRect TBMapRectForBoundingBox(TBBoundingBox boundingBox)
{
    MKMapPoint topLeft = MKMapPointForCoordinate(CLLocationCoordinate2DMake(boundingBox.x0, boundingBox.y0));
    MKMapPoint botRight = MKMapPointForCoordinate(CLLocationCoordinate2DMake(boundingBox.xf, boundingBox.yf));
    
    return MKMapRectMake(topLeft.x, botRight.y, fabs(botRight.x - topLeft.x), fabs(botRight.y - topLeft.y));
}

NSInteger TBZoomScaleToZoomLevel(MKZoomScale scale)
{
    double totalTilesAtMaxZoom = MKMapSizeWorld.width / 256.0;
    NSInteger zoomLevelAtMaxZoom = log2(totalTilesAtMaxZoom);
    NSInteger zoomLevel = MAX(0, zoomLevelAtMaxZoom + floor(log2f(scale) + 0.5));
    
    return zoomLevel;
}

float TBCellSizeForZoomScale(MKZoomScale zoomScale)
{
    NSInteger zoomLevel = TBZoomScaleToZoomLevel(zoomScale);
    
    if (IS_DEBUG) {
        NSLog(@"zoomlevel: %ld",(long)zoomLevel);
    }
    
    //    if (zoomLevel<13) {
    //        return 96;
    //    }
    //    else{
    //        return 64;
    //    }
    
    switch (zoomLevel) {
        case 13:
            return 64;
        case 14:
            
        case 15:
            return 32;
        case 16:
            
        case 17:
        case 18:
            
        case 19:
            return 16;
            
        default:
            return 88;
    }
}

@interface TBCoordinateQuadTree()
{
    TBQuadTreeNode * cachedRoots[4];
}
@property (nonatomic,strong) NSMutableDictionary * cachedFiles;//{"filename":indexIncachedRoots}
//@property (nonatomic) TBQuadTreeNode * cachedRoots[4];//pointers to cached tree roots
@end

@implementation TBCoordinateQuadTree

- (NSMutableDictionary *) cachedFiles{
    if (!_cachedFiles) {
        _cachedFiles=[NSMutableDictionary dictionary];
    }
    return _cachedFiles;
}

//- (TBQuadTreeNode **) cachedRoots{
//    if (!_cachedRoots) {
//        _cachedRoots=malloc(sizeof(TBQuadTreeNode *)*4);
//    }
//    return _cachedRoots;
//}

- (void)buildTreeWithFile:(NSString *)filename
{
    @autoreleasepool {
        if (!filename||[filename isEqual:@""]) {
            _root=nil;
            return;
        }
        NSNumber *ind=[self.cachedFiles objectForKey:filename];
        if (ind) {
            if (IS_DEBUG) {
                NSLog(@"%@ from cache",filename);
            }
            _root= cachedRoots[[ind intValue]-1];
        }
        else{
            if (IS_DEBUG) {
                NSLog(@"%@ from file",filename);
            }
            
            NSString *data = [NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:filename ofType:@""] encoding:NSMacOSRomanStringEncoding error:nil];
            NSArray *lines = [data componentsSeparatedByString:@"\n"];
            
            NSInteger count = lines.count - 1;
            
            TBQuadTreeNodeData *dataArray = malloc(sizeof(TBQuadTreeNodeData) * count);
            for (NSInteger i = 0; i < count; i++) {
                dataArray[i] = TBDataFromLine(lines[i]);
            }
            
            TBBoundingBox world = TBBoundingBoxMake(-40,133,-22,153); // (botright.lat,topleft.lon,topleft.lat,botright.lon) the bound within which the nodes located. The nodes outside this bound will not be searchable.
            
            _root = TBQuadTreeBuildWithData(dataArray, (int)count, world, 4);
            
            cachedRoots[[self.cachedFiles count]]=_root;
            [self.cachedFiles setObject:[NSNumber numberWithInt:(int)[self.cachedFiles count]+1] forKey:filename];
        }
    }
}

// cache this file for later use.
- (void) prepareTreeWithFile:(NSString *)filename{
    if (filename) {
        NSNumber *ind=[self.cachedFiles objectForKey:filename];
        if (!ind) {
            NSString *data = [NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:filename ofType:@""] encoding:NSMacOSRomanStringEncoding error:nil];
            NSArray *lines = [data componentsSeparatedByString:@"\n"];
            
            NSInteger count = lines.count - 1;
            
            TBQuadTreeNodeData *dataArray = malloc(sizeof(TBQuadTreeNodeData) * count);
            for (NSInteger i = 0; i < count; i++) {
                dataArray[i] = TBDataFromLine(lines[i]);
            }
            
            TBBoundingBox world = TBBoundingBoxMake(-40,133,-22,153); // (botright.lat,topleft.lon,topleft.lat,botright.lon) the bound of "world" within which annotations located. The annotations outside this bound will not be searchable.
            
            TBQuadTreeNode* tempRoot = TBQuadTreeBuildWithData(dataArray, (int)count, world, 4);
            cachedRoots[[self.cachedFiles count]]=tempRoot;
            [self.cachedFiles setObject:[NSNumber numberWithInt:(int)[self.cachedFiles count]+1] forKey:filename];
            tempRoot=nil;
            if (IS_DEBUG) {
                NSLog(@"builded tree for %@ file",filename);
            }
        }
        else{
            if (IS_DEBUG) {
                NSLog(@"%@ tree exists in cache",filename);
            }
        }
    }
}

-(void) clearCache{
    for (int i=0; i<[self.cachedFiles count]; i++) {
        cachedRoots[i]=nil;
    }
    self.cachedFiles=nil;
}

/*
- (void)buildTreeWithFile:(NSString *)filename
{
    @autoreleasepool {
        NSString *data = [NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:filename ofType:@""] encoding:NSMacOSRomanStringEncoding error:nil];
        NSArray *lines = [data componentsSeparatedByString:@"\n"];
        
        NSInteger count = lines.count - 1;
        
        TBQuadTreeNodeData *dataArray = malloc(sizeof(TBQuadTreeNodeData) * count);
        for (NSInteger i = 0; i < count; i++) {
            dataArray[i] = TBDataFromLine(lines[i]);
        }
        
        TBBoundingBox world = TBBoundingBoxMake(-40,133,-22,153); // (botright.lat,topleft.lon,topleft.lat,botright.lon) the bound within which the nodes located. The nodes outside this bound will not be searchable.
        _root = TBQuadTreeBuildWithData(dataArray, (int)count, world, 4);
    }
}
 */
- (NSArray *)clusteredAnnotationsWithinMapRect:(MKMapRect)rect withZoomScale:(double)zoomScale
{
    if (!self.root) {
        return nil;
    }
    double TBCellSize = TBCellSizeForZoomScale(zoomScale);
    double scaleFactor =zoomScale / TBCellSize*2;
    
    NSInteger minX = floor(MKMapRectGetMinX(rect) * scaleFactor);
    NSInteger maxX = floor(MKMapRectGetMaxX(rect) * scaleFactor);
    NSInteger minY = floor(MKMapRectGetMinY(rect) * scaleFactor);
    NSInteger maxY = floor(MKMapRectGetMaxY(rect) * scaleFactor);
    
    NSMutableArray *clusteredAnnotations = [[NSMutableArray alloc] init];
    for (NSInteger x = minX; x <= maxX; x++) {
        for (NSInteger y = minY; y <= maxY; y++) {
            MKMapRect mapRect = MKMapRectMake(x / scaleFactor, y / scaleFactor, 1.0 / scaleFactor, 1.0 / scaleFactor);
            
            __block double totalX = 0;
            __block double totalY = 0;
            __block int count = 0;
            
            NSMutableArray *names = [[NSMutableArray alloc] init];
            NSMutableArray *phoneNumbers = [[NSMutableArray alloc] init];
            NSMutableArray *xs=[NSMutableArray array];
            NSMutableArray *ys=[NSMutableArray array];
            
            TBQuadTreeGatherDataInRange(self.root, TBBoundingBoxForMapRect(mapRect), ^(TBQuadTreeNodeData data) {
                totalX += data.x;
                totalY += data.y;
                count++;
                [xs addObject:[NSNumber numberWithDouble:data.x]];
                [ys addObject:[NSNumber numberWithDouble:data.y]];
                
                TBStationInfo stationInfo = *(TBStationInfo *)data.data;
                [names addObject:[NSString stringWithFormat:@"%s", stationInfo.name]];
                [phoneNumbers addObject:[NSString stringWithFormat:@"%s", stationInfo.address]];
            });
            
            //            for (int i=0; i<count; i++) {
            //                CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake([[xs objectAtIndex:i] doubleValue], [[ys objectAtIndex:i] doubleValue]);
            //                TBClusterAnnotation *annotation = [[TBClusterAnnotation alloc] initWithCoordinate:coordinate count:1];
            //                annotation.title = [names objectAtIndex:i];
            //                annotation.subtitle = [phoneNumbers objectAtIndex:i];
            //                [clusteredAnnotations addObject:annotation];
            //            }
            
            if (count == 1) {
                CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake(totalX, totalY);
                TBClusterAnnotation *annotation = [[TBClusterAnnotation alloc] initWithCoordinate:coordinate count:count];
                annotation.title = [names lastObject];
                annotation.subtitle = [phoneNumbers lastObject];
                [clusteredAnnotations addObject:annotation];
            }
            
            if (count > 1) {
                //                CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake(totalX / count, totalY / count);
                CLLocationCoordinate2D coordinate=CLLocationCoordinate2DMake([[xs objectAtIndex:count/2] doubleValue], [[ys objectAtIndex:count/2] doubleValue]);
                TBClusterAnnotation *annotation = [[TBClusterAnnotation alloc] initWithCoordinate:coordinate count:count];
                [clusteredAnnotations addObject:annotation];
            }
        }
    }
    
    return [NSArray arrayWithArray:clusteredAnnotations];
}

@end
