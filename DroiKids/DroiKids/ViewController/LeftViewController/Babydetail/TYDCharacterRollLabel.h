//
//  TYDCharacterRollLabel.h
//  DroiKids
//
//  Created by wangchao on 15/10/8.
//  Copyright © 2015年 TYDTech. All rights reserved.
//  http://blog.sina.com.cn/s/blog_7c45221901014ezr.html

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, CharacterRollLabelType)
{
    CharacterRollLabelRepeat = 0,
    CharacterRollLabelClick,
    CharacterRollLabelBan,
};

@interface TYDCharacterRollLabel : UIView

@property (assign, nonatomic) IBInspectable BOOL gestureEnable;
@property (assign, nonatomic) IBInspectable CharacterRollLabelType type;
@property (assign, nonatomic) IBInspectable CGFloat time;
@property (assign, nonatomic) CGSize size;

-(void)startAnimation;

-(void)stopAnimation;

@end

@interface TYDCharacterRollLabel (UILabelProperty)

@property (nonatomic) IBInspectable NSString *text;
@property (nonatomic) IBInspectable UIFont *font;
@property (nonatomic) IBInspectable UIColor *textColor;
@property (nonatomic) UIColor *shadowColor;
@property (nonatomic) CGSize shadowOffset;
@property (nonatomic) IBInspectable NSTextAlignment textAlignment;
@property (nonatomic) NSLineBreakMode lineBreakMode;
@property (nonatomic) NSAttributedString *attributedText NS_AVAILABLE_IOS(6_0);
@property (nonatomic) UIColor *highlightedTextColor;
@property (nonatomic, getter = isHighlighted) BOOL highlighted;
@property (nonatomic, getter = isEnabled) BOOL enabled;
@property (nonatomic) NSInteger numberOfLines;
@property (nonatomic) BOOL adjustsFontSizeToFitWidth;
@property (nonatomic) UIBaselineAdjustment baselineAdjustment;
@property (nonatomic) CGFloat minimumScaleFactor NS_AVAILABLE_IOS(6_0);
@property (nonatomic) CGFloat preferredMaxLayoutWidth NS_AVAILABLE_IOS(6_0);

- (CGRect)textRectForBounds:(CGRect)bounds limitedToNumberOfLines:(NSInteger)numberOfLines;

- (void)drawTextInRect:(CGRect)rect;

@end
