//
//  TYDLeftDrawerTableViewCell.m
//  DroiKids
//
//  Created by superjunjun on 15/8/24.
//  Copyright (c) 2015年 TYDTech. All rights reserved.
//

#import "TYDLeftDrawerTableViewCell.h"

@implementation TYDLeftDrawerTableViewCell

- (void)awakeFromNib
{
    self.separetorView.height = 0.5;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
}

@end
