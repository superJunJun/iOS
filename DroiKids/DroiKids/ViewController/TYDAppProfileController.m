//
//  TYDAppProfileController.m
//  DroiKids
//
//  Created by macMini_Dev on 15/9/22.
//  Copyright © 2015年 TYDTech. All rights reserved.
//

#import "TYDAppProfileController.h"

@interface TYDAppProfileController () <UIScrollViewDelegate>

@property (strong, nonatomic) NSArray *profileImageNames;
@property (strong, nonatomic) UIButton *experienceButton;

@end

@implementation TYDAppProfileController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = cBasicGreenColor;
    self.edgesForExtendedLayout = UIRectEdgeNone;
    
    [self localDataInitialize];
    [self navigationBarItemsLoad];
    [self subviewsLoad];
}


- (void)localDataInitialize
{
    self.profileImageNames = @[@"common_appProfile1", @"common_appProfile2"];
}

- (void)navigationBarItemsLoad
{
    
}

- (void)subviewsLoad
{
    NSArray *profileNames = self.profileImageNames;
    UIView *baseView = self.view;
    CGRect frame = baseView.bounds;
    
    NSInteger pageCount = profileNames.count;
    UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:frame];
    scrollView.backgroundColor = [UIColor clearColor];
    scrollView.pagingEnabled = YES;
    scrollView.showsHorizontalScrollIndicator = NO;
    scrollView.showsVerticalScrollIndicator = NO;
    scrollView.bounces = NO;
    scrollView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    scrollView.delegate = self;
    scrollView.contentSize = CGSizeMake(scrollView.width * pageCount, scrollView.height);
    [baseView addSubview:scrollView];
    
    frame = scrollView.bounds;
    for(NSInteger i = 0; i < profileNames.count; i++)
    {
        UIView *pageView = [[UIView alloc] initWithFrame:frame];
        pageView.backgroundColor = [UIColor clearColor];
        pageView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
        [scrollView addSubview:pageView];
        
        CGPoint center = pageView.innerCenter;
        NSString *imageName = profileNames[i];
        UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:imageName]];
        CGFloat scale = 1.0;
        if(imageView.width < pageView.width)
        {
            scale = pageView.width / imageView.width;
            imageView.size = CGSizeMake(imageView.width * scale, imageView.height * scale);
        }
        imageView.center = center;
        [pageView addSubview:imageView];
        
        if(profileNames.lastObject == imageName)
        {
            CGSize buttonSize = CGSizeMake(100, 30);
            CGFloat bottom = pageView.height - (pageView.height - imageView.height) * 0.5 - 80;
            UIFont *buttonFont = [UIFont boldSystemFontOfSize:16];
            if(scale > 1)
            {
                buttonSize = CGSizeMake(buttonSize.width * scale, buttonSize.height * scale);
                bottom = pageView.height - (pageView.height - imageView.height) * 0.5 - 80 * scale;
                buttonFont = [UIFont boldSystemFontOfSize:18];
            }
            UIButton *experienceButton = [[UIButton alloc] initWithImageName:@"common_experienceBtn" highlightedImageName:@"common_experienceBtnH" capInsets:UIEdgeInsetsMake(5, 5, 5, 5) givenButtonSize:buttonSize title:@"知道了" titleFont:buttonFont titleColor:[UIColor whiteColor]];
            [experienceButton setTitleColor:[UIColor colorWithHex:0xffffff andAlpha:0.5] forState:UIControlStateHighlighted];
            [experienceButton addTarget:self action:@selector(experienceButtonTap:) forControlEvents:UIControlEventTouchUpInside];
            experienceButton.center = center;
            experienceButton.bottom = bottom;
            experienceButton.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
            [pageView addSubview:experienceButton];
        }
        frame.origin.x += pageView.width;
    }
}

#pragma mark - TouchEvent

- (void)experienceButtonTap:(UIButton *)sender
{
    NSLog(@"experienceButtonTap");
    if([self.delegate respondsToSelector:@selector(appProfileControllerExperienceButtonTap:)])
    {
        [self.delegate appProfileControllerExperienceButtonTap:self];
    }
}

#pragma mark - Destroy

- (void)destroyAnimated:(BOOL)animated
{
    if(animated)
    {
        __weak typeof(self) wself = self;
        [UIView animateWithDuration:0.25 animations:^{
            self.view.alpha = 0;
        } completion:^(BOOL finished){
            if(finished)
            {
                [wself.view removeFromSuperview];
                [wself removeFromParentViewController];
            }
        }];
    }
    else
    {
        self.view.alpha = 0;
        [self.view removeFromSuperview];
        [self removeFromParentViewController];
    }
}

#pragma mark - UIScrollViewDelegate

//- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
//{
//    NSInteger index = scrollView.contentOffset.x / scrollView.width;
//}

@end
