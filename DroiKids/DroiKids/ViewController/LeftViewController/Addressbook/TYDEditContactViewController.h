//
//  TYDEditContactViewController.h
//  DroiKids
//
//  Created by wangchao on 15/8/29.
//  Copyright (c) 2015年 TYDTech. All rights reserved.
//

#import "BaseScrollController.h"

@class TYDKidContactInfo;

typedef NS_ENUM(NSInteger, TYDEditContactType)
{
    TYDEditContactTypeAdd,
    TYDEditContactTypeModify
};

@interface TYDEditContactViewController : BaseScrollController

@property (strong, nonatomic) TYDKidContactInfo *kidContactInfo;
@property (assign, nonatomic) TYDEditContactType editContactType;
@property (strong, nonatomic) NSNumber *avatarID;

@end
