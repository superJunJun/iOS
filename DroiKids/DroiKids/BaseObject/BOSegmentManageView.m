//
//  BOSegmentManageView.m
//

#import "BOSegmentManageView.h"

@interface BOSegmentManageView () <BOSegmentedViewDelegate>

@property (strong, nonatomic) BOSegmentedView *segmentedView;
@property (strong, nonatomic) UIScrollView *scrollView;

@property (nonatomic) BOOL isScrollToSwitchView;

@end

@implementation BOSegmentManageView

- (instancetype)initWithSegmentedView:(BOSegmentedView *)segmentedView
                         containViews:(NSArray *)containedViews
                        superviewSize:(CGSize)superviewSize
                 isScrollToSwitchView:(BOOL)isScrollToSwitchView
{
    if(self = [super init])
    {
        self.backgroundColor = [UIColor clearColor];
        self.size = superviewSize;
        self.isScrollToSwitchView = isScrollToSwitchView;
        
        CGPoint center = self.innerCenter;
        segmentedView.delegate = self;
        segmentedView.center = center;
        segmentedView.top = 0;
        
        [self addSubview:segmentedView];
        
        CGRect frame = CGRectMake(0, segmentedView.bottom, superviewSize.width, superviewSize.height - segmentedView.height);
        UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:frame];
        scrollView.backgroundColor = [UIColor clearColor];
        scrollView.contentSize = frame.size;
        scrollView.pagingEnabled = YES;
        scrollView.showsHorizontalScrollIndicator = NO;
        scrollView.showsVerticalScrollIndicator = NO;
        scrollView.scrollEnabled = YES;
        scrollView.bounces = NO;
        scrollView.autoresizesSubviews = YES;
        scrollView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
        [self addSubview:scrollView];
        
        frame = scrollView.bounds;
        for(int i = 0; i < segmentedView.countOfSegments; i++)
        {
            UIView *subview = nil;
            if(i < containedViews.count)
            {
                subview = containedViews[i];
                subview.frame = frame;
            }
            else
            {
                subview = [[UIView alloc] initWithFrame:frame];
                subview.backgroundColor = [UIColor clearColor];
            }
            [scrollView addSubview:subview];
            frame.origin.x += frame.size.width;
        }
        scrollView.contentSize = CGSizeMake(scrollView.width * segmentedView.countOfSegments, scrollView.height);
        scrollView.contentOffset = CGPointZero;
        
        _indexOfShowedView = 0;
        self.segmentedView = segmentedView;
        self.scrollView = scrollView;
    }
    return self;
}

- (void)setContainedView:(UIView *)containedView atIndex:(NSUInteger)index
{
    if(index < self.scrollView.subviews.count)
    {
        UIView *replacedView = self.scrollView.subviews[index];
        [replacedView removeFromSuperview];
        containedView.frame = replacedView.frame;
        [self.scrollView insertSubview:containedView atIndex:index];
    }
}

- (void)showContainedViewAtIndex:(NSUInteger)index animated:(BOOL)animated
{
    if(index < self.segmentedView.countOfSegments)
    {
        self.segmentedView.selectedSegmentIndex = index;
        
        [self.scrollView setContentOffset:CGPointMake(self.scrollView.width * index, 0) animated:animated];
    }
}

- (UIView *)showedView
{
    UIView *view = nil;
    if(self.indexOfShowedView < self.scrollView.subviews.count)
    {
        view = self.scrollView.subviews[self.indexOfShowedView];
    }
    return view;
}

#pragma mark - OverrideSettingMethod

- (void)setIndexOfShowedView:(NSUInteger)index
{
    if(_indexOfShowedView != index
       && index < self.scrollView.subviews.count)
    {
        _indexOfShowedView = index;
        [self showContainedViewAtIndex:index animated:NO];
    }
}

#pragma mark - BOSegmentedViewDelegate

- (void)segmentedView:(BOSegmentedView *)segmentedView valueChanged:(NSUInteger)value
{
    _indexOfShowedView = value;
    [self showContainedViewAtIndex:value animated:self.isScrollToSwitchView];
    if([self.delegate respondsToSelector:@selector(segmentManageView:didShowView:indexOfView:)])
    {
        [self.delegate segmentManageView:self didShowView:self.scrollView.subviews[value] indexOfView:value];
    }
}


@end
