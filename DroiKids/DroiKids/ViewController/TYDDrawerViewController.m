//
//  TYDDrawerViewController.m
//  DroiKids
//
//  Created by superjunjun on 15/8/5.
//  Copyright (c) 2015年 superjunjun. All rights reserved.
//

#import "TYDDrawerViewController.h"
#import "TYDMainViewController.h"
#import "TYDLeftDrawerViewController.h"
#import "TYDNoticeViewController.h"
#import "AppDelegate.h"

#define nLeftSideViewShowedWidth        180
#define nRightSideViewShowedWidth       80
#define kMenuFullWidth                  320.0f
#define kMenuDisplayedWidth             280.0f


const NSString *DrawerViewControllerIdentifier = @"drawerViewController";

@interface TYDDrawerViewController ()

@property (nonatomic, strong) UIView *tapGestureRecognizerView;

@end

@implementation TYDDrawerViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self subviewLoad];
    AppDelegate *delegate = [UIApplication sharedApplication].delegate;
    delegate.drawerViewController = self;
}

- (void)subviewLoad
{
    UINavigationController *mainNavigationController = [self.storyboard instantiateViewControllerWithIdentifier:@"mainNavigationController"];
    UIViewController *LeftViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"LeftViewController"];
    
    [self addChildViewController:mainNavigationController];
    [self addChildViewController:LeftViewController];
    [self.view addSubview:LeftViewController.view];
    [self.view addSubview:mainNavigationController.view];
    self.leftDrawerViewController = LeftViewController;
    self.centerDrawerViewController = mainNavigationController;
}

#pragma mark - TouchEvent

- (void)tap:(UITapGestureRecognizer *)tapGestureRecognizer
{
    [self closeDrawerView];
}

#pragma mark - ShowViewController

- (void)showLeftViewController
{
    [self addGestureRecognizerView];
    UIViewController *mainViewController = self.childViewControllers.firstObject;
    //添加抽屉视图
    UIView *view = self.leftDrawerViewController.view;
    CGRect frame = self.view.bounds;
    
    frame = mainViewController.view.frame;
    frame.origin.x = CGRectGetMaxX(view.frame) - (kMenuFullWidth - kMenuDisplayedWidth);
    
    [UIView animateWithDuration:.3 animations:^{
        mainViewController.view.frame = frame;
    } completion:^(BOOL finished) {
       // [_tap setEnabled:YES];
    }];
    
}

- (void)addGestureRecognizerView
{
    //添加单击手势视图
    if (_tapGestureRecognizerView == nil)
    {
        _tapGestureRecognizerView = [[UIView alloc] initWithFrame:self.view.bounds];
    }
    [[self.childViewControllers.firstObject view] addSubview:_tapGestureRecognizerView];
    UITapGestureRecognizer  *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tap:)];
    UIPanGestureRecognizer *panGestureRecognizer = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(tap:)];
    [_tapGestureRecognizerView addGestureRecognizer:tapGestureRecognizer];
    [_tapGestureRecognizerView addGestureRecognizer:panGestureRecognizer];
}

- (void)closeDrawerView
{
    UIViewController *mainViewController = self.childViewControllers.firstObject;
    CGRect frame = mainViewController.view.frame;
    frame.origin.x = 0.0f;
    [UIView animateWithDuration:.3 animations:^{
        mainViewController.view.frame = frame;
    } completion:^(BOOL finished) {
        [self closeDrawerViewEnd];
    }];
}

// 关闭抽屉时执行相关移除操作。
- (void)closeDrawerViewEnd
{
    [_tapGestureRecognizerView removeFromSuperview];
    _tapGestureRecognizerView = nil;
}

@end
