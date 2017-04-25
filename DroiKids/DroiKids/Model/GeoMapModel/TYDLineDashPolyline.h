//
//  TYDLineDashPolyline.h
//  DroiKids
//
//  Created by wangchao on 15/8/17.
//  Copyright (c) 2015年 superjunjun. All rights reserved.
//

#import <MAMapKit/MAPolyline.h>
#import <MAMapKit/MAOverlay.h>

@interface TYDLineDashPolyline : NSObject <MAOverlay>

@property (nonatomic, readonly) CLLocationCoordinate2D coordinate;
@property (nonatomic, readonly) MAMapRect boundingMapRect;
@property (nonatomic, retain)  MAPolyline *polyline;

- (id)initWithPolyline:(MAPolyline *)polyline;

@end
