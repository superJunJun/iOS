//
//  TYDDrawerViewController.h
//  DroiKids
//
//  Created by superjunjun on 15/8/5.
//  Copyright (c) 2015年 superjunjun. All rights reserved.
//

#import <UIKit/UIKit.h>

extern NSString *DrawerViewControllerIdentifier;

@interface TYDDrawerViewController : UIViewController

@property (nonatomic ,strong) UIViewController *centerDrawerViewController;
@property (nonatomic ,strong) UIViewController *leftDrawerViewController;
//@property (nonatomic ,strong) UIViewController *rightDrawerViewController;

- (void)showLeftViewController;
//- (void)showRightViewController;
- (void)closeDrawerView;

@end
