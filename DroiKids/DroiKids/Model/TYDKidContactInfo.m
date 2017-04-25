//
//  TYDKidContactInfo.m
//  DroiKids
//
//  Created by macMini_Dev on 15/8/21.
//  Copyright (c) 2015年 superjunjun. All rights reserved.
//

#import "TYDKidContactInfo.h"

@implementation TYDKidContactInfo

- (NSDictionary *)attributeMapDictionary
{
    NSDictionary *mapDic =
    @{
        @"id"                       :@"contactID",
        @"contactID"                :@"contactOpenID",
        @"kidID"                    :@"kidID",
        @"contactNumber"            :@"contactNumber",
        @"shortNumber"              :@"shortNumber",
        @"contactType"              :@"contactType",
        @"contactName"              :@"contactName",
        @"imgid"                    :@"contactAvatarID",
        @"quicklyNumberType"        :@"quicklyNumberType",
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
    self.contactID = [self stringValueFix:self.contactID];
    self.contactOpenID = [self stringValueFix:self.contactOpenID];
    self.contactName = [self stringValueFix:self.contactName];
    self.contactNumber = [self stringValueFix:self.contactNumber];
    self.shortNumber = [self stringValueFix:self.shortNumber];
    self.contactType = [self integerNumberValueFix:self.contactType];
    self.contactAvatarID = [self integerNumberValueFix:self.contactAvatarID];
    self.quicklyNumberType = [self integerNumberValueFix:self.quicklyNumberType];
}

- (BOOL)isEqual:(TYDKidContactInfo *)object
{
    return ([self.contactOpenID isEqualToString:object.contactOpenID]
             && [self.contactID isEqualToString:object.contactID]);
}

- (BOOL)setAttributesWithObject:(TYDKidContactInfo *)object
{
    BOOL result = [super setAttributesWithObject:object];
    if(result)
    {
        self.kidID = object.kidID;
        self.contactID = object.contactID;
        self.contactOpenID = object.contactOpenID;
        self.contactName = object.contactName;
        self.contactNumber = object.contactNumber;
        self.shortNumber = object.shortNumber;
        self.contactType = object.contactType;
        self.contactAvatarID = object.contactAvatarID;
        self.quicklyNumberType = object.quicklyNumberType;
    }
    return result;
}

@end
