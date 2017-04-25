//
//  TYDBackgroundColorBlock.m
//  DroiKids
//
//  Created by wangchao on 15/8/18.
//  Copyright (c) 2015年 superjunjun. All rights reserved.
//

#import "TYDBackgroundColorBlock.h"

@interface TYDBackgroundColorBlock ()

@property (strong, nonatomic) UIView *checkIcon;

@end

@implementation TYDBackgroundColorBlock

- (instancetype)initWithSizeLength:(CGFloat)sizeLength andBackgroundColor:(NSNumber *)colorType
{
    if(self = [self init])
    {
        self.size = CGSizeMake(sizeLength, sizeLength);
        self.layer.cornerRadius = sizeLength / 2;
        self.colorType = colorType;
        self.checkIconVisible = NO;
        
        [self checkIconLoad];
    }
    
    return self;
}

- (void)checkIconLoad
{
    UIImageView *checkIcon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"babyDetail_selectColorBlockBg"]];
    checkIcon.frame = self.frame;
    [self addSubview:checkIcon];
    
    checkIcon.hidden = self.checkIconVisible ? NO : YES;
    self.checkIcon = checkIcon;
}

-(void)setCheckIconVisible:(BOOL)checkIconVisible
{
    if(self.checkIconVisible != checkIconVisible)
    {
        _checkIconVisible = checkIconVisible;
        self.checkIcon.hidden = !checkIconVisible;
    }
}

- (void)setColorType:(NSNumber *)colorType
{
    if(![self.colorType isEqualToNumber: colorType])
    {
        long colorHex = [TYDKidInfo kidColorHexWithKidColorType:colorType];
        self.backgroundColor = [UIColor colorWithHex:colorHex];
        
        _colorType = colorType;
    }
}

@end
