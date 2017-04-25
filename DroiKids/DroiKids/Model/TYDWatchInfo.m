//
//  TYDWatchInfo.m
//  DroiKids
//
//  Created by superjunjun on 15/9/25.
//  Copyright © 2015年 TYDTech. All rights reserved.
//

#import "TYDWatchInfo.h"
#import "TYDDataCenter.h"

@implementation TYDWatchInfo

- (NSDictionary *)attributeMapDictionary
{
    NSDictionary *mapDic =
    @{
      @"id"                 :@"stateID",
      @"openid"             :@"openID",
      @"watchid"            :@"watchID",
      @"autoconnect"        :@"autoConnectState",
      @"silentstatus"       :@"silentState",
      @"silenttime"         :@"silentTime",
      @"backlighttime"      :@"backlightTime",
      @"watchsound"         :@"watchSoundState",
      @"watchshock"         :@"watchShockState",
      @"cpinterval"         :@"capTime",
      @"electronicfence"    :@"electronicFenceState",
      @"points"             :@"fenceCenterPoint",
      @"radius"             :@"fenceRadius",
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
    self.stateID = [self integerNumberValueFix:self.stateID];
    self.openID = [self stringValueFix:self.openID];
    self.watchID = [self stringValueFix:self.watchID];
    self.autoConnectState = [self integerNumberValueFix:self.autoConnectState];
    self.silentState = [self integerNumberValueFix:self.silentState];
    self.silentTime = [self stringValueFix:self.silentTime];
    self.backlightTime = [self integerNumberValueFix:self.backlightTime];
    self.watchSoundState = [self integerNumberValueFix:self.watchSoundState];
    self.watchShockState = [self integerNumberValueFix:self.watchShockState];
    self.capTime = [self integerNumberValueFix:self.capTime];
    self.electronicFenceState = [self integerNumberValueFix:self.electronicFenceState];
    self.fenceCenterPoint = [self stringValueFix:self.fenceCenterPoint];
    self.fenceRadius = [self integerNumberValueFix:self.fenceRadius];
    
}

- (void)watchAttributeSetDefaultValue
{
    self.stateID = nil;
    self.openID = [TYDUserInfo sharedUserInfo].openID;
    self.watchID = [[[TYDDataCenter defaultCenter] currentKidInfo] watchID];
    self.autoConnectState = nwatchStateDefaultValue;
    self.silentTime = @"09:00-11:40 02:00-05:00";
    self.backlightTime = @(10);
    self.watchSoundState = nwatchStateDefaultValue;
    self.watchShockState = nwatchStateDefaultValue;
    self.capTime = @(15);
    self.electronicFenceState = nwatchStateDefaultValue;
    self.fenceCenterPoint = @"121.419332 31.150284";
    self.fenceRadius = @(1000);
}

- (BOOL)isEqual:(TYDWatchInfo *)object
{
    return ([self.watchID isEqualToString:object.watchID]
            && [self.autoConnectState isEqualToNumber:object.autoConnectState]
            && [self.silentTime isEqualToString:object.silentTime]
            && [self.backlightTime isEqualToNumber:object.backlightTime]
            && [self.watchSoundState isEqualToNumber:object.watchSoundState]
            && [self.watchShockState isEqualToNumber:object.watchShockState]
            && [self.capTime isEqualToNumber:object.capTime]
            && [self.electronicFenceState isEqualToNumber:object.electronicFenceState]
            && [self.fenceCenterPoint isEqualToString:object.fenceCenterPoint]
            && [self.fenceRadius isEqualToNumber:object.fenceRadius]
            );
}

//- (BOOL)setAttributesWithObject:(TYDKidInfo *)object
//{
//    BOOL result = [super setAttributesWithObject:object];
//    if(result)
//    {
//        //self.kidID = object.kidID;
//        self.kidName = object.kidName;
//        self.watchID = object.watchID;
//        self.phoneNumber = object.phoneNumber;
//        self.kidGender = object.kidGender;
//        self.kidBirthday = object.kidBirthday;
//        self.kidWeight = object.kidWeight;
//        self.kidHeight = object.kidHeight;
//        self.kidColorType = object.kidColorType;
//        self.homeAddress = object.homeAddress;
//        self.schoolAddress = object.schoolAddress;
//        self.kidAvatarPath = object.kidAvatarPath;
//        self.kidGuardianType = object.kidGuardianType;
//    }
//    return result;
//}
//
//#pragma mark - Gender
//
//+ (NSNumber *)kidGenderWithGenderString:(NSString *)genderString
//{
//    return ([genderString isEqualToString:@"男"] ? @(TYDKidGenderTypeBoy) : @(TYDKidGenderTypeGirl));
//}
//
//+ (NSString *)kidGenderStringWithGender:(TYDKidGenderType)gender
//{
//    return (gender == TYDKidGenderTypeBoy ? @"男" : @"女");
//}
//
//+ (long)kidColorHexWithKidColorType:(NSNumber *)kidColorType
//{
//    long colorValue = 0x6cbb52;
//    switch(kidColorType.integerValue)
//    {
//        case TYDKidColorTypeGreen:
//            colorValue = 0x6cbb52;
//            break;
//        case TYDKidColorTypeYellow:
//            colorValue = 0xfa952d;
//            break;
//        case TYDKidColorTypeBlue:
//            colorValue = 0x1283cf;
//            break;
//        case TYDKidColorTypePurple:
//            colorValue = 0xa849c0;
//            break;
//        case TYDKidColorTypeRed:
//            colorValue = 0xef6152;
//            break;
//    }
//    
//    return colorValue;
//}
//
//+ (NSString *)colorStringWithColorType:(NSNumber *)kidColorType
//{
//    NSString *colorString = @"绿色";
//    switch(kidColorType.integerValue)
//    {
//        case TYDKidColorTypeGreen:
//            colorString = @"绿色";
//            break;
//        case TYDKidColorTypeYellow:
//            colorString = @"黄色";
//            break;
//        case TYDKidColorTypeBlue:
//            colorString = @"蓝色";
//            break;
//        case TYDKidColorTypePurple:
//            colorString = @"紫色";
//            break;
//        case TYDKidColorTypeRed:
//            colorString = @"红色";
//            break;
//    }
//    
//    return colorString;
//}
//
//+ (NSNumber *)kidBirthdayDefaultValue
//{//6年
//    NSDateFormatter *dateFormatter = [NSDateFormatter new];
//    dateFormatter.dateFormat = @"yyyy";
//    NSString *yearString = [dateFormatter stringFromDate:[NSDate date]];
//    yearString = [NSString stringWithFormat:@"%d", yearString.intValue - 6];
//    return @(((NSInteger)[[dateFormatter dateFromString:yearString] timeIntervalSince1970]));
//}

@end
