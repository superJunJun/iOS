//
//  BOCircleGaugeView.m
//
//  仿改自CHCircleGaugeView

#import "BOCircleGaugeView.h"
#import <QuartzCore/QuartzCore.h>

#define nValueDefault                       0
#define nCircleWidthMin                     1.0
#define nCircleViewRadiusMin                20
#define nCircleAnimationDuration            0.5
#define nCircleWidthDefaultWidth            16
#define cTrackTintColorDefaultColor         [UIColor blackColor]
#define cGaugeTintColorDefaultColor         [UIColor redColor]

@interface BOCircleGaugeView ()

@property (strong, nonatomic) UILabel *valueTextLabel;
@property (strong, nonatomic) CAShapeLayer *trackCircleLayer;
@property (strong, nonatomic) CAShapeLayer *gaugeCircleLayer;

@end

@implementation BOCircleGaugeView

- (instancetype)initWithRadius:(CGFloat)radius
{
    CGFloat width = MAX(nCircleViewRadiusMin, radius * 2);
    CGRect frame = CGRectMake(0.0, 0.0, width, width);
    if(self = [super initWithFrame:frame])
    {
        self.backgroundColor = [UIColor clearColor];
        _trackTintColor = cTrackTintColorDefaultColor;
        _gaugeTintColor = cGaugeTintColorDefaultColor;
        _circleWidth = nCircleWidthDefaultWidth;
        _textColor = [UIColor whiteColor];
        _numberFont = [UIFont systemFontOfSize:16];
        _percentSignFont = [UIFont systemFontOfSize:16];
        
        [self.layer addSublayer:self.trackCircleLayer];
        [self.layer addSublayer:self.gaugeCircleLayer];
        [self addSubview:self.valueTextLabel];
        self.value = nValueDefault;
    }
    return self;
}

#pragma mark - OverridePropertyMethod

- (void)setTrackTintColor:(UIColor *)trackTintColor
{
    if(_trackTintColor != trackTintColor)
    {
        _trackTintColor = trackTintColor;
        self.trackCircleLayer.strokeColor = trackTintColor.CGColor;
    }
}

- (void)setGaugeTintColor:(UIColor *)gaugeTintColor
{
    if(_gaugeTintColor != gaugeTintColor)
    {
        _gaugeTintColor = gaugeTintColor;
        self.gaugeCircleLayer.strokeColor = gaugeTintColor.CGColor;
    }
}

- (void)setCircleWidth:(CGFloat)circleWidth
{
    circleWidth = MAX(nCircleWidthMin, circleWidth);
    if(_circleWidth != circleWidth) {
        
        _circleWidth = circleWidth;
        self.trackCircleLayer.lineWidth = circleWidth;
        self.gaugeCircleLayer.lineWidth = circleWidth;
        [self.layer layoutSublayers];
    }
    _circleWidth = circleWidth;
}

- (void)setValue:(CGFloat)value
{
    [self setValue:value animated:NO];
}

- (void)setValue:(CGFloat)value animated:(BOOL)animated
{
    NSLog(@"setValue animated");
    if(_value != value)
    {
        [self willChangeValueForKey:NSStringFromSelector(@selector(value))];
        value = MIN(1.0f, (MAX(0.0f, value)));
        [self updateGaugeWithValue:value animated:animated];
        _value = value;
        [self didChangeValueForKey:NSStringFromSelector(@selector(value))];
        [self refreshValueText];
    }
}

- (UILabel *)valueTextLabel
{
    if(!_valueTextLabel)
    {
        CGRect frame = self.bounds;
        UILabel *label = [[UILabel alloc] initWithFrame:frame];
        label.backgroundColor = [UIColor clearColor];
        label.font = [UIFont systemFontOfSize:10];
        label.textColor = [UIColor whiteColor];
        label.textAlignment = NSTextAlignmentCenter;
        //label.text = @"0.0%";
        _valueTextLabel = label;
    }
    return _valueTextLabel;
}

- (void)setNumberFont:(UIFont *)numberFont percentSignFont:(UIFont *)percentSignFont
{
    self.numberFont = numberFont;
    self.percentSignFont = percentSignFont;
}

- (void)setTextColor:(UIColor *)textColor
{
    if(_textColor != textColor)
    {
        _textColor = textColor;
        [self refreshValueText];
    }
}

- (void)setPercentSignFont:(UIFont *)percentSignFont
{
    if(_percentSignFont != percentSignFont)
    {
        _percentSignFont = percentSignFont;
        [self refreshValueText];
    }
}

- (void)setNumberFont:(UIFont *)numberFont
{
    if(_numberFont != numberFont)
    {
        _numberFont = numberFont;
        [self refreshValueText];
    }
}

#pragma mark - ValueStringMake

- (void)refreshValueText
{
    self.valueTextLabel.attributedText = [self valueString];
}

- (NSAttributedString *)valueString
{
    NSString *numberString = @"100";
    NSString *percentSign = @"%";
    if(self.value < 1)
    {
//        numberString = [NSString stringWithFormat:@"%.1f", self.value * 100];
        numberString = [NSString stringWithFormat:@"%.0f", self.value * 100];
    }
    
    UIFont *numberFont = self.numberFont;
    UIFont *percentSignFont = self.percentSignFont;
    UIColor *textColor = self.textColor;
    NSString *text = [numberString stringByAppendingString:percentSign];
    NSMutableAttributedString *attributedText = [[NSMutableAttributedString alloc] initWithString:text attributes:@{NSForegroundColorAttributeName:textColor,                                                            NSFontAttributeName:percentSignFont}];
    [attributedText setAttributes:@{NSFontAttributeName:numberFont} range:NSMakeRange(0, numberString.length)];
    return attributedText;
}

#pragma mark - Animation

- (void)updateGaugeWithValue:(CGFloat)value animated:(BOOL)animated
{
    BOOL previousDisableActionsValue = [CATransaction disableActions];
    [CATransaction setDisableActions:YES];
    
    self.gaugeCircleLayer.strokeEnd = value;
    if(animated)
    {
        //[self.gaugeCircleLayer removeAllAnimations];
        CABasicAnimation *pathAnimation = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
        pathAnimation.duration = nCircleAnimationDuration;
        pathAnimation.fromValue = @(self.value);
        pathAnimation.toValue = @(value);
        pathAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
        [self.gaugeCircleLayer addAnimation:pathAnimation forKey:@"strokeEndAnimation"];
    }
    
    [CATransaction setDisableActions:previousDisableActionsValue];
}

#pragma mark - CircleShape

- (CAShapeLayer *)trackCircleLayer
{
    if(!_trackCircleLayer)
    {
        CAShapeLayer *layer = [CAShapeLayer layer];
        layer.lineWidth = self.circleWidth;
        layer.fillColor = [UIColor clearColor].CGColor;
        layer.strokeColor = self.trackTintColor.CGColor;
        layer.path = [self circlePath].CGPath;
        _trackCircleLayer = layer;
    }
    return _trackCircleLayer;
}

- (CAShapeLayer *)gaugeCircleLayer
{
    if(!_gaugeCircleLayer)
    {
        CAShapeLayer *layer = [CAShapeLayer layer];
        layer.lineWidth = self.circleWidth;
        layer.fillColor = [UIColor clearColor].CGColor;
        layer.strokeColor = self.gaugeTintColor.CGColor;
        layer.strokeStart = 0.0;
        layer.strokeEnd = self.value;
        layer.path = [self circlePath].CGPath;
        _gaugeCircleLayer = layer;
    }
    return _gaugeCircleLayer;
}

- (UIBezierPath *)circlePath
{
    CGPoint center = CGPointMake(self.bounds.size.width * 0.5, self.bounds.size.height * 0.5);
    CGFloat radius = (self.bounds.size.width - self.circleWidth) * 0.5;
    CGFloat startAngle = -M_PI_2;
    CGFloat endAngle = startAngle + 2 * M_PI;
    return [UIBezierPath bezierPathWithArcCenter:center
                                          radius:radius
                                      startAngle:startAngle
                                        endAngle:endAngle
                                       clockwise:YES];
}

#pragma mark - CALayerDelegate

- (void)layoutSublayersOfLayer:(CALayer *)layer
{
    [super layoutSublayersOfLayer:layer];
    if(layer == self.layer)
    {
        UIBezierPath *path = [self circlePath];
        self.trackCircleLayer.path = path.CGPath;
        self.gaugeCircleLayer.path = path.CGPath;
    }
}

#pragma mark - KVO
// Handling KVO notifications for the value property, since
//   we're proxying with the setValue:animated: method.
+ (BOOL)automaticallyNotifiesObserversForKey:(NSString *)key
{
    if([key isEqualToString:NSStringFromSelector(@selector(value))])
    {
        return NO;
    }
    else
    {
        return [super automaticallyNotifiesObserversForKey:key];
    }
}

@end
