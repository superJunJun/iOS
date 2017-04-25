//
//  TYDKidContactInfo.h
//  DroiKids
//
//  Created by macMini_Dev on 15/8/21.
//  Copyright (c) 2015年 superjunjun. All rights reserved.
//

#import "TYDBaseModel.h"

//联系人类型
typedef NS_ENUM(NSInteger, TYDKidContactType)
{
    TYDKidContactTypeManager    = 0,//管理员
    TYDKidContactTypeGuardian   = 1,//普通监护人
    TYDKidContactTypeNormal     = 2,//普通联系人
};

//快捷拨号
typedef NS_ENUM(NSInteger, TYDKidContactQuickNumber)
{
    TYDKidContactQuickNumberNone    = 0,
    TYDKidContactQuickNumber1st     = 1,
    TYDKidContactQuickNumber2nd     = 2,
};

//联系人关系
typedef NS_ENUM(NSInteger, TYDKidContactRelationShip)
{
    TYDKidContactFather = 0,
    TYDKidContactMother,
    TYDKidContactGrandFather,
    TYDKidContactGrandMother,
    TYDKidContactOther,
};

@interface TYDKidContactInfo : TYDBaseModel

@property (strong, nonatomic) NSString *kidID;
@property (strong, nonatomic) NSString *contactID;
@property (strong, nonatomic) NSString *contactOpenID;
@property (strong, nonatomic) NSString *contactName;
@property (strong, nonatomic) NSString *contactNumber;
@property (strong, nonatomic) NSString *shortNumber;
@property (strong, nonatomic) NSNumber *contactType;//TYDKidContactType
@property (strong, nonatomic) NSNumber *contactAvatarID;
@property (strong, nonatomic) NSNumber *quicklyNumberType;//TYDKidContactQuickNumber

- (BOOL)isEqual:(TYDKidContactInfo *)object;

@end
