//
//  TYDGeocodeAnnotation.m
//  DroiKids
//
//  Created by wangchao on 15/8/17.
//  Copyright (c) 2015年 superjunjun. All rights reserved.
//

#import "TYDGeocodeAnnotation.h"

@interface TYDGeocodeAnnotation ()

@property (nonatomic, readwrite, strong) AMapGeocode *geocode;

@end

@implementation TYDGeocodeAnnotation

#pragma mark - MAAnnotation Protocol

- (NSString *)title
{
    return self.geocode.formattedAddress;
}

- (NSString *)subtitle
{
    return [self.geocode.location description];
}

- (CLLocationCoordinate2D)coordinate
{
    return CLLocationCoordinate2DMake(self.geocode.location.latitude, self.geocode.location.longitude);
}

#pragma mark - Life Cycle

- (id)initWithGeocode:(AMapGeocode *)geocode
{
    if(self = [super init])
    {
        self.geocode = geocode;
    }
    
    return self;
}
@end
