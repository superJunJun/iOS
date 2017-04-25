//
//  TYDEnshrineLocationInfo.h
//  DroiKids
//
//  Created by macMini_Dev on 15/8/21.
//  Copyright (c) 2015年 superjunjun. All rights reserved.
//
//  收藏地点
//

#import "TYDBaseModel.h"

@interface TYDEnshrineLocationInfo : TYDBaseModel

@property (strong, nonatomic) NSString *kidID;
@property (strong, nonatomic) NSString *locationID;
@property (strong, nonatomic) NSString *locationName;
@property (strong, nonatomic) NSString *locationMemo;//备注
@property (strong, nonatomic) NSNumber *locationLatitude;
@property (strong, nonatomic) NSNumber *locationLongitude;
@property (strong, nonatomic) NSNumber *infoCreateTime;

@end
