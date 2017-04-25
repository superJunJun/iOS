//
//  BOBottomPopupView.h
//  EMove
//
//  Created by macMini_Dev on 15/1/8.
//  Copyright (c) 2015年 Young. All rights reserved.
//
//  底部弹出管控视图
//

#import <UIKit/UIKit.h>

@class BOBottomPopupView;
@protocol BOBottomPopupViewDelegate <NSObject>
@optional
- (void)bottomPopupViewWillShow:(BOBottomPopupView *)view;
- (void)bottomPopupViewDidHidden:(BOBottomPopupView *)view;
@end

@interface BOBottomPopupView : UIView

//当前视图，customViews中顶层视图
@property (strong, nonatomic) UIView *currentVisibleCustomView;

//视图组
@property (strong, nonatomic) NSArray *customViews;

//背景渲染色，默认黑色半透
@property (strong, nonatomic) UIColor *backgroundTintColor;

//点击中心视图外区域是否隐藏弹出视图，默认YES
@property (nonatomic) BOOL isToHideWhenTapOutSide;

@property (assign, nonatomic) id<BOBottomPopupViewDelegate> delegate;

- (instancetype)initWithCustomViews:(NSArray *)customViews;

- (void)bottomPopupViewShowAnimated;
- (void)bottomPopupViewHide:(BOOL)animated;
- (void)bottomPopupViewSwitchVisibleState;

@end
