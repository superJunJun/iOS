//
//  TYDWeekTimeBlock.h
//  DroiKids
//
//  Created by wangchao on 15/9/7.
//  Copyright (c) 2015年 TYDTech. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TYDWeekTimeBlock : UIButton

@property (strong, nonatomic) NSString *weekTime;

- (instancetype)initWithWeekTimeString:(NSString *)string stringFont:(UIFont *)font;

@end
