//
//  TYDBindWatchIDController.h
//  DroiKids
//
//  Created by wangchao on 15/9/9.
//  Copyright (c) 2015年 TYDTech. All rights reserved.
//

#import "BaseScrollController.h"

typedef NS_ENUM(NSUInteger, BindingControllerType)
{
    userHasBabyBinding,
    userHasNoBabyBinding,
};

@interface TYDBindWatchIDController : BaseScrollController

@property (nonatomic) BOOL isFirstLoginSituation;
@property (assign, nonatomic) BindingControllerType type;
@property (strong, nonatomic) NSNumber *avatarID;

@end
