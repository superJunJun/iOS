//
//  ScanAnimationView.h
//  ScanQRCode
//
//  Created by Darren Xie on 14-7-30.
//  Copyright (c) 2014年 Darren Xie. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol BindingButtonTapDelegate <NSObject>

- (void)bindingButtonTap;

@end

@interface ScanAnimationView : UIView

@property (strong, nonatomic) UILabel *scanPromptLabel;
@property (assign, nonatomic) id<BindingButtonTapDelegate> delegate;

- (void)startScanAnimation;
- (void)stopScanAnimation;

@end
