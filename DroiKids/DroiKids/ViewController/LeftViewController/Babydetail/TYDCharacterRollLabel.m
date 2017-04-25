//
//  TYDCharacterRollLabel.m
//  DroiKids
//
//  Created by wangchao on 15/10/8.
//  Copyright © 2015年 TYDTech. All rights reserved.
//  http://blog.sina.com.cn/s/blog_7c45221901014ezr.html

#import "TYDCharacterRollLabel.h"

#define IOS_VER ([[[UIDevice currentDevice] systemVersion] floatValue])

#define kAnimationKey       @"scrollAnimation"

@interface TYDCharacterRollLabel ()
{
    CFTimeInterval _pausedTime;
    BOOL _isRight;
    BOOL _isAnimationRun;
    CFTimeInterval _startTime;
}

@property (nonatomic, weak) UILabel *label;
@property (nonatomic) CABasicAnimation *leftScrollAnimation;
@property (nonatomic) CABasicAnimation *rightScrollAnimation;

@end


@implementation TYDCharacterRollLabel

#pragma mark - Init

- (instancetype)init
{
    if(self = [super init])
    {
        [self configLabel];
    }
    
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if(self = [super initWithCoder:aDecoder])
    {
        [self configLabel];
    }
    
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    if(self = [super initWithFrame:frame])
    {
        [self configLabel];
    }
    
    return self;
}

- (void)configLabel
{
    UILabel *label = [[UILabel alloc] init];
    label.textAlignment = NSTextAlignmentCenter;
    _label = label;
    [self addSubview:label];
    self.clipsToBounds = YES;
}

#pragma mark - RollLabelProperty

- (void)setGestureEnable:(BOOL)gestureEnable
{
    _gestureEnable = gestureEnable;
    
    self.userInteractionEnabled = NO;
}

- (void)setBounds:(CGRect)bounds
{
    super.bounds = bounds;
    
    if (_label)
    {
        [self calcLabelFrame];
        [self startAnimation];
    }
}

- (void)setTime:(CGFloat)time
{
    _time = time;
    if(time <= 0.01)
    {
        self.type = CharacterRollLabelBan;
    }
    else
    {
        self.leftScrollAnimation.duration = time;
        self.rightScrollAnimation.duration = time;
        
        [self startAnimation];
    }
}

- (void)setType:(CharacterRollLabelType)type
{
    _type = type;
    switch(type)
    {
        case CharacterRollLabelRepeat:
            [self startAnimation];
            break;
            
        case CharacterRollLabelClick:
            [self stopAnimation];
            break;
            
        case CharacterRollLabelBan:
            [self stopAnimation];
            break;
            
        default:
            _type = CharacterRollLabelBan;
            [self startAnimation];
            break;
    }
}

- (void)setSize:(CGSize)size
{
    super.size = size;
    
    if (_label)
    {
        [self calcLabelFrame];
        [self startAnimation];
    }
}

#pragma mark - Util

-(void)calcLabelFrame
{
    [self.label sizeToFit];
    
    if(self.bounds.size.width < self.label.bounds.size.width)
    {
        self.label.frame = CGRectMake(0, (self.height - self.label.height) / 2, self.label.width + 10, self.label.height);
        
        self.leftScrollAnimation = [self creadAnimation:YES];
        self.rightScrollAnimation = [self creadAnimation:NO];
    }
    else
    {
        self.label.frame = self.bounds;
        
        self.leftScrollAnimation = nil;
        self.rightScrollAnimation = nil;
    }
}

#pragma mark - Animation

- (CABasicAnimation *)creadAnimation:(BOOL)isRight
{
    
    NSValue *leftValue = [NSValue valueWithCGPoint:self.label.center];
    NSValue *rightValue = [NSValue valueWithCGPoint:CGPointMake(self.label.center.x + (self.frame.size.width - self.label.frame.size.width), self.label.center.y)];
    
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"position"];
    animation.fromValue = isRight ? leftValue : rightValue;
    animation.toValue = isRight ? rightValue : leftValue;
    animation.duration = self.time;
    animation.timingFunction = [CAMediaTimingFunction functionWithName: kCAMediaTimingFunctionEaseInEaseOut];
    animation.removedOnCompletion = NO;
    animation.fillMode = kCAFillModeForwards;
    animation.delegate = self;
    
    return animation;
}

- (void)startAnimation
{
    if(self.time < 0.1
        || self.type == CharacterRollLabelBan
        || self.leftScrollAnimation == nil
        || self.rightScrollAnimation == nil)
    {
        return;
    }
    
    _isAnimationRun = YES;
    [self.label.layer addAnimation:_isRight ? self.rightScrollAnimation : self.leftScrollAnimation forKey:kAnimationKey];
    _startTime = [self.label.layer convertTime:CACurrentMediaTime() fromLayer:nil];
}

- (void)stopAnimation
{
    [self.label.layer removeAnimationForKey:kAnimationKey];
}

- (void)suspendAnimation
{
    _pausedTime = [self.label.layer convertTime:CACurrentMediaTime() fromLayer:nil];
    
    self.label.layer.speed = 0.0;
    self.label.layer.timeOffset = _pausedTime;
}

- (void)moveAnimation:(CFTimeInterval)time
{
    _pausedTime += time;
    
    if(_pausedTime < _startTime)
    {
        _pausedTime = _startTime;
    }
    else if(_pausedTime > _startTime + self.time)
    {
        _pausedTime = _startTime + self.time;
    }
    
    self.label.layer.timeOffset = _pausedTime;
}

- (void)continueAnimation
{
    self.label.layer.speed = 1.0;
    self.label.layer.timeOffset = 0.0;
    self.label.layer.beginTime = 0.0;
    CFTimeInterval timeSincePause = [self.label.layer convertTime:CACurrentMediaTime() fromLayer:nil] - _pausedTime;
    self.label.layer.beginTime = timeSincePause;
}


- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag
{
    if(flag)
    {
        _isRight = !_isRight;
        if(self.type == CharacterRollLabelRepeat)
        {
            [self startAnimation];
        }
        else if(self.type == CharacterRollLabelClick)
        {
            if(_isRight)
            {
                [self startAnimation];
            }
            else
            {
                _isAnimationRun = NO;
            }
        }
    }
    else
    {
        _isAnimationRun = NO;
    }
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    if(self.type == CharacterRollLabelRepeat)
    {
        [self suspendAnimation];
    }
    else if(self.type == CharacterRollLabelClick)
    {
        if(!_isAnimationRun)
        {
            [self startAnimation];
        }
        
        [self suspendAnimation];
    }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    if(self.type == CharacterRollLabelRepeat
        || self.type == CharacterRollLabelClick)
    {
        [self continueAnimation];
    }
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    if(self.type == CharacterRollLabelRepeat
        || self.type == CharacterRollLabelClick)
    {
        UITouch *touch = touches.anyObject;
        CGFloat x1 = [touch locationInView:self].x;
        CGFloat x2 = [touch previousLocationInView:self].x;
        CFTimeInterval moveTime = (_isRight ? x1 - x2 : x2 - x1) / (self.label.bounds.size.width - self.bounds.size.width) * self.time;
        
        [self moveAnimation:moveTime];
    }
}

@end

@implementation TYDCharacterRollLabel (UILabelProperty)

#pragma mark - UILabelProperty

- (NSString *)text
{
    return _label.text;
}

- (void)setText:(NSString *)text
{
    _label.text = text;
    
    [self calcLabelFrame];
    [self startAnimation];
}

- (UIFont *)font
{
    return _label.font;
}

- (void)setFont:(UIFont *)font
{
    _label.font = font;
    
    [self calcLabelFrame];
}

- (UIColor *)textColor
{
    return _label.textColor;
}

- (void)setTextColor:(UIColor *)textColor
{
    _label.textColor = textColor;
}

- (UIColor *)shadowColor
{
    return _label.shadowColor;
}

- (void)setShadowColor:(UIColor *)shadowColor
{
    _label.shadowColor = shadowColor;
}

- (CGSize)shadowOffset
{
    return _label.shadowOffset;
}

- (void)setShadowOffset:(CGSize)shadowOffset
{
    _label.shadowOffset = shadowOffset;
}

- (NSTextAlignment)textAlignment
{
    return _label.textAlignment;
}

- (void)setTextAlignment:(NSTextAlignment)textAlignment
{
    _label.textAlignment = textAlignment;
}

- (NSLineBreakMode)lineBreakMode
{
    return _label.lineBreakMode;
}

- (void)setLineBreakMode:(NSLineBreakMode)lineBreakMode
{
    _label.lineBreakMode = lineBreakMode;
}

- (NSAttributedString *)attributedText
{
    return _label.attributedText;
}

- (void)setAttributedText:(NSAttributedString *)attributedText
{
    _label.attributedText = attributedText;
}

- (UIColor *)highlightedTextColor
{
    return _label.highlightedTextColor;
}

- (void)setHighlightedTextColor:(UIColor *)highlightedTextColor
{
    _label.highlightedTextColor = highlightedTextColor;
}

- (BOOL)isHighlighted
{
    return _label.isHighlighted;
}

- (void)setHighlighted:(BOOL)highlighted
{
    _label.highlighted = highlighted;
}

- (BOOL)isEnabled
{
    return _label.isEnabled;
}

- (void)setEnabled:(BOOL)enabled
{
    _label.enabled = enabled;
}

- (NSInteger)numberOfLines
{
    return _label.numberOfLines;
}

- (void)setNumberOfLines:(NSInteger)numberOfLines
{
    _label.numberOfLines = numberOfLines;
}

- (BOOL)adjustsFontSizeToFitWidth
{
    return _label.adjustsFontSizeToFitWidth;
}

- (void)setAdjustsFontSizeToFitWidth:(BOOL)adjustsFontSizeToFitWidth
{
    _label.adjustsFontSizeToFitWidth = adjustsFontSizeToFitWidth;
}

- (UIBaselineAdjustment)baselineAdjustment
{
    return _label.baselineAdjustment;
}

- (void)setBaselineAdjustment:(UIBaselineAdjustment)baselineAdjustment
{
    _label.baselineAdjustment = baselineAdjustment;
}

- (CGFloat)minimumScaleFactor
{
    return _label.minimumScaleFactor;
}

- (void)setMinimumScaleFactor:(CGFloat)minimumScaleFactor
{
    _label.minimumScaleFactor = minimumScaleFactor;
}

- (CGFloat)preferredMaxLayoutWidth
{
    return _label.preferredMaxLayoutWidth;
}

- (void)setPreferredMaxLayoutWidth:(CGFloat)preferredMaxLayoutWidth
{
    _label.preferredMaxLayoutWidth = preferredMaxLayoutWidth;
}

#pragma mark -UILabelMethod

- (CGRect)textRectForBounds:(CGRect)bounds limitedToNumberOfLines:(NSInteger)numberOfLines
{
    return [_label textRectForBounds:bounds limitedToNumberOfLines:numberOfLines];
}

- (void)drawTextInRect:(CGRect)rect
{
    [_label drawTextInRect:rect];
}

@end
