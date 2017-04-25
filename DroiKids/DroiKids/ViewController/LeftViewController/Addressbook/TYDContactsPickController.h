//
//  TYDContactsPickController.h
//  DroiKids
//
//  Created by wangchao on 15/8/31.
//  Copyright (c) 2015年 TYDTech. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"

@protocol TYDContactsPickDelegate <NSObject>

@optional
- (void)contactsPickComplete:(NSString *)contactNumber;

@end

@interface TYDContactsPickController : BaseViewController

@property (strong, nonatomic) id<TYDContactsPickDelegate> delegate;

@end
