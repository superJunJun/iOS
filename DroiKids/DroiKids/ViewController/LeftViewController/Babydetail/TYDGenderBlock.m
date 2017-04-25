//
//  TYDGenderBlock.m
//  DroiKids
//
//  Created by wangchao on 15/8/18.
//  Copyright (c) 2015年 superjunjun. All rights reserved.
//

#import "TYDGenderBlock.h"

@interface TYDGenderBlock ()

@property (strong, nonatomic) UIImageView *genderIcon;
@property (strong, nonatomic) UILabel *genderNameLabel;

@end

@implementation TYDGenderBlock

- (instancetype)initWithGenderName:(NSString *)genderName
                    genderNameFont:(UIFont *)genderNameFont
                    genderIconSize:(CGSize)genderIconSize
{
    if(self = [super init])
    {
        self.gender = genderName;
        
        UIImage *genderBlockImage = [[UIImage imageNamed:@"babyDetail_genderBlock"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 10, 0, 10) resizingMode:UIImageResizingModeStretch];
        
        self.backgroundColor = [UIColor clearColor];
        [self setBackgroundImage:genderBlockImage forState:UIControlStateSelected];
        
        //genderIcon
        NSString *genderIconImageName = ([genderName isEqualToString:@"男"]) ? @"babyDetail_maleIcon" : @"babyDetail_femaleIcon";
        NSString *genderIconHImageName = ([genderName isEqualToString:@"男"]) ? @"babyDetail_maleIconH" : @"babyDetail_femaleIconH";
        
        UIImageView *genderIcon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:genderIconImageName] highlightedImage:[UIImage imageNamed:genderIconHImageName]];
        genderIcon.backgroundColor = [UIColor clearColor];
        genderIcon.size = CGSizeMake(genderIconSize.width, genderIconSize.height);
        [self addSubview:genderIcon];
        self.genderIcon = genderIcon;
        
        //genderName
        UILabel *genderNameLabel = [UILabel new];
        genderNameLabel.backgroundColor = [UIColor clearColor];
        genderNameLabel.font = genderNameFont;
        genderNameLabel.textColor = [UIColor colorWithHex:0x000000];
        genderNameLabel.text = genderName;
        [genderNameLabel sizeToFit];
        
        [self addSubview:genderNameLabel];
        self.genderNameLabel = genderNameLabel;
        
        //layoutViews
        CGFloat horEdgeInsets = 10;
        CGFloat verticalEdgeInsets = 3;
        CGFloat viewDistance = 2;
        self.width = horEdgeInsets * 2 + self.genderIcon.width + viewDistance + self.genderNameLabel.width;
        self.height = MAX(self.genderIcon.height, self.genderNameLabel.height) + verticalEdgeInsets * 2;
        
        self.genderIcon.left = horEdgeInsets;
        self.genderIcon.yCenter = self.yCenter;
        self.genderNameLabel.left = self.genderIcon.right + viewDistance;
        self.genderNameLabel.yCenter = self.yCenter;
    }
    
    return self;
}

#pragma mark OverrideMethod

- (void)setSelected:(BOOL)selected
{
    if(self.selected != selected)
    {
        [super setSelected:selected];
        
        if(selected)
        {
            self.genderNameLabel.textColor = [UIColor whiteColor];
        }
        else
        {
            self.genderNameLabel.textColor = [UIColor blackColor];
        }
        
        self.genderIcon.highlighted = selected;
    }
}

@end
