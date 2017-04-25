//
//  TYDKidInfo.m
//  DroiKids
//
//  Created by macMini_Dev on 15/8/18.
//  Copyright (c) 2015年 superjunjun. All rights reserved.
//

#import "TYDKidInfo.h"
#import "TYDKidContactInfo.h"

@implementation TYDKidInfo

- (NSDictionary *)attributeMapDictionary
{
    NSDictionary *mapDic =
    @{
        @"childid"              :@"kidID",
        @"childname"            :@"kidName",
        @"phone"                :@"phoneNumber",
        @"sex"                  :@"kidGender",
        @"birthday"             :@"kidBirthday",
        @"weight"               :@"kidWeight",
        @"height"               :@"kidHeight",
        @"color"                :@"kidColorType",
        @"address"              :@"homeAddress",
        @"school"               :@"schoolAddress",
        @"img"                  :@"kidAvatarPath",
        @"relationship"         :@"kidGuardianRelationShip",
        @"type"                 :@"kidGuardianType",
        
        @"watchid"              :@"watchID",
        @"autoconnect"          :@"autoConnectState",
        @"silentstatus"         :@"silentState",
        @"silenttime"           :@"silentTime",
        @"backlighttime"        :@"backlightTime",
        @"watchsound"           :@"watchSoundState",
        @"watchshock"           :@"watchShockState",
        @"cpinterval"           :@"capInterval",
        @"electronicfence"      :@"electronicFenceState",
        @"electronicFencePoints":@"fenceCenterPoint",
        @"radius"               :@"fenceRadius",
        @"castoff"              :@"castOff"
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
    self.kidName = [self stringValueFix:self.kidName];
    self.watchID = [self stringValueFix:self.watchID];
    self.phoneNumber = [self stringValueFix:self.phoneNumber];
    self.kidBirthday = [self integerNumberValueFix:self.kidBirthday];
    self.kidWeight = [self floatNumberValueFix:self.kidWeight];
    self.kidHeight = [self integerNumberValueFix:self.kidHeight];
    self.homeAddress = [self stringValueFix:self.homeAddress];
    self.schoolAddress = [self stringValueFix:self.schoolAddress];
    self.kidAvatarPath = [self stringValueFix:self.kidAvatarPath];
    self.kidGuardianRelationShip = [self stringValueFix:self.kidGuardianRelationShip];
    self.kidGuardianType = [self integerNumberValueFix:self.kidGuardianType];
    self.kidGender = [self integerNumberValueFix:self.kidGender];
    self.kidColorType = [self integerNumberValueFix:self.kidColorType];
    
    //watch
    self.autoConnectState = [self integerNumberValueFix:self.autoConnectState];
    self.silentState = [self integerNumberValueFix:self.silentState];
    self.silentTime = [self defultSilentTime:[self stringValueFix:self.silentTime]];
    self.backlightTime = [self integerNumberValueFix:self.backlightTime];
    self.watchSoundState = [self integerNumberValueFix:self.watchSoundState];
    self.watchShockState = [self integerNumberValueFix:self.watchShockState];
    self.capInterval = [self defultCapInterval:[self integerNumberValueFix:self.capInterval]];
    self.electronicFenceState = [self integerNumberValueFix:self.electronicFenceState];
    self.fenceCenterPoint = [self stringValueFix:self.fenceCenterPoint];
    self.fenceRadius = [self integerNumberValueFix:self.fenceRadius];
    self.castOff = [self integerNumberValueFix:self.castOff];
}

- (BOOL)isEqual:(TYDKidInfo *)object
{
    return ([self.kidID isEqualToString:object.kidID]
            && self.kidID.length > 0);
}

- (BOOL)setAttributesWithObject:(TYDKidInfo *)object
{
    BOOL result = [super setAttributesWithObject:object];
    if(result)
    {
        //self.kidID = object.kidID;
        self.kidName = object.kidName;
        self.watchID = object.watchID;
        self.phoneNumber = object.phoneNumber;
        self.kidGender = object.kidGender;
        self.kidBirthday = object.kidBirthday;
        self.kidWeight = object.kidWeight;
        self.kidHeight = object.kidHeight;
        self.kidColorType = object.kidColorType;
        self.homeAddress = object.homeAddress;
        self.schoolAddress = object.schoolAddress;
        self.kidAvatarPath = object.kidAvatarPath;
        self.kidGuardianType = object.kidGuardianType;
        
        self.autoConnectState = object.autoConnectState;
        self.silentState = object.silentState;
        self.silentTime = object.silentTime;
        self.backlightTime = object.backlightTime;
        self.watchSoundState = object.watchSoundState;
        self.watchShockState = object.watchShockState;
        self.capInterval = object.capInterval;
        self.electronicFenceState = object.electronicFenceState;
        self.fenceCenterPoint = object.fenceCenterPoint;
        self.fenceRadius = object.fenceRadius;
        self.castOff = object.castOff;
    }
    return result;
}

#pragma mark - Gender

+ (NSNumber *)kidGenderWithGenderString:(NSString *)genderString
{
    return ([genderString isEqualToString:@"男"] ? @(TYDKidGenderTypeBoy) : @(TYDKidGenderTypeGirl));
}

+ (NSString *)kidGenderStringWithGender:(TYDKidGenderType)gender
{
    return (gender == TYDKidGenderTypeBoy ? @"男" : @"女");
}

+ (long)kidColorHexWithKidColorType:(NSNumber *)kidColorType
{
    long colorValue = 0x6cbb52;
    switch(kidColorType.integerValue)
    {
        case TYDKidColorTypeGreen:
            colorValue = 0x6cbb52;
            break;
        case TYDKidColorTypeYellow:
            colorValue = 0xfa952d;
            break;
        case TYDKidColorTypeBlue:
            colorValue = 0x1283cf;
            break;
        case TYDKidColorTypePurple:
            colorValue = 0xa849c0;
            break;
        case TYDKidColorTypeRed:
            colorValue = 0xef6152;
            break;
    }
    
    return colorValue;
}

+ (NSString *)colorStringWithColorType:(NSNumber *)kidColorType
{
    NSString *colorString = @"绿色";
    switch(kidColorType.integerValue)
    {
        case TYDKidColorTypeGreen:
            colorString = @"绿色";
            break;
        case TYDKidColorTypeYellow:
            colorString = @"黄色";
            break;
        case TYDKidColorTypeBlue:
            colorString = @"蓝色";
            break;
        case TYDKidColorTypePurple:
            colorString = @"紫色";
            break;
        case TYDKidColorTypeRed:
            colorString = @"红色";
            break;
    }
    
    return colorString;
}

+ (NSNumber *)kidBirthdayDefaultValue
{//6年
    NSDateFormatter *dateFormatter = [NSDateFormatter new];
    dateFormatter.dateFormat = @"yyyy";
    NSString *yearString = [dateFormatter stringFromDate:[NSDate date]];
    yearString = [NSString stringWithFormat:@"%d", yearString.intValue - 6];
    return @(((NSInteger)[[dateFormatter dateFromString:yearString] timeIntervalSince1970]));
}

//- (void)watchAttributeSetDefaultValue
//{
//    self.kidName = @"宝宝";
//    self.phoneNumber = @"";
//    self.kidGender = @(TYDKidGenderTypeBoy);
//    self.kidBirthday = @(123456321);
//    self.kidWeight = @(30);
//    self.kidHeight = @(100);
//    self.kidColorType = @(TYDKidColorTypeGreen);
//    self.homeAddress = @"桂平路";
//    self.schoolAddress = @"上海小学";
//    self.autoConnectState = nwatchStateDefaultValue;
//    self.silentTime = @"09:00-11:40 02:00-05:00";
//    self.backlightTime = @(10);
//    self.watchSoundState = nwatchStateDefaultValue;
//    self.watchShockState = nwatchStateDefaultValue;
//    self.capInterval = @(15);
//    self.electronicFenceState = nwatchStateDefaultValue;
//    self.fenceCenterPoint = @"121.419332 31.150284";
//    self.fenceRadius = @(1000);
//}

- (NSString *)defultSilentTime:(NSString *)string
{
    if([string componentsSeparatedByString:@" "].count != 3)
    {
        return @"1111100 08:30-11:00 14:00-16:30";
    }
    return string;
}

- (NSNumber *)defultCapInterval:(NSNumber *)capInterval
{
    if(capInterval.integerValue == 0)
    {
        return @(60);
    }
    return capInterval;
}

//- (void)setBatteryLeft:(NSNumber *)batteryLeft
//{
//
//}
//
//- (void)setCurrentLocation:(NSString *)currentLocation
//{
//
//}

@end
