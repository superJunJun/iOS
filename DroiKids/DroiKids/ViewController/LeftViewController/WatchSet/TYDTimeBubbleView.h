//
//  TYDTimeBubbleView.h
//  DroiKids
//
//  Created by wangchao on 15/9/7.
//  Copyright (c) 2015年 TYDTech. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TYDTimeBubbleView : UIButton

- (instancetype)initWithTimeString:(NSString *)timeString timeFont:(UIFont *)timeFont;

@property (strong, nonatomic) NSString *classTime;

@end
