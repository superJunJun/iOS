//
//  TYDTimeBubbleView.m
//  DroiKids
//
//  Created by wangchao on 15/9/7.
//  Copyright (c) 2015年 TYDTech. All rights reserved.
//

#import "TYDTimeBubbleView.h"

@interface TYDTimeBubbleView ()

@property (strong, nonatomic) UILabel *classTimeLabel;

@end

@implementation TYDTimeBubbleView

- (instancetype)initWithTimeString:(NSString *)timeString timeFont:(UIFont *)timeFont
{
    if(self = [super init])
    {
        self.classTime = timeString;
        
        UIImage *backGroundImage = [[UIImage imageNamed:@"watchSet_classTime"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 15, 0, 15) resizingMode:UIImageResizingModeStretch];
        self.backgroundColor = [UIColor clearColor];
        [self setBackgroundImage:backGroundImage forState:UIControlStateSelected];
        
        UILabel *classTimeLabel = [UILabel new];
        classTimeLabel.backgroundColor = [UIColor clearColor];
        classTimeLabel.font = [UIFont systemFontOfSize:14];
        classTimeLabel.textColor = [UIColor blackColor];
        classTimeLabel.text = timeString;
        [classTimeLabel sizeToFit];
        
        [self addSubview:classTimeLabel];
        self.classTimeLabel = classTimeLabel;
        
        CGFloat horOffset = 10;
        CGFloat verticalOffset = 4;
        
        self.size = CGSizeMake(classTimeLabel.width + horOffset * 2, classTimeLabel.height + verticalOffset * 2);
        
        self.classTimeLabel.center = self.innerCenter;
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
            self.classTimeLabel.textColor = [UIColor whiteColor];
        }
        else
        {
            self.classTimeLabel.textColor = [UIColor blackColor];
        }
    }
}

- (void)setClassTime:(NSString *)classTime
{
    if(![self.classTime isEqualToString:classTime])
    {
        self.classTimeLabel.text = classTime;
        [self.classTimeLabel sizeToFit];
        
        CGFloat horOffset = 10;
        CGFloat verticalOffset = 4;
        
        self.size = CGSizeMake(self.classTimeLabel.width + horOffset * 2, self.classTimeLabel.height + verticalOffset * 2);
        self.classTimeLabel.center = self.innerCenter;
        
        _classTime = classTime;
    }
}

@end
