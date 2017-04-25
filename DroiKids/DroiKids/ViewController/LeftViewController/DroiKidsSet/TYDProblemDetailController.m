//
//  TYDProblemDetailController.m
//  DroiKids
//
//  Created by caiyajie on 15/9/23.
//  Copyright (c) 2015年 TYDTech. All rights reserved.
//

#import "TYDProblemDetailController.h"

@interface TYDProblemDetailController ()

@end

@implementation TYDProblemDetailController

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
    self.title = @"问题详情";
}

- (void)subviewsLoad
{
    CGFloat intervalY = 20;
    CGFloat intervalLeft = 17;
    UIView *baseView = self.baseView;
    
    UILabel *titleLabel = [UILabel new];
    titleLabel.text = @"问题问题问题";
    titleLabel.font = [BOAssistor defaultTextStringFontWithSize:18];
    titleLabel.textColor = [UIColor colorWithHex:0x0];
    [titleLabel sizeToFit];
    titleLabel.top = intervalY;
    titleLabel.left = intervalLeft;
    [baseView addSubview:titleLabel];
    
    UIView *lineView = [UIView new];
    lineView.size = CGSizeMake(baseView.width - intervalLeft, 0.5);
    lineView.backgroundColor = [UIColor colorWithHex:0xdfdfdf];
    lineView.top = titleLabel.bottom + intervalY;
    lineView.left = intervalLeft;
    [baseView addSubview:lineView];
    
    UILabel *detailTitleLabel = [UILabel new];
    detailTitleLabel.text = @"    描述描述描述描述描述描述描述描述描述描述描述描述";
    detailTitleLabel.font = [BOAssistor defaultTextStringFontWithSize:15];
    detailTitleLabel.textColor = [UIColor colorWithHex:0xaaaaaa];
    detailTitleLabel.numberOfLines = 0;
    detailTitleLabel.lineBreakMode = NSLineBreakByWordWrapping;
    CGFloat detailTitleLabelHeight = [BOAssistor string:detailTitleLabel.text sizeWithFont:detailTitleLabel.font constrainedToWidth:(baseView.width - 2 * intervalLeft) lineBreakMode:NSLineBreakByWordWrapping].height;
    detailTitleLabel.size = CGSizeMake(baseView.width - 2 * intervalLeft , detailTitleLabelHeight);
    detailTitleLabel.top = lineView.bottom + intervalY;
    detailTitleLabel.left = intervalLeft;
    [baseView addSubview:detailTitleLabel];
    
    UIImageView *imageView = [UIImageView new];
    imageView.size  = CGSizeMake(baseView.width - 2 * intervalLeft , 125);
    imageView.top = detailTitleLabel.bottom + intervalY;
    imageView.left = intervalLeft;
    imageView.backgroundColor = [UIColor lightGrayColor];
    [baseView addSubview:imageView];
    
    UILabel *detailBottomLabel = [UILabel new];
    detailBottomLabel.text = @"    描述描述描述描述描述描述描述描述描述描述描述描述描述描述描述描述描述描述描述描述描述描述描述描述";
    detailBottomLabel.font = [BOAssistor defaultTextStringFontWithSize:15];
    detailBottomLabel.textColor = [UIColor colorWithHex:0xaaaaaa];
    detailBottomLabel.numberOfLines = 0;
    detailBottomLabel.lineBreakMode = NSLineBreakByWordWrapping;
    CGFloat bottomLabelHeight = [BOAssistor string:detailBottomLabel.text sizeWithFont:detailBottomLabel.font constrainedToWidth:(baseView.width - 2 * intervalLeft) lineBreakMode:NSLineBreakByWordWrapping].height;
    detailBottomLabel.size = CGSizeMake(baseView.width - 2 * intervalLeft , bottomLabelHeight);
    detailBottomLabel.top = imageView.bottom + intervalY;
    detailBottomLabel.left = intervalLeft;
    [baseView addSubview:detailBottomLabel];
    baseView.height = detailBottomLabel.bottom;
    self.baseViewBaseHeight = baseView.bottom;
}

@end
