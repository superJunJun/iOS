//
//  BOCoordinateTransformation.m
//  DroiKids
//
//  Created by superjunjun on 15/10/12.
//  Copyright © 2015年 TYDTech. All rights reserved.
//

#import "BOCoordinateTransformation.h"

double a = 6378245.0;
double ee = 0.00669342162296594323;

@implementation BOCoordinateTransformation

+ (CLLocationCoordinate2D)changeWGS84ToGcj02WithLatitude:(double )latitude withLongitude:(double )longitude
{
    //    if([self outOfChina:latitude withLongitude:longitude])
    //    {
    //        return NULL;
    //    }
    CLLocationCoordinate2D coord;
    double dLatitude = [self transformLatWithX:longitude - 105.0 WithY:(latitude - 35.0)];
    double dLongitude = [self transformLonWithX:longitude - 105.0 WithY:latitude - 35.0];
    double radLat = latitude / 180.0 * M_PI;
    double magic = sin(radLat);
    magic = 1 - ee * magic * magic;
    double sqrtMagic = sqrt(magic);
    dLatitude = (dLatitude * 180.0) / ((a * (1 - ee)) / (magic * sqrtMagic) * M_PI);
    dLongitude = (dLongitude * 180.0) / (a / sqrtMagic * cos(radLat) * M_PI);
    double mgLat = latitude + dLatitude;
    double mgLon = longitude + dLongitude;
    coord = CLLocationCoordinate2DMake(mgLat, mgLon);
    return coord;
}

- (BOOL)outOfChina:(double )latitude withLongitude:(double )longitude
{
    if((longitude < 72.004 || longitude > 137.8347) || (latitude < 0.8293 || latitude > 55.8271))
    {
        return YES;
    }
    else
    {
        return NO;
    }
}

+ (double)transformLatWithX:(double )x WithY:(double )y
{
    double ret = -100.0 + 2.0 * x + 3.0 * y + 0.2 * y * y + 0.1 * x * y
    + 0.2 * sqrt(fabs(x));
    ret += (20.0 * sin(6.0 * x * M_PI) + 20.0 * sin(2.0 * x * M_PI)) * 2.0 / 3.0;
    ret += (20.0 * sin(y * M_PI) + 40.0 * sin(y / 3.0 * M_PI)) * 2.0 / 3.0;
    ret += (160.0 * sin(y / 12.0 * M_PI) + 320 * sin(y * M_PI / 30.0)) * 2.0 / 3.0;
    return ret;
}

+ (double)transformLonWithX:(double )x WithY:(double )y
{
    double ret = 300.0 + x + 2.0 * y + 0.1 * x * x + 0.1 * x * y + 0.1
    * sqrt(fabs(x));
    ret += (20.0 * sin(6.0 * x * M_PI) + 20.0 * sin(2.0 * x * M_PI)) * 2.0 / 3.0;
    ret += (20.0 * sin(x * M_PI) + 40.0 * sin(x / 3.0 * M_PI)) * 2.0 / 3.0;
    ret += (150.0 * sin(x / 12.0 * M_PI) + 300.0 * sin(x / 30.0 * M_PI)) * 2.0 / 3.0;
    return ret;
}

+ (NSString *)changeGcj02ToWGS84WithLatitude:(double )latitude withLongitude:(double )longitude
{
//    CLLocationCoordinate2D coord;
    double dLat = [self transformLatWithX:longitude - 105.0 WithY:latitude - 35.0];
    double dLon = [self transformLonWithX:longitude - 105.0 WithY:latitude - 35.0];
    double radLat = latitude / 180.0 * M_PI;
    double magic = sin(radLat);
    magic = 1 - ee * magic * magic;
    double sqrtMagic = sqrt(magic);
    dLat = (dLat * 180.0) / ((a * (1 - ee)) / (magic * sqrtMagic) * M_PI);
    dLon = (dLon * 180.0) / (a / sqrtMagic * cos(radLat) * M_PI);
    double mgLat = latitude + dLat;
    double mgLon = longitude + dLon;
    
    return [NSString stringWithFormat:@"%f %f ",longitude * 2 - mgLon ,latitude * 2 - mgLat];
}


@end
