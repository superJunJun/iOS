//
//  BOCoordinateTransformation.h
//  DroiKids
//
//  Created by superjunjun on 15/10/12.
//  Copyright © 2015年 TYDTech. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@interface BOCoordinateTransformation : NSObject

+ (CLLocationCoordinate2D)changeWGS84ToGcj02WithLatitude:(double )latitude withLongitude:(double )longitude;

+ (NSString *)changeGcj02ToWGS84WithLatitude:(double )latitude withLongitude:(double )longitude;

@end
