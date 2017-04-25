//
//  TYDGeocodeAnnotation.h
//  DroiKids
//
//  Created by wangchao on 15/8/17.
//  Copyright (c) 2015年 superjunjun. All rights reserved.
//

#import <MAMapKit/MAMapKit.h>
#import <AMapSearchKit/AMapCommonObj.h>

@interface TYDGeocodeAnnotation : NSObject <MAAnnotation>

@property (nonatomic, readonly, strong) AMapGeocode *geocode;
@property (nonatomic, readonly) CLLocationCoordinate2D coordinate;

- (id)initWithGeocode:(AMapGeocode *)geocode;

/*!
 @brief 获取annotation标题
 @return 返回annotation的标题信息
 */
- (NSString *)title;

/*!
 @brief 获取annotation副标题
 @return 返回annotation的副标题信息
 */
- (NSString *)subtitle;

@end
