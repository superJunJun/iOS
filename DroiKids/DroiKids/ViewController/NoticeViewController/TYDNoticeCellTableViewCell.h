//
//  TYDNoticeCellTableViewCell.h
//  DroiKids
//
//  Created by superjunjun on 15/9/1.
//  Copyright (c) 2015年 TYDTech. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TYDKidMessageInfo.h"
#import <AMapSearchKit/AMapSearchAPI.h>
#import <CoreLocation/CoreLocation.h>

@interface TYDNoticeCellTableViewCell : UITableViewCell <AMapSearchDelegate>

@property (strong, nonatomic) TYDKidMessageInfo *messageInfo;
@property (strong, nonatomic) AMapSearchAPI       *search;
@property (strong, nonatomic) UIImageView         *redImageView;

@property (weak, nonatomic) IBOutlet UIImageView  *avatarImageView;
@property (weak, nonatomic) IBOutlet UILabel      *noticeTypeLabel;
@property (weak, nonatomic) IBOutlet UILabel      *noticeLocationLabel;
@property (weak, nonatomic) IBOutlet UILabel      *noticeTimeLabel;

@end
