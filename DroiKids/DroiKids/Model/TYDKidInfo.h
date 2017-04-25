//
//  TYDKidInfo.h
//  DroiKids
//
//  Created by macMini_Dev on 15/8/18.
//  Copyright (c) 2015年 superjunjun. All rights reserved.
//

#import "TYDBaseModel.h"
#import "TYDWatchInfo.h"

typedef NS_ENUM(NSInteger, TYDKidColorType)
{
    TYDKidColorTypeNone = -1,
    
    TYDKidColorTypeRed = 1,
    TYDKidColorTypeYellow,
    TYDKidColorTypeGreen,
    TYDKidColorTypeBlue,
    TYDKidColorTypePurple,
    
    TYDKidColorTypeTotal,
};

//性别 0：男 1：女
typedef NS_ENUM(NSInteger, TYDKidGenderType)
{
    TYDKidGenderTypeBoy     = 0,
    TYDKidGenderTypeGirl    = 1,
};

#define sKidAvatarNameGirl              @"main_left_babyFemale"
#define sKidAvatarNameBoy               @"main_left_babyMale"

//6岁孩子指标
#define nKidGenderDefaultValue          (TYDKidGenderTypeGirl)
#define nKidHeightDefaultValue          117
#define nKidWeightDefaultValue          22

@interface TYDKidInfo : TYDBaseModel

@property (strong, nonatomic) NSString *kidID;
@property (strong, nonatomic) NSString *kidName;
@property (strong, nonatomic) NSString *phoneNumber;
@property (strong, nonatomic) NSNumber *kidGender;
@property (strong, nonatomic) NSNumber *kidBirthday;
@property (strong, nonatomic) NSNumber *kidWeight;      //单位kg，保留一位小数
@property (strong, nonatomic) NSNumber *kidHeight;      //单位cm，整数
@property (strong, nonatomic) NSNumber *kidColorType;   //
@property (strong, nonatomic) NSString *homeAddress;    //家庭地址
@property (strong, nonatomic) NSString *schoolAddress;  //学校地址
@property (strong, nonatomic) NSString *kidAvatarPath;  //头像路径
@property (strong, nonatomic) NSString *kidGuardianRelationShip;//称呼关系
@property (strong, nonatomic) NSNumber *kidGuardianType;//当前用户的监护人类型

@property (strong, nonatomic) NSString *watchID;
@property (strong, nonatomic) NSNumber *autoConnectState;    //手表自动接通 0  关  1 开
@property (strong, nonatomic) NSNumber *silentState;         //静音状态   0  关  1  开
@property (strong, nonatomic) NSString *silentTime;          //静音时间段，中间空格隔开
@property (strong, nonatomic) NSNumber *backlightTime;       //背光时间  min
@property (strong, nonatomic) NSNumber *watchSoundState;     //铃声  0 关  1  开
@property (strong, nonatomic) NSNumber *watchShockState;     //震动 0 关  1  开
@property (strong, nonatomic) NSNumber *capInterval;              //手表上传位置信息的间隔时间  min
@property (strong, nonatomic) NSNumber *electronicFenceState;    //电子围栏开关  0  关  1  开
@property (strong, nonatomic) NSString *fenceCenterPoint;      //点（当前为圆心坐标，经纬度之间空格隔开）
@property (strong, nonatomic) NSNumber *fenceRadius;             //半径，单位待定
@property (strong, nonatomic) NSNumber *castOff;                //是否开启防脱落

@property (strong, nonatomic) NSNumber *batteryLeft;            //剩余电量
@property (strong, nonatomic) NSString *currentLocation;        //小孩当前位置

+ (NSNumber *)kidGenderWithGenderString:(NSString *)genderString;
+ (NSString *)kidGenderStringWithGender:(TYDKidGenderType)gender;

+ (long)kidColorHexWithKidColorType:(NSNumber *)kidColorType;
+ (NSString *)colorStringWithColorType:(NSNumber *)kidColorType;

+ (NSNumber *)kidBirthdayDefaultValue;

@end


