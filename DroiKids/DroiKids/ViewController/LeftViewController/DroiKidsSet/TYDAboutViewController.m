//
//  TYDAboutViewController.m
//  DroiKids
//
//  Created by caiyajie on 15/8/14.
//  Copyright (c) 2015年 superjunjun. All rights reserved.
//

#import "TYDAboutViewController.h"

@interface TYDAboutViewController ()

@end

@implementation TYDAboutViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self localDataInitialize];
    [self navigationBarItemsLoad];
    [self subviewsLoad];
}

- (void)localDataInitialize
{
    
}

- (void)navigationBarItemsLoad
{
    self.title = @"关于";
}

- (void)subviewsLoad
{
    
}

@end
