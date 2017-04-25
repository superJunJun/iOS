//
//  TYDLineDashPolyline.m
//  DroiKids
//
//  Created by wangchao on 15/8/17.
//  Copyright (c) 2015年 superjunjun. All rights reserved.
//

#import "TYDLineDashPolyline.h"

@implementation TYDLineDashPolyline

- (id)initWithPolyline:(MAPolyline *)polyline
{
    self = [super init];
    if(self)
    {
        self.polyline = polyline;
    }
    return self;
}

- (CLLocationCoordinate2D) coordinate
{
    return [_polyline coordinate];
}

- (MAMapRect) boundingMapRect
{
    return [_polyline boundingMapRect];
}

@end
