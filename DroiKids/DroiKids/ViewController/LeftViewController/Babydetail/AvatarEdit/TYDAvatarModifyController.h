//
//  TYDAvatarModifyController.h
//  DroiKids
//
//  Created by wangchao on 15/8/22.
//  Copyright (c) 2015年 superjunjun. All rights reserved.
//

#import "BaseViewController.h"

@protocol TYDAvatarModifyCompleteDelegate <NSObject>
@optional
- (void)avatarModifyComplete:(UIImage *)avatarImage;

@end

@interface TYDAvatarModifyController : BaseViewController

@property (strong, nonatomic) UIImage *avatarImage;
@property (assign, nonatomic) id<TYDAvatarModifyCompleteDelegate> delegate;

@end
