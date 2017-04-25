//
//  BOBottomPopupView.m
//
//  底部弹出管控视图
//

#import "BOBottomPopupView.h"

#define nAnimationDuration      0.25
#define cDefaultBgTintColor     [UIColor colorWithHex:0x0 andAlpha:0.4]

@interface BOBottomPopupView ()

@property (strong, nonatomic) UIView *customBaseView;
@property (strong, nonatomic) UIView *tintBackground;

@end

@implementation BOBottomPopupView
{
    BOOL _animationLock;
}

- (instancetype)initWithCustomViews:(NSArray *)customViews
{
    if(self = [super init])
    {
        self.backgroundColor = [UIColor clearColor];
        
        UIControl *tintBackground = [UIControl new];
        [tintBackground addTarget:self action:@selector(tapOnSpace:) forControlEvents:UIControlEventTouchUpInside];
        tintBackground.alpha = 0;
        [self addSubview:tintBackground];
        
        UIView *customBaseView = [UIView new];
        customBaseView.backgroundColor = [UIColor clearColor];
        customBaseView.clipsToBounds = YES;
        [self addSubview:customBaseView];
        
        NSMutableArray *customViewArray = [NSMutableArray new];
        for(id customViewObj in customViews)
        {
            if([customViewObj isKindOfClass:UIView.class])
            {//过滤
                UIView *view = customViewObj;
                if(view.superview)
                {
                    [view removeFromSuperview];
                }
                view.origin = CGPointZero;
                [customViewArray addObject:view];
                [customBaseView addSubview:view];
                [BOAssistor rectangleShow:view.frame withTitle:@"view.frame"];
            }
        }
        
        self.tintBackground = tintBackground;
        self.customBaseView = customBaseView;
        self.isToHideWhenTapOutSide = YES;
        self.backgroundTintColor = cDefaultBgTintColor;
        _customViews = customViewArray;
        if(customViewArray.count > 0)
        {
            self.currentVisibleCustomView = customViewArray.lastObject;
        }
        _animationLock = NO;
        self.hidden = YES;
    }
    return self;
}

#pragma mark - OverridePropertyMethod

- (void)setBackgroundColor:(UIColor *)backgroundColor
{//拦截
    backgroundColor = [UIColor clearColor];
    super.backgroundColor = backgroundColor;
}

- (void)setBackgroundTintColor:(UIColor *)color
{
    _backgroundTintColor = color;
    self.tintBackground.backgroundColor = color;
}

- (void)setCurrentVisibleCustomView:(UIView *)currentView
{
    for(UIView *view in self.customViews)
    {
        view.hidden = (view != currentView);
    }
    
    if(!currentView)
    {//nil
        self.customBaseView.frame = CGRectZero;
        _currentVisibleCustomView = nil;
        return;
    }
    
    if([self.customViews indexOfObject:currentView] != NSNotFound)
    {
        [self.customBaseView bringSubviewToFront:currentView];
        self.customBaseView.size = currentView.size;
        self.customBaseView.center = self.innerCenter;
        self.bottom = self.height;
        _currentVisibleCustomView = currentView;
    }
}

#pragma mark - TouchEvent

- (void)tapOnSpace:(UIControl *)sender
{
    if(self.hidden == NO && self.isToHideWhenTapOutSide)
    {
        [self bottomPopupViewHide:YES];
    }
}

#pragma mark - Animation

- (void)bottomPopupViewWillShow
{
    if([self.delegate respondsToSelector:@selector(bottomPopupViewWillShow:)])
    {
        [self.delegate bottomPopupViewWillShow:self];
    }
}

- (void)bottomPopupViewDidHidden
{
    if([self.delegate respondsToSelector:@selector(bottomPopupViewDidHidden:)])
    {
        [self.delegate bottomPopupViewDidHidden:self];
    }
}

- (void)bottomPopupViewSwitchVisibleState
{
    if(self.hidden)
    {
        [self bottomPopupViewShowAnimated];
    }
    else
    {
        [self bottomPopupViewHide:YES];
    }
}

- (void)bottomPopupViewShowAnimated
{
    if(_animationLock
       || !self.hidden
       || !self.superview)
    {
        return;
    }
    
    _animationLock = YES;
    self.hidden = NO;
    [self.superview bringSubviewToFront:self];
    self.size = self.superview.size;
    self.tintBackground.frame = self.bounds;
    self.customBaseView.center = self.innerCenter;
    self.customBaseView.top = self.height;
    
    [BOAssistor rectangleShow:self.customBaseView.frame withTitle:@"customBaseView.frame"];
    
    __weak typeof(self) wself = self;
    [self bottomPopupViewWillShow];
    [UIView animateWithDuration:nAnimationDuration
                     animations:^{
                         wself.tintBackground.alpha = 1;
                         wself.customBaseView.bottom = wself.height;
                     } completion:^(BOOL finished) {
                         _animationLock = NO;
                     }];
}

- (void)bottomPopupViewHide:(BOOL)animated
{
    if(_animationLock
       || self.hidden
       || !self.superview)
    {
        return;
    }
    
    _animationLock = YES;
    if(animated)
    {
        __weak typeof(self) wself = self;
        [UIView animateWithDuration:nAnimationDuration
                         animations:^{
                             wself.tintBackground.alpha = 0;
                             wself.customBaseView.top = wself.height;
                         } completion:^(BOOL finished) {
                             wself.hidden = YES;
                             _animationLock = NO;
                             [wself bottomPopupViewDidHidden];
                         }];
    }
    else
    {
        self.tintBackground.alpha = 0;
        self.customBaseView.top = self.height;
        self.hidden = YES;
        _animationLock = NO;
        [self bottomPopupViewDidHidden];
    }
}

@end
