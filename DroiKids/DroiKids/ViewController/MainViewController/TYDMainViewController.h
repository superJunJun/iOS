//
//  ViewController.h
//  DroiKids
//
//  Created by superjunjun on 15/8/5.
//  Copyright (c) 2015年 superjunjun. All rights reserved.
//

#import "BaseViewController.h"

typedef NS_ENUM(NSInteger, OperationType) {
    TYDGetBettaryLeft,
    TYDTelephoneConversations,
    TYDGetKidLocationInfo,
};

@interface TYDMainViewController : BaseViewController

@property (strong, nonatomic) UIView               *grayView;

- (void)reloadLocation:(NSString *)currentLocation;
- (void)reloadBettry:(NSInteger )batteryLeft;

@end

