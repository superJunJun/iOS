//
//  BOSegmentedView.h
//

#import <UIKit/UIKit.h>

@class BOSegmentedView;
@protocol BOSegmentedViewDelegate <NSObject>
@optional
- (void)segmentedView:(BOSegmentedView *)segmentedView valueChanged:(NSUInteger)value;
@end

@interface BOSegmentedView : UIView

@property (nonatomic, readonly) NSUInteger countOfSegments;
@property (nonatomic) NSUInteger selectedSegmentIndex;
@property (assign, nonatomic) id<BOSegmentedViewDelegate> delegate;

- (instancetype)initWithFrame:(CGRect)frame
                       titles:(NSArray *)titles
                    titleFont:(UIFont *)titleFont
             titleNormalColor:(UIColor *)titleNormalColor
           titleSelectedColor:(UIColor *)titleSelectedColor
          titleLabelVerOffset:(CGFloat)titleLabelVerOffset
            indicatorBarColor:(UIColor *)indicatorBarColor
              backgroundColor:(UIColor *)backgroundColor
        segmentSeparatorImage:(UIImage *)segmentSeparatorImage
                 cornerRadius:(CGFloat)cornerRadius;

@end
