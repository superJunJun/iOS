//
//  BOCircleGaugeView.h
//

#import <UIKit/UIKit.h>

@interface BOCircleGaugeView : UIView

@property (assign, nonatomic) CGFloat value;//(0.0~1.0)
@property (assign, nonatomic) CGFloat circleWidth;
@property (strong, nonatomic) UIColor *trackTintColor;
@property (strong, nonatomic) UIColor *gaugeTintColor;

@property (strong, nonatomic) UIFont *percentSignFont;
@property (strong, nonatomic) UIFont *numberFont;
@property (strong, nonatomic) UIColor *textColor;

- (instancetype)initWithRadius:(CGFloat)radius;
- (void)setValue:(CGFloat)value animated:(BOOL)animated;

@end
