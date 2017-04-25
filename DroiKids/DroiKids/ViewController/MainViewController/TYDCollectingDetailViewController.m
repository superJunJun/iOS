//
//  TYDCollectingDetailViewController.m
//  DroiKids
//
//  Created by superjunjun on 15/9/10.
//  Copyright (c) 2015年 TYDTech. All rights reserved.
//

#import "TYDCollectingDetailViewController.h"
#import <MAMapKit/MAMapKit.h>
#import <AMapSearchKit/AMapSearchAPI.h>
#import "TYDHistoricalTrackViewController.h"
#import "TYDFenceViewController.h"
#import "TYDCollectingListViewController.h"
#import "SBJson.h"
#import "TYDKidTrackInfo.h"
#import "TYDEnshrineLocationInfo.h"
#import "TYDKidInfo.h"
#import "TYDDataCenter.h"
#import "BOCoordinateTransformation.h"

#define sLocationButtonTag                          1000
#define sLocationIconImageViewTag                   10000

@interface TYDCollectingDetailViewController ()<MAMapViewDelegate, AMapSearchDelegate, UIGestureRecognizerDelegate ,UIAlertViewDelegate>

@property (strong, nonatomic) MAPinAnnotationView   *myAnnotation;
@property (strong, nonatomic) AMapSearchAPI         *search;
@property (strong, nonatomic) MAPointAnnotation     *startAnnotation;
@property (strong, nonatomic) MAMapView             *mapView;
@property (strong, nonatomic) MAPolyline            *polyLine;

@property (strong, nonatomic) UILabel               *locationInfoLabel;
@property (strong, nonatomic) UILabel               *markInfoLabel;
@property (strong, nonatomic) UIButton              *collectionButton;
@property (assign, nonatomic) NSInteger             currentKidId;

@end

@implementation TYDCollectingDetailViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self localDataInitialize];
    [self navigationBarItemsLoad];
    [self subviewsLoad];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)localDataInitialize
{
    TYDKidInfo *kidInfo =  [[TYDDataCenter defaultCenter]currentKidInfo];
    self.currentKidId = [kidInfo.kidID integerValue];
}

- (void)navigationBarItemsLoad
{
    self.title = @"收藏详情";
}

- (void)subviewsLoad
{
    [self mapViewLoad];
    [self locationInfoBarLoad];
}

- (void)mapViewLoad
{
    CGRect frame = self.view.bounds;
    MAMapView *mapView = [[MAMapView alloc]initWithFrame:frame];
    //设置地图缩放级别
    [mapView setZoomLevel:16.1 animated:YES];
    _search = [[AMapSearchAPI alloc] initWithSearchKey:sGaodeMapSDKAppKey Delegate:self];
    mapView.showsCompass = NO;
    mapView.showsScale = NO;
    mapView.delegate = self;
    [self.view addSubview:mapView];
    
    CLLocationCoordinate2D coord = CLLocationCoordinate2DMake(self.kidcollectionInfo.locationLatitude.doubleValue, self.kidcollectionInfo.locationLongitude.doubleValue);
    mapView.centerCoordinate = coord;
    MAPointAnnotation *pointAnnotation = [[MAPointAnnotation alloc] init];
    pointAnnotation.coordinate = coord;
    [mapView addAnnotation:pointAnnotation];
    
    self.mapView = mapView;
}

- (void)locationInfoBarLoad
{
    CGRect frame = self.view.frame;
    NSInteger verCap = 64;
    UIView *infoBarView = [UIView new];
    infoBarView.top = self.view.bottom - 66 -verCap;
    infoBarView.left = 0;
    infoBarView.height = 66;
    infoBarView.width = self.view.width;
    infoBarView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:infoBarView];
    
    CGFloat infoBarYCenter = infoBarView.height / 2;
    NSInteger leftCap = 10;
    NSInteger buttonWidth = 30;
    
    UIImageView *locationImageView = [UIImageView new];
    locationImageView.image = [UIImage imageNamed:@"main_location_location"];
    [locationImageView sizeToFit];
    locationImageView.left = leftCap;
    locationImageView.yCenter= infoBarYCenter;
    [infoBarView addSubview:locationImageView];
    
    UILabel *markInfoLabel = [UILabel new];
    markInfoLabel.text = self.kidcollectionInfo.locationMemo;
    markInfoLabel.font = [UIFont systemFontOfSize:14.0];
    [markInfoLabel sizeToFit];
    markInfoLabel.left = locationImageView.right +leftCap;
    markInfoLabel.yCenter = infoBarYCenter - 5;
    [infoBarView addSubview:markInfoLabel];
    self.markInfoLabel = markInfoLabel;
    
    UILabel *locationInfoLabel = [UILabel new];
    locationInfoLabel.text = self.kidcollectionInfo.locationName;
    locationInfoLabel.font = [UIFont systemFontOfSize:11.0];
    [locationInfoLabel sizeToFit];
    locationInfoLabel.left = markInfoLabel.left;
    locationInfoLabel.yCenter = infoBarYCenter + 10;
    [infoBarView addSubview:locationInfoLabel];
    self.locationInfoLabel = locationInfoLabel;
   
    UIButton *collectionButton = [UIButton new];
    collectionButton.left = frame.size.width - leftCap * 2 - buttonWidth;
    collectionButton.width = collectionButton.height = buttonWidth;
    collectionButton.yCenter = infoBarYCenter;
    [collectionButton setBackgroundImage:[UIImage imageNamed:@"main_location_uncollection"] forState:UIControlStateNormal];
    [collectionButton setBackgroundImage:[UIImage imageNamed:@"main_location_collection"] forState:UIControlStateSelected];
    collectionButton.selected = YES;
    [collectionButton addTarget:self action:@selector(collectionButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    [infoBarView addSubview:collectionButton];
    self.collectionButton = collectionButton;
}

#pragma mark - Touch Event

- (void)collectionButtonClick:(UIButton *)sender
{
//    if(self.kidcollectionInfo)
//    {
//        if(sender.selected == NO)
//        {
//            UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"位置收藏成功，添加备注" message:nil delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"好的", nil];
//            alertView.alertViewStyle = UIAlertViewStyleLoginAndPasswordInput;
//            
//            UITextField *textField = [alertView textFieldAtIndex:0];
//            textField.placeholder = @"";
//            UIImageView *imageView = [UIImageView new];
//            imageView.size = CGSizeMake(10, 10);
//            imageView.image = [UIImage imageNamed:@"main_location_unlocation"];
//            textField.text = self.locationInfoLabel.text;
//            textField.leftView = imageView;
//            textField.leftViewMode = UITextFieldViewModeAlways;
//            textField.enabled = NO;
//            textField.borderStyle = UITextBorderStyleNone;
//            
//            UITextField *markTextField = [alertView textFieldAtIndex:1];
//            markTextField.placeholder = @"备注";
//            markTextField.secureTextEntry = NO;
//            [alertView show];
//        }
//        else
//        {
//            [self removeCollectionPointToServer];
//        }
//    }
//    else
//    {
//        self.noticeText = @"没有当前收藏信息";
//    }
    if(sender.selected == YES)
    {
      [self removeCollectionPointToServer];
    }
}



#pragma mark - UIAlertViewDelegate

//- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
//{
//    if(buttonIndex != alertView.cancelButtonIndex)
//    {
//        UITextField *textField=[alertView textFieldAtIndex:1];
//        self.markInfoLabel.text = textField.text;
//        [self.markInfoLabel sizeToFit];
//    }
//}
//
//- (void)updateLocationInfoBarLoad
//{
//    
//}

#pragma mark - mapOverLay

- (MAAnnotationView *)mapView:(MAMapView *)mapView viewForAnnotation:(id <MAAnnotation>)annotation
{
    if ([annotation isKindOfClass:[MAPointAnnotation class]])
    {
        static NSString *reuseIndetifier = @"annotationReuseIndetifier";
        MAAnnotationView *annotationView = (MAAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:reuseIndetifier];
        if (annotationView == nil)
        {
            annotationView = [[MAAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:reuseIndetifier];
            
            annotationView.centerOffset = CGPointMake(0, -38);
            annotationView.image = [UIImage imageNamed:@"main_location_point_big"];
            UIImageView *imageView = [[UIImageView alloc]initWithFrame:CGRectMake(5, 5, 45, 45)];
            TYDKidInfo *kidInfo = [[TYDDataCenter defaultCenter]currentKidInfo];
            if(kidInfo.kidAvatarPath.length > 0)
            {
                if(kidInfo.kidGender.integerValue == TYDKidGenderTypeBoy)
                {
                    NSURL *avatarUrl = [[NSURL alloc]initWithString:kidInfo.kidAvatarPath];
                    [imageView setImageWithURL:avatarUrl placeholderImage:[UIImage imageNamed:@"main_left_babyMale"]];
                }
                else
                {
                    NSURL *avatarUrl = [[NSURL alloc]initWithString:kidInfo.kidAvatarPath];
                    [imageView setImageWithURL:avatarUrl placeholderImage:[UIImage imageNamed:@"main_left_babyFemale"]];
                }
            }
            else if(kidInfo.kidGender.integerValue == TYDKidGenderTypeBoy)
            {
                imageView.image = [UIImage imageNamed:@"main_left_babyMale"];
            }
            else if(kidInfo.kidGender.integerValue == TYDKidGenderTypeGirl)
            {
                imageView.image = [UIImage imageNamed:@"main_left_babyFemale"];
            }
            imageView.layer.cornerRadius = imageView.width / 2;
            imageView.layer.masksToBounds = YES;
            imageView.tag = sLocationIconImageViewTag;
            [annotationView addSubview:imageView];
//            [self clickReverseGeoCode:[annotation coordinate]];
        }
        return annotationView;
    }
    return nil;
}

#pragma mark - MAGeoCodeSearchDelegate

////获取反编码状态
//-(void)clickReverseGeoCode:(CLLocationCoordinate2D)coordinate
//{
//    //构造AMapReGeocodeSearchRequest对象，location为必选项，radius为可选项
//    AMapReGeocodeSearchRequest *regeoRequest = [[AMapReGeocodeSearchRequest alloc] init];
//    regeoRequest.searchType = AMapSearchType_ReGeocode;
//    regeoRequest.location = [AMapGeoPoint locationWithLatitude:coordinate.latitude longitude:coordinate.longitude];
//    regeoRequest.radius = 10000;
//    regeoRequest.requireExtension = YES;
//    //发起正向地理编码
//    [_search AMapReGoecodeSearch: regeoRequest];
//}
//
////实现逆地理编码的回调函数
//- (void)onReGeocodeSearchDone:(AMapReGeocodeSearchRequest *)request response:(AMapReGeocodeSearchResponse *)response
//{
//    if(response.regeocode != nil)
//    {
//        //获取起始位置
//        AMapAddressComponent *addressComponent = response.regeocode.addressComponent;
//        [self changeUserLocationInfo:[NSString stringWithFormat:@"%@%@%@", addressComponent.district, addressComponent.streetNumber.street, addressComponent.streetNumber.number]];
//    }
//}
//
//- (void)changeUserLocationInfo:(NSString *)locationString
//{
//    //修改地址
//    self.locationInfoLabel.text = locationString;
//    [self.locationInfoLabel sizeToFit];
//}

#pragma mark - Connect To Server

//- (void)saveCollectionPointToServer
//{
//    NSString *address = self.locationInfoLabel.text;
//    NSString *description = self.markInfoLabel.text;
//    NSString *latitude = [NSString stringWithFormat:@"%f",self.kidcollectionInfo.locationLatitude.doubleValue];
//    NSString *longitude = [NSString stringWithFormat:@"%f",self.kidcollectionInfo.locationLongitude.doubleValue];
//    NSString *openId = [[TYDUserInfo sharedUserInfo] openID];
//    NSDictionary *params = @{@"childid"     :@(self.currentKidId),
//                             @"openid"      :openId,
//                             @"address"     :address,
//                             @"latitude"    :latitude,
//                             @"longitude"   :longitude,
//                             @"description" :description
//                             };
//    
//    [self postURLRequestWithMessageCode:ServiceMsgCodeEnshrineLocation
//                           HUDLabelText:nil
//                                 params:[params mutableCopy]
//                          completeBlock:^(id result) {
//                              [self saveCollectionPointToServerComplete:result];
//                          }];
//}
//
//- (void)saveCollectionPointToServerComplete:(id)result
//{
//    NSLog(@"saveCollectionPointToServerComplete:%@", result);
//    NSNumber *resultCode = result[@"result"];
//    
//    if(resultCode != nil
//       && resultCode.intValue == 0)
//    {
//        [self progressHUDShowWithCompleteText:@"收藏成功" isSucceed:YES];
//        self.collectionButton.selected = YES;
//    }
//    else
//    {
//        [self progressHUDShowWithCompleteText:@"收藏失败" isSucceed:NO];
//    }
//}


- (void)removeCollectionPointToServer
{
    NSDictionary *params = @{@"id" :@(self.kidcollectionInfo.locationID.integerValue)};
    
    [self postURLRequestWithMessageCode:ServiceMsgCodeRemoveEnshrineLocation
                           HUDLabelText:nil
                                 params:[params mutableCopy]
                          completeBlock:^(id result) {
                              [self removeCollectionPointToServerComplete:result];
                          }];
}

- (void)removeCollectionPointToServerComplete:(id)result
{
    NSLog(@"saveCollectionPointToServerComplete:%@", result);
    NSNumber *resultCode = result[@"result"];
    
    if(resultCode != nil
       && resultCode.intValue == 0)
    {
        [self progressHUDShowWithCompleteText:@"取消收藏成功" isSucceed:YES additionalTarget:self action:@selector(popBackEventWillHappen) object:nil];
    }
    else
    {
        [self progressHUDShowWithCompleteText:@"取消收藏失败" isSucceed:NO];
    }
}

@end
