//
//  TYDAppProfileController.h
//  DroiKids
//
//  Created by macMini_Dev on 15/9/22.
//  Copyright © 2015年 TYDTech. All rights reserved.
//

#import <UIKit/UIKit.h>

@class TYDAppProfileController;
@protocol TYDAppProfileControllerDelegate <NSObject>
@optional
- (void)appProfileControllerExperienceButtonTap:(TYDAppProfileController *)viewController;
@end

@interface TYDAppProfileController : UIViewController

@property (assign, nonatomic) id<TYDAppProfileControllerDelegate> delegate;
- (void)destroyAnimated:(BOOL)animated;

@end
