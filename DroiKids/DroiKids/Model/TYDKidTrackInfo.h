//
//  TYDKidTrackInfo.h
//  DroiKids
//
//  Created by macMini_Dev on 15/8/21.
//  Copyright (c) 2015年 superjunjun. All rights reserved.
//

#import "TYDBaseModel.h"

@interface TYDKidTrackInfo : TYDBaseModel

@property (strong, nonatomic) NSString *kidID;
//@property (strong, nonatomic) NSString *trackID;
@property (strong, nonatomic) NSNumber *trackLatitude;
@property (strong, nonatomic) NSNumber *trackLongitude;
@property (strong, nonatomic) NSNumber *infoCreateTime;

@end
