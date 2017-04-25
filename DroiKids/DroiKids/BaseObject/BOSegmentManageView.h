//
//  BOSegmentManageView.h
//

#import <UIKit/UIKit.h>
#import "BOSegmentedView.h"

@class BOSegmentManageView;
@protocol BOSegmentManageViewDelegate <NSObject>
@optional
- (void)segmentManageView:(BOSegmentManageView *)segmentedView didShowView:(UIView *)view indexOfView:(NSUInteger)index;
@end

@interface BOSegmentManageView : UIView

@property (nonatomic) NSUInteger indexOfShowedView;
@property (assign, nonatomic) id<BOSegmentManageViewDelegate> delegate;

- (instancetype)initWithSegmentedView:(BOSegmentedView *)segmentedView
                         containViews:(NSArray *)containedViews
                        superviewSize:(CGSize)superviewSize
                 isScrollToSwitchView:(BOOL)isScrollToSwitchView;

- (void)setContainedView:(UIView *)containedView atIndex:(NSUInteger)index;
//- (void)sizeModified;
- (UIView *)showedView;

@end
