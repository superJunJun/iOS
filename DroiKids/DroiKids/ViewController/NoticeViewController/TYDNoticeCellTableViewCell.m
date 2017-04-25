//
//  TYDNoticeCellTableViewCell.m
//  DroiKids
//
//  Created by superjunjun on 15/9/1.
//  Copyright (c) 2015年 TYDTech. All rights reserved.
//

#import "TYDNoticeCellTableViewCell.h"
#import "TYDDataCenter.h"

#define aNoticeStringArray       @[@"未接来电",@"手表电量低", @"解除绑定", @"绑定成功", @"绑定失败", @"超出了电子栅栏", @"进入了电子栅栏"]

@implementation TYDNoticeCellTableViewCell

- (void)awakeFromNib
{
    // Initialization code
    _search = [[AMapSearchAPI alloc] initWithSearchKey:sGaodeMapSDKAppKey Delegate:self];

    self.avatarImageView.layer.cornerRadius = self.avatarImageView.size.width / 2;
    self.avatarImageView.layer.masksToBounds = YES;
    UIImageView *redImageView = [UIImageView new];
    redImageView.topRight = self.avatarImageView.topRight;
    [redImageView sizeToFit];
    redImageView.hidden = YES;
    [self.contentView addSubview:redImageView];
    self.redImageView = redImageView;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setMessageInfo:(TYDKidMessageInfo *)messageInfo
{
    NSData *data = [messageInfo.messageContent dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
    NSDictionary *contentDic = dic[@"content"];
    NSArray *kidArray = [[TYDDataCenter defaultCenter]kidInfoList];
    NSInteger infoType = messageInfo.infoType.integerValue;
    
    self.noticeTimeLabel.text = [BOTimeStampAssistor getHourStringWithTimeStamp:messageInfo.infoCreateTime.integerValue];
    NSNumber *watchID = contentDic[@"watchid"];
    if(watchID)
    {
        for(TYDKidInfo *kidInfo in kidArray)
        {
            if(kidInfo.watchID.integerValue == watchID.integerValue)
            {
                if(kidInfo.kidAvatarPath.length > 0)
                {
                    if(kidInfo.kidGender.integerValue == TYDKidGenderTypeBoy)
                    {
                        NSURL *avatarUrl = [[NSURL alloc]initWithString:kidInfo.kidAvatarPath];
                        [self.avatarImageView setImageWithURL:avatarUrl placeholderImage:[UIImage imageNamed:@"main_left_babyMale"]];
                    }
                    else
                    {
                        NSURL *avatarUrl = [[NSURL alloc]initWithString:kidInfo.kidAvatarPath];
                        [self.avatarImageView setImageWithURL:avatarUrl placeholderImage:[UIImage imageNamed:@"main_left_babyFemale"]];
                    }
                }

            }
        }
    }
   
    self.avatarImageView.image = [UIImage imageNamed:@"main_left_babyMale"];
    if(infoType == 103014 || infoType == 103015 || infoType == 103016)
    {
        if(messageInfo.messageUnreadFlag.integerValue == 0)
        {
            self.redImageView.hidden = NO;
        }
    }
    switch(infoType)
    {
        case 103011:
        {
            // 获取到手表电量
            self.noticeLocationLabel.text = @"请及时充电";
            self.noticeTypeLabel.text = aNoticeStringArray[1];
            self.accessoryType = UITableViewCellAccessoryNone;
            break;
        }
        case 103014:
        {
            // 未接来电
            CLLocationCoordinate2D coord = CLLocationCoordinate2DMake([contentDic[@"latitude"] doubleValue], [contentDic[@"longitude"] doubleValue]);
            [self clickReverseGeoCode:coord];
//            self.noticeLocationLabel.text = [NSString stringWithFormat:@"位置:%@",];
            self.noticeTypeLabel.text = aNoticeStringArray[0];
            self.accessoryType = UITableViewCellAccessoryNone;
            break;
        }
        case 103020:
        {
            //绑定成功
            NSNumber *watchID = contentDic[@"watchid"];
            for(TYDKidInfo *kidInfo in kidArray)
            {
                if(kidInfo.watchID.integerValue == watchID.integerValue)
                {
                    self.noticeLocationLabel.text = [NSString stringWithFormat:@"与%@绑定成功",kidInfo.kidName];
                }
            }
            self.noticeTypeLabel.text = aNoticeStringArray[3];
            self.accessoryType = UITableViewCellAccessoryNone;
            break;
        }
        case 103021: case 103022:
        {
            //绑定失败
            self.noticeLocationLabel.text = @"绑定失败";
            self.noticeTypeLabel.text = aNoticeStringArray[4];
            self.accessoryType = UITableViewCellAccessoryNone;
            break;
        }
        case 103004: case 103007:
        {
            //解绑成功
            NSDictionary *userDic = contentDic[@"user"];
            self.noticeLocationLabel.text = [NSString stringWithFormat:@"%@与%@解除了绑定关系",userDic[@"description"], userDic[@"userName"]];
            self.noticeTypeLabel.text = aNoticeStringArray[2];
            self.accessoryType = UITableViewCellAccessoryNone;
            break;
        }
        case 103015:
        {
            //出围栏
            NSNumber *childId = contentDic[@"childid"];
            for(TYDKidInfo *kidInfo in kidArray)
            {
                if(kidInfo.kidID.integerValue == childId.integerValue)
                {
                    self.noticeTypeLabel.text = [NSString stringWithFormat:@"%@超出了电子围栏",kidInfo.kidName];
                }
            }
            CLLocationCoordinate2D coord = CLLocationCoordinate2DMake([contentDic[@"latitude"] doubleValue], [contentDic[@"longitude"] doubleValue]);
            [self clickReverseGeoCode:coord];
            self.accessoryType = UITableViewCellAccessoryNone;
            break;
        }
        case 103016:
        {
            //进围栏
            NSNumber *childId = contentDic[@"childid"];
            for(TYDKidInfo *kidInfo in kidArray)
            {
                if(kidInfo.kidID.integerValue == childId.integerValue)
                {
                    self.noticeTypeLabel.text = [NSString stringWithFormat:@"%@进入了电子围栏",kidInfo.kidName];
                }
            }
            CLLocationCoordinate2D coord = CLLocationCoordinate2DMake([contentDic[@"latitude"] doubleValue], [contentDic[@"longitude"] doubleValue]);
            [self clickReverseGeoCode:coord];
            self.accessoryType = UITableViewCellAccessoryNone;
            break;
        }
          default:
            break;
    }
//    if(messageInfo.messageContent.length > 0)
//    {
//        self.accessoryType = UITableViewCellAccessoryDetailDisclosureButton;
//    }
//    else
//    {
//        self.accessoryType = UITableViewCellAccessoryNone;
//    }
}

#pragma mark - MAGeoCodeSearchDelegate

//获取反编码状态
-(void)clickReverseGeoCode:(CLLocationCoordinate2D )coordinate
{
    //构造AMapReGeocodeSearchRequest对象，location为必选项，radius为可选项
    AMapReGeocodeSearchRequest *regeoRequest = [[AMapReGeocodeSearchRequest alloc] init];
    regeoRequest.searchType = AMapSearchType_ReGeocode;
    regeoRequest.location = [AMapGeoPoint locationWithLatitude:coordinate.latitude longitude:coordinate.longitude];
    regeoRequest.radius = 10000;
    regeoRequest.requireExtension = YES;
    //发起正向地理编码
    [_search AMapReGoecodeSearch: regeoRequest];
}

//实现逆地理编码的回调函数
- (void)onReGeocodeSearchDone:(AMapReGeocodeSearchRequest *)request response:(AMapReGeocodeSearchResponse *)response
{
    if(response.regeocode != nil)
    {
        //获取起始位置
        AMapAddressComponent *addressComponent = response.regeocode.addressComponent;
//        NSInteger index = [request.poiIdFilter integerValue];
        NSString *location = [NSString stringWithFormat:@"%@%@%@号", addressComponent.district, addressComponent.streetNumber.street, addressComponent.streetNumber.number];
        self.noticeLocationLabel.text = [NSString stringWithFormat:@"位置:%@",location];
    }
}


@end
