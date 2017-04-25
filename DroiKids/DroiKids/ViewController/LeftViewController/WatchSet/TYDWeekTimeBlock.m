//
//  TYDWeekTimeBlock.m
//  DroiKids
//
//  Created by wangchao on 15/9/7.
//  Copyright (c) 2015年 TYDTech. All rights reserved.
//

#import "TYDWeekTimeBlock.h"

@interface TYDWeekTimeBlock ()

@property (strong, nonatomic) UILabel *weekTimeLabel;

@end

@implementation TYDWeekTimeBlock

- (instancetype)initWithWeekTimeString:(NSString *)string stringFont:(UIFont *)font
{
    if(self = [super init])
    {
        _weekTime = string;
        
        UIImage *backgroundImage = [UIImage imageNamed:@"watchSet_weekTime"];
        [self setBackgroundImage:backgroundImage forState:UIControlStateSelected];
        self.size = CGSizeMake(25, 25);
        
        UILabel *label = [UILabel new];
        label.backgroundColor = [UIColor clearColor];
        label.font = [UIFont systemFontOfSize:14];
        label.textColor = [UIColor blackColor];
        label.text = string;
        [label sizeToFit];
        label.center = self.innerCenter;
        
        [self addSubview:label];
        self.weekTimeLabel = label;
    }
    
    return self;
}

- (void)setSelected:(BOOL)selected
{
    if(self.selected != selected)
    {
        [super setSelected:selected];
        
        if(selected)
        {
            self.weekTimeLabel.textColor = [UIColor whiteColor];
        }
        else
        {
            self.weekTimeLabel.textColor = [UIColor blackColor];
        }
    }
}

@end
