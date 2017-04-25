//
//  TYDEnshrineLocationInfo.m
//  DroiKids
//
//  Created by macMini_Dev on 15/8/21.
//  Copyright (c) 2015年 superjunjun. All rights reserved.
//

#import "TYDEnshrineLocationInfo.h"

@implementation TYDEnshrineLocationInfo

- (NSDictionary *)attributeMapDictionary
{
    NSDictionary *mapDic =
    @{
        @"childid"                  :@"kidID",
        @"id"                       :@"locationID",
        @"address"                  :@"locationName",
        @"description"              :@"locationMemo",
        @"latitude"                 :@"locationLatitude",
        @"longitude"                :@"locationLongitude",
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
    self.locationName = [self stringValueFix:self.locationName];
    self.locationMemo = [self stringValueFix:self.locationMemo];
    self.locationLatitude = [self floatNumberValueFix:self.locationLatitude];
    self.locationLongitude = [self floatNumberValueFix:self.locationLongitude];
    self.infoCreateTime = [self integerNumberValueFix:self.infoCreateTime];
}

- (BOOL)isEqual:(TYDEnshrineLocationInfo *)object
{
    return [self.locationID isEqualToString:object.locationID];
}

- (BOOL)setAttributesWithObject:(TYDEnshrineLocationInfo *)object
{
    BOOL result = [super setAttributesWithObject:object];
    if(result)
    {
        //self.locationID = object.locationID;
        self.locationName = object.locationName;
        self.locationLatitude = object.locationLatitude;
        self.locationLongitude = object.locationLongitude;
        self.infoCreateTime = object.infoCreateTime;
    }
    return result;
}

@end
