//
//  TYDKidTrackInfo.m
//  DroiKids
//
//  Created by macMini_Dev on 15/8/21.
//  Copyright (c) 2015年 superjunjun. All rights reserved.
//

#import "TYDKidTrackInfo.h"

@implementation TYDKidTrackInfo

- (NSDictionary *)attributeMapDictionary
{
    NSDictionary *mapDic =
    @{
        @"childid"                  :@"kidID",
        @"latitude"                 :@"trackLatitude",
        @"longitude"                :@"trackLongitude",
        @"time"                     :@"infoCreateTime",
    };
    return mapDic;
}

- (void)setAttributes:(NSDictionary *)dataDic
{
    [super setAttributes:dataDic];
    [self attributeFix];
}

- (void)attributeFix
{
    self.kidID = [self stringValueFix:self.kidID];
    self.trackLatitude = [self floatNumberValueFix:self.trackLatitude];
    self.trackLongitude = [self floatNumberValueFix:self.trackLongitude];
    self.infoCreateTime = [self integerNumberValueFix:self.infoCreateTime];
}

- (BOOL)isEqual:(TYDKidTrackInfo *)object
{
//    return ([self.trackID isEqualToString:object.trackID]
//            && [self.infoCreateTime isEqualToNumber:object.infoCreateTime]);
    return [self.infoCreateTime isEqualToNumber:object.infoCreateTime];
}


@end
