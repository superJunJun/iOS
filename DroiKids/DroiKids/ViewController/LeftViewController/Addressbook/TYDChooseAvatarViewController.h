//
//  TYDChooseAvatarViewController.h
//  DroiKids
//
//  Created by superjunjun on 15/8/21.
//  Copyright (c) 2015年 superjunjun. All rights reserved.
//

#import "BaseScrollController.h"
#import "TYDEditContactViewController.h"

@protocol TYDChooseAvatarDelegate <NSObject>
@optional
- (void)choseAvatarComplete:(NSNumber *)avatarID;

@end

@interface TYDChooseAvatarViewController : BaseScrollController

@property (assign, nonatomic) TYDEditContactType editContactType;
@property (strong, nonatomic) NSNumber *avatarID;

@property (assign, nonatomic) id<TYDChooseAvatarDelegate> choseAvatarDelegate;

@end
