//
//  TYDChoseBundingStyleController.m
//  DroiKids
//
//  Created by wangchao on 15/9/22.
//  Copyright © 2015年 TYDTech. All rights reserved.
//

#import "TYDChoseBundingStyleController.h"
#import "TYDQRCodeViewController.h"
#import "TYDBindWatchIDController.h"

@implementation TYDChoseBundingStyleController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self localDataInitialize];
    [self navigationBarItemsLoad];
    [self subviewsLoad];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if(self.isFirstLoginSituation)
    {
        self.backButtonVisible = NO;
    }
}

- (void)localDataInitialize
{
    
}

- (void)navigationBarItemsLoad
{
    self.title = @"绑定手表设备";
}

- (void)subviewsLoad
{
    UIView *baseView = [UIView new];
    baseView.backgroundColor = [UIColor clearColor];
    
    UIEdgeInsets capInsets = UIEdgeInsetsMake(10, 10, 10, 10);
    CGFloat buttonDistance = 30;
    
    UIButton *scanButton = [[UIButton alloc] initWithImageName:@"login_btn" highlightedImageName:@"login_btnH" capInsets:capInsets givenButtonSize:CGSizeMake(self.view.width - 34, 40) title:@"扫描二维码" titleFont:[UIFont fontWithName:@"Arial" size:18] titleColor:UIColorWithHex(0xffffff)];
    [scanButton addTarget:self action:@selector(scanButtonTap:) forControlEvents:UIControlEventTouchUpInside];
    scanButton.origin = CGPointMake(17, 0);
    [baseView addSubview:scanButton];
    
    UIButton *inputNumberButton = [[UIButton alloc] initWithImageName:@"login_btn" highlightedImageName:@"login_btnH" capInsets:capInsets givenButtonSize:CGSizeMake(self.view.width - 34, 40) title:@"添加绑定号" titleFont:[UIFont fontWithName:@"Arial" size:18] titleColor:UIColorWithHex(0xffffff)];
    [inputNumberButton addTarget:self action:@selector(inputNumberButtonTap:) forControlEvents:UIControlEventTouchUpInside];
    
    inputNumberButton.top = scanButton.bottom + buttonDistance;
    inputNumberButton.left = scanButton.left;
    [baseView addSubview:inputNumberButton];
    
    baseView.size = CGSizeMake(self.view.width, scanButton.height + buttonDistance + inputNumberButton.height);
    [BOAssistor rectangleShow:self.view.frame withTitle:@"self.view.frame"];
    baseView.center = self.view.center;
    baseView.yCenter = baseView.yCenter - 32;
    [self.baseView addSubview:baseView];
    
    self.baseViewBaseHeight = baseView.bottom;
}

#pragma mark - TouchEvent

- (void)scanButtonTap:(UIButton *)sender
{
    NSLog(@"scanButtonTap");
    
    TYDQRCodeViewController *vc = [TYDQRCodeViewController new];
    vc.isFirstLoginSituation = self.isFirstLoginSituation;
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)inputNumberButtonTap:(UIButton *)sender
{
    NSLog(@"inputNumberButtonTap");
    
    TYDBindWatchIDController *vc = [TYDBindWatchIDController new];
    vc.isFirstLoginSituation = self.isFirstLoginSituation;
    [self.navigationController pushViewController:vc animated:YES];
}

@end
