//
//  TYDMapCommonUtility.h
//  DroiKids
//
//  Created by wangchao on 15/8/17.
//  Copyright (c) 2015年 superjunjun. All rights reserved.
//

#import <MAMapKit/MAMapKit.h>
#import <AMapSearchKit/AMapSearchAPI.h>

@interface TYDMapCommonUtility : NSObject

+ (CLLocationCoordinate2D *)coordinatesForString:(NSString *)string
                                 coordinateCount:(NSUInteger *)coordinateCount
                                      parseToken:(NSString *)token;

+ (MAPolyline *)polylineForCoordinateString:(NSString *)coordinateString;
+ (MAPolyline *)polylineForStep:(AMapStep *)step;
+ (MAPolyline *)polylineForBusLine:(AMapBusLine *)busLine;

+ (NSArray *)polylinesForWalking:(AMapWalking *)walking;
+ (NSArray *)polylinesForSegment:(AMapSegment *)segment;
+ (NSArray *)polylinesForPath:(AMapPath *)path;
+ (NSArray *)polylinesForTransit:(AMapTransit *)transit;


+ (MAMapRect)unionMapRect1:(MAMapRect)mapRect1 mapRect2:(MAMapRect)mapRect2;
+ (MAMapRect)mapRectUnion:(MAMapRect *)mapRects count:(NSUInteger)count;
+ (MAMapRect)mapRectForOverlays:(NSArray *)overlays;

+ (MAMapRect)minMapRectForMapPoints:(MAMapPoint *)mapPoints count:(NSUInteger)count;
+ (MAMapRect)minMapRectForAnnotations:(NSArray *)annotations;


@end
