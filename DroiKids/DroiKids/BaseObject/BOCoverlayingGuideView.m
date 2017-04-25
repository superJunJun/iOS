//
//  BOCoverlayingGuideView.m
//
//  操作引导信息视图，附加在UIWindow上
//  或者附加在最上层NavigationController、TabBarController（未验证）
//

#import "BOCoverlayingGuideView.h"

@interface BOCoverlayingGuideView ()

@property (strong, nonatomic) NSMutableArray *guideViews;

@end

@implementation BOCoverlayingGuideView

- (instancetype)initWithGuideViews:(NSArray *)guideViews
{
    CGRect frame = [[UIApplication sharedApplication].delegate window].frame;
    frame.origin = CGPointZero;
    
    if(self = [super initWithFrame:frame])
    {
        self.backgroundColor = [UIColor colorWithHex:0x0 andAlpha:0.5];
        
        [super addTarget:self action:@selector(coverlayingGuideViewTap:) forControlEvents:UIControlEventTouchUpInside];
        self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        self.hidden = YES;
        
        self.guideViews = [NSMutableArray new];
        [self appendGuideViews:guideViews];
    }
    
    return self;
}

- (void)appendGuideViews:(NSArray *)guideViewArray
{
    for(id view in guideViewArray)
    {
        if([view isKindOfClass:UIView.class])//check
        {
            [self.guideViews addObject:view];
        }
    }
}

- (void)clearSubviews
{
    for(UIView *view in self.subviews)
    {
        [view removeFromSuperview];
    }
}

- (void)show
{
    if(self.guideViews.count > 0)
    {
        UIView *showedView = self.guideViews.firstObject;
        [self.guideViews removeObjectAtIndex:0];
        
        [self addSubview:showedView];
        self.hidden = NO;
        
        if(!self.superview)
        {
            UIWindow *window = [[UIApplication sharedApplication].delegate window];
            [window addSubview:self];
        }
    }
    else
    {
        [self removeFromSuperview];
    }
}

- (void)hide
{
    [self.guideViews removeAllObjects];
    [self removeFromSuperview];
}

#pragma mark - TouchEvent

- (void)coverlayingGuideViewTap:(id)sender
{
    NSLog(@"coverlayingGuideViewTap");
    
    [self clearSubviews];
    if(self.guideViews.count > 0)
    {
        UIView *showedView = self.guideViews.firstObject;
        [self.guideViews removeObjectAtIndex:0];
        
        [self addSubview:showedView];
        self.hidden = NO;
    }
    else
    {
        [self removeFromSuperview];
    }
}

@end
