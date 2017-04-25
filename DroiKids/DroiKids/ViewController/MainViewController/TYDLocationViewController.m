//
//  TYDLocationViewController.m
//  DroiKids
//
//  Created by superjunjun on 15/8/18.
//  Copyright (c) 2015年 superjunjun. All rights reserved.
//

#import "TYDLocationViewController.h"
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
#import "TYDMainViewController.h"

#define sLocationButtonTag                          1000
#define sLocationIconImageViewTag                   10000
#define sLocalFenceKey                  [[[TYDDataCenter defaultCenter] currentKidInfo] watchID]
#define sAddLocationSucced                   @"位置收藏成功，添加备注"

@interface TYDLocationViewController ()<MAMapViewDelegate, AMapSearchDelegate, CLLocationManagerDelegate, UIGestureRecognizerDelegate ,UIAlertViewDelegate>

{
    BOOL _isPolyLineExist;
    BOOL _iscollectedPointsExist;
}
@property (strong, nonatomic) MAPinAnnotationView   *myAnnotation;
@property (strong, nonatomic) AMapSearchAPI         *search;
@property (strong, nonatomic) MAPointAnnotation     *startAnnotation;
@property (strong, nonatomic) MAMapView             *mapView;
@property (strong, nonatomic) MAPolyline            *polyLine;

@property (strong, nonatomic) NSArray               *buttonItems;
@property (strong, nonatomic) NSMutableArray        *userlocationPointArray;//服务器请求来的定位点数组
@property (strong, nonatomic) NSMutableArray        *userCollectionPointArray;//服务器请求来的收藏点数组
@property (strong, nonatomic) NSMutableArray        *collectedPointAnnotation;//用来删除操作的点数组
@property (strong, nonatomic) NSMutableArray        *collectedAnnotation;//收藏地点
@property (copy  , nonatomic) NSString              *currentLocationString;
@property (strong, nonatomic) UILabel               *locationInfoLabel;
@property (strong, nonatomic) UILabel               *markInfoLabel;
@property (strong, nonatomic) UILabel               *infoTimeLabel;
@property (strong, nonatomic) UIButton              *collectionButton;
@property (assign, nonatomic) BOOL                  isFirstLocation;
@property (assign, nonatomic) NSInteger             currentKidId;
@property (assign, nonatomic) NSInteger             currentEnshrineLocationId;
@property (strong, nonatomic) TYDKidTrackInfo       *currentKidTrackInfo;
@property (strong, nonatomic) TYDEnshrineLocationInfo *currentEnshrineInfo;
@property (strong, nonatomic) NSString              *currentTextFieldtext;
@property (assign, nonatomic) CLLocationCoordinate2D     currentCoord;

@end

@implementation TYDLocationViewController

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
    [self getLocationInfo];
//    if(self.userlocationPointArray.count > 0)
//    {
//        UIButton *button = self.buttonItems.firstObject;
//        button.selected = YES;
//    }
    //显示定位
    NSArray *array = [[[[TYDDataCenter defaultCenter]currentKidInfo] currentLocation]componentsSeparatedByString:@","];
    if(array.count == 3)
    {
        CLLocationCoordinate2D coord = [BOCoordinateTransformation changeWGS84ToGcj02WithLatitude:[array.firstObject doubleValue] withLongitude:[array[1] doubleValue]];
        [self clickReverseGeoCode:coord];
        MAPointAnnotation *pointAnnotation = [[MAPointAnnotation alloc] init];
        pointAnnotation.coordinate = coord;
        [self.mapView addAnnotation:pointAnnotation];
        self.mapView.centerCoordinate = coord;
    }
    else
    {
        self.mapView.showsUserLocation = YES;
    }
    //显示栅栏是否开启
    UIButton *button = self.buttonItems[1];
    NSString *detailString = [[NSUserDefaults standardUserDefaults]objectForKey:sLocalFenceKey];
    if(detailString)
    {
        NSArray *array = [detailString componentsSeparatedByString:@","];
        if([array.firstObject boolValue])
        {
            button.selected = YES;
        }
        else
        {
            button.selected = NO;
        }
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    if ([CLLocationManager locationServicesEnabled] &&
        ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusAuthorized
         || [CLLocationManager authorizationStatus] == kCLAuthorizationStatusNotDetermined))
    {
            //定位功能可用，开始定位
        self.mapView.showsUserLocation = YES;
//           CLLocationManager *locationManger = [CLLocationManager new];
//            locationManger.delegate = self;
//            [locationManger startUpdatingLocation];
    }
    else if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusDenied)
    {
        UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"提示" message:@"请打开儿童手表的定位" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:@"取消", nil];
        [alertView show];
    }
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self cleanCollectPlace];
    [self.userCollectionPointArray removeAllObjects];
    [self.userlocationPointArray removeAllObjects];
    [self.collectedPointAnnotation removeAllObjects];
}
- (void)localDataInitialize
{
    self.userlocationPointArray = [NSMutableArray new];
    TYDKidInfo *kidInfo =  [[TYDDataCenter defaultCenter]currentKidInfo];
    self.currentKidId = [kidInfo.kidID integerValue];
    self.userCollectionPointArray = [NSMutableArray new];
    self.collectedPointAnnotation = [NSMutableArray new];
    self.collectedAnnotation = [NSMutableArray new];
}

- (void)navigationBarItemsLoad
{
    self.title = @"定位";
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setBackgroundImage:[UIImage imageNamed:@"main_location_calendar"] forState:UIControlStateNormal];
    [button sizeToFit];
    [button addTarget:self action:@selector(calendarButtonClick) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *rightBarButtonItem = [[UIBarButtonItem alloc]initWithCustomView:button];
    self.navigationItem.rightBarButtonItem = rightBarButtonItem;
}

- (void)subviewsLoad
{
    [self mapViewLoad];
    [self buttonLoad];
    [self locationInfoBarLoad];
}

- (void)mapViewLoad
{
    CGRect frame = self.view.bounds;
    MAMapView *mapView = [[MAMapView alloc]initWithFrame:frame];
    //不显示精度圈
//    MAUserLocationRepresentation *representation = [MAUserLocationRepresentation new];
//    representation.showsAccuracyRing = NO;
//    representation.image = [UIImage imageNamed:@"login_qqBtn"];
//    representation.showsHeadingIndicator = YES;
//    [mapView updateUserLocationRepresentation:representation];
//    mapView.showsUserLocation = YES;//显示定位图层
//    mapView.userTrackingMode = MAUserTrackingModeFollow;//设置定位的状态
    //设置地图缩放级别
    [mapView setZoomLevel:16.1 animated:YES];
//    mapView.distanceFilter = 5.0;
//    mapView.desiredAccuracy = kCLLocationAccuracyBest;
    _search = [[AMapSearchAPI alloc] initWithSearchKey:sGaodeMapSDKAppKey Delegate:self];
    mapView.showsCompass = NO;
    mapView.showsScale = NO;
    mapView.delegate = self;
//    mapView.pausesLocationUpdatesAutomatically = NO;
//    mapView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    [self.view addSubview:mapView];

    self.mapView = mapView;
}

- (void)buttonLoad
{
    CGRect frame = self.view.frame;
    NSArray *nameArray = @[@"main_location_today_close", @"main_location_fence", @"main_location_collection_list"];
    NSArray *selectedNameArray = @[@"main_location_today", @"main_location_fence_open", @"main_location_collection"];

    NSMutableArray *buttonItems = [NSMutableArray new];
    NSInteger buttonWidth = 36;
    NSInteger topCap = 40;
    NSInteger rightCap = 53;
    NSInteger buttonCap = 12;
    for(int i = 0; i < nameArray.count; i++)
    {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        [button setBackgroundImage:[UIImage imageNamed:@"main_location_buttonBackground"] forState:UIControlStateNormal];
        [button setImage:[UIImage imageNamed:nameArray[i]] forState:UIControlStateNormal];
        [button setImage:[UIImage imageNamed:selectedNameArray[i]] forState:UIControlStateSelected];
//        button.backgroundColor = [UIColor blackColor];
//        button.alpha = 0.5;
//        button.layer.cornerRadius = 10;
//        button.layer.masksToBounds = YES;
        button.left = frame.size.width - rightCap;
        button.top = topCap + (buttonWidth + buttonCap) * i;
        button.width = buttonWidth;
        button.height = buttonWidth;
        button.tag = sLocationButtonTag + i;
        [button addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:button];
        [buttonItems addObject:button];
    }
    self.buttonItems = buttonItems;
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
    NSInteger leftCap = 17;
    NSInteger buttonWidth = 30;
    NSInteger timeLabelWidth = frame.size.width - (leftCap + buttonWidth) * 4;

    UIImageView *locationImageView = [UIImageView new];
    locationImageView.image = [UIImage imageNamed:@"main_location_location"];
    [locationImageView sizeToFit];
    locationImageView.left = leftCap;
    locationImageView.yCenter= infoBarYCenter;
    [infoBarView addSubview:locationImageView];
    
    UILabel *markInfoLabel = [UILabel new];
    markInfoLabel.text = @"未获取到定位信息";
    markInfoLabel.font = [UIFont systemFontOfSize:14.0];
    [markInfoLabel sizeToFit];
    markInfoLabel.left = locationImageView.right + 10;
    markInfoLabel.yCenter = infoBarYCenter - 5;
    [infoBarView addSubview:markInfoLabel];
//    markInfoLabel.backgroundColor = [UIColor redColor];
    self.markInfoLabel = markInfoLabel;
    
    UILabel *locationInfoLabel = [UILabel new];
    locationInfoLabel.text = @"时间";
    locationInfoLabel.font = [UIFont systemFontOfSize:11.0];
    locationInfoLabel.left = markInfoLabel.left;
    locationInfoLabel.width = timeLabelWidth + 15;
    locationInfoLabel.height = 21;
    locationInfoLabel.yCenter = infoBarYCenter + 10;
    [infoBarView addSubview:locationInfoLabel];
//    locationInfoLabel.backgroundColor = [UIColor orangeColor];
    self.locationInfoLabel = locationInfoLabel;
    
    UIButton *callButton = [UIButton new];
    callButton.left = frame.size.width - leftCap - buttonWidth;
    callButton.width = callButton.height = buttonWidth;
    callButton.yCenter = infoBarYCenter;
    [callButton setBackgroundImage:[UIImage imageNamed:@"main_location_callIcon"] forState:UIControlStateNormal];
    [callButton addTarget:self action:@selector(callButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    [infoBarView addSubview:callButton];
    
    UIButton *collectionButton = [UIButton new];
    collectionButton.left = frame.size.width - leftCap - buttonWidth * 3;
    collectionButton.width = collectionButton.height = buttonWidth;
    collectionButton.yCenter = infoBarYCenter;
    [collectionButton setBackgroundImage:[UIImage imageNamed:@"main_location_uncollection"] forState:UIControlStateNormal];
    [collectionButton setBackgroundImage:[UIImage imageNamed:@"main_location_collection"] forState:UIControlStateSelected];
    [collectionButton addTarget:self action:@selector(collectionButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    [infoBarView addSubview:collectionButton];
    self.collectionButton = collectionButton;
    
    UILabel *infoTimeLabel = [UILabel new];
    infoTimeLabel.text = @" ";
    infoTimeLabel.font = [UIFont systemFontOfSize:11.0];
    [infoTimeLabel sizeToFit];
    infoTimeLabel.left = collectionButton.left - 10 - infoTimeLabel.size.width;
    infoTimeLabel.yCenter = locationInfoLabel.yCenter;
    [infoBarView addSubview:infoTimeLabel];
//    infoTimeLabel.backgroundColor = [UIColor greenColor];
    self.infoTimeLabel = infoTimeLabel;
}

#pragma mark - Touch Event

- (void)buttonClick:(UIButton *)sender
{
    switch(sender.tag - sLocationButtonTag)
    {
        case 0:
        {
            if(!sender.selected)
            {
                [self showLocationPlace];
                sender.selected = YES;
            }
            else
            {
                [self cleanCollectPlace];
                sender.selected = NO;
            }
            break;
        }
        case 1:
        {
            //电子栅栏
            NSLog(@"电子栅栏");
            TYDFenceViewController *vc = [TYDFenceViewController new];
            [self.navigationController pushViewController:vc animated:YES];
            break;
        }
        case 2:
        {
            //收藏地点
            NSLog(@"收藏地点");
            TYDCollectingListViewController *vc = [TYDCollectingListViewController new];
            [self.navigationController pushViewController:vc animated:YES];
            break;
        }
        default:
            break;
    }
}

- (void)collectionButtonClick:(UIButton *)sender
{
    if(self.userlocationPointArray.count > 0)
    {
        if(sender.selected == NO)
        {
            NSString *locationString = [NSString stringWithFormat:@"地址:%@",self.markInfoLabel.text];
            UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"添加备注" message:locationString delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"好的", nil];
            alertView.alertViewStyle = UIAlertViewStylePlainTextInput;
            
//            UITextField *textField = [alertView textFieldAtIndex:0];
//            textField.placeholder = @"";
//            UIImageView *imageView = [UIImageView new];
//            imageView.size = CGSizeMake(10, 10);
//            imageView.image = [UIImage imageNamed:@"main_location_unlocation"];
//            textField.text = self.markInfoLabel.text;
//            textField.leftView = imageView;
//            textField.leftViewMode = UITextFieldViewModeAlways;
//            textField.enabled = NO;
//            textField.borderStyle = UITextBorderStyleNone;
//            
//            UITextField *markTextField = [alertView textFieldAtIndex:1];
//            markTextField.placeholder = @"备注";
//            markTextField.secureTextEntry = NO;
            [alertView show];
        }
        else
        {
            sender.selected = NO;
            [self removeCollectionPointToServer];
        }
    }
    else
    {
        self.noticeText = @"没有当前定位信息";
    }
}

- (void)callButtonClick:(UIButton *)sender
{
    NSLog(@"通话");
    NSMutableString *numberStr = [[NSMutableString alloc] initWithFormat:@"tel:%@", [[[TYDDataCenter defaultCenter]currentKidInfo] phoneNumber]];
    NSLog(@"numberStr %@",numberStr);
    UIWebView * callWebview = [[UIWebView alloc] init];
    [callWebview loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:numberStr]]];
    [self.view addSubview:callWebview];
}

////长按手势处理方法
//- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
//{
//    return YES;
//}
//
//- (void)longPress:(UILongPressGestureRecognizer *)gestureRecognizer
//{
//    if (gestureRecognizer.state == UIGestureRecognizerStateEnded)
//    {
//        return;
//    }
//    //坐标转换
//    CGPoint touchPoint = [gestureRecognizer locationInView:self.mapView];
//    CLLocationCoordinate2D touchMapCoordinate =
//    [self.mapView convertPoint:touchPoint toCoordinateFromView:self.mapView];
//    
//    MAPointAnnotation *pointAnnotation = [[MAPointAnnotation alloc] init];
//    pointAnnotation.coordinate = touchMapCoordinate;
//    pointAnnotation.title = @"名字";
//    [self.mapView addAnnotation:pointAnnotation];
//}

- (void)calendarButtonClick
{
    NSLog(@"calendarButtonClick");
    //历史轨迹
    TYDHistoricalTrackViewController *vc = [TYDHistoricalTrackViewController new];
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if([alertView.title isEqualToString:sAddLocationSucced])
    {
        if(buttonIndex != alertView.cancelButtonIndex)
        {
            UITextField *textField=[alertView textFieldAtIndex:0];
            self.currentTextFieldtext = textField.text;;
            [self saveCollectionPointToServer];
        }
    }
}

#pragma mark - mapOverLay

//- (void)addOverLine
//{
//    NSArray *longitudeArray = @[@(121.403046), @(121.405449) ,@(121.407337) ,@(121.412659) ,@(121.418495) ,@(121.419182)];
//    NSArray *latitudeArray = @[@(31.162284), @(31.163312) ,@(31.163945) ,@(31.165663) ,@(31.166838) ,@(31.164634)];
//    NSInteger coordCount = longitudeArray.count;
//    CLLocationCoordinate2D coords[coordCount];
//    for(int i = 0; i < coordCount; i++)
//    {
//        double latitude = [latitudeArray[i] doubleValue];
//        double longitude = [longitudeArray[i] doubleValue];
//        coords[i].latitude = latitude;
//        coords[i].longitude = longitude;
//        
//        MAPointAnnotation *pointAnnotation = [[MAPointAnnotation alloc] init];
//        pointAnnotation.coordinate = CLLocationCoordinate2DMake(latitude, longitude);
//        pointAnnotation.title = @"方恒国际";
//        pointAnnotation.subtitle = @"阜通东大街6号";
//        [_mapView addAnnotation:pointAnnotation];
//        [self.pointAnnotation addObject:pointAnnotation];
//    }
//    // 添加路线overlay
////    MAPolyline *polyLine = [MAPolyline polylineWithCoordinates:coords count:coordCount];
////    //[self.mapView setCenterCoordinate:coords[0]];
////    //self.mapView.zoomLevel = 18;
////    [self.mapView addOverlay:polyLine];
//    MACoordinateRegion region = MACoordinateRegionMake(coords[2], MACoordinateSpanMake( 0.05,  0.05));
//    [self.mapView setRegion:[self.mapView regionThatFits:region] animated:YES];
//    //[self.mapView setZoomLevel:10 animated:YES];
////    self.polyLine = polyLine;
//}

- (void)cleanOverLay:(UIButton *)sender
{
    if(self.polyLine)
    {
        [self.mapView removeOverlay:self.polyLine];
//        [self.mapView removeAnnotations:self.pointAnnotation];
        _isPolyLineExist = NO;
    }
}

- (void)showLocationPlace
{
//    NSDictionary *params = @{@"openid"  :[[TYDUserInfo sharedUserInfo] openID],
//                             @"watchid" :[[[TYDDataCenter defaultCenter]currentKidInfo] watchID],
//                             @"type"    :@(TYDGetKidLocationInfo)
//                             };
//    [self postURLRequestWithMessageCode:ServiceMsgCodeSetWatchOperate
//                           HUDLabelText:nil
//                                 params:[params mutableCopy]
//                          completeBlock:^(id result) {
//                              [self operationToServerComplete:result];
//                          }];
    
    NSArray *array = self.userlocationPointArray;
    if (array.count > 0)
    {
        self.currentKidTrackInfo = array.lastObject;
        
        NSInteger coordCount = array.count;
        CLLocationCoordinate2D coords[coordCount];
        for(int i = 0; i < coordCount; i++)
        {
            TYDKidTrackInfo *kidTrackInfo = array[i];
            double latitude = [kidTrackInfo.trackLatitude floatValue];
            double longitude = [kidTrackInfo.trackLongitude floatValue];
            coords[i].latitude = latitude;
            coords[i].longitude = longitude;
            
            MAPointAnnotation *pointAnnotation = [[MAPointAnnotation alloc] init];
            
            pointAnnotation.coordinate = [BOCoordinateTransformation changeWGS84ToGcj02WithLatitude:latitude withLongitude:longitude];
            if(i == coordCount - 1)
            {
                self.mapView.centerCoordinate = pointAnnotation.coordinate;
                pointAnnotation.title = @"selected";
                self.currentCoord = coords[i];
                [self clickReverseGeoCode:pointAnnotation.coordinate];
            }
            [self.mapView addAnnotation:pointAnnotation];
            [self.collectedPointAnnotation addObject:pointAnnotation];
        }
        MACoordinateRegion region = MACoordinateRegionMake(coords[2], MACoordinateSpanMake(0.05,  0.05));
        [self.mapView setRegion:[self.mapView regionThatFits:region] animated:YES];
    }
    else
    {
        self.noticeText = @"没有当前儿童定位信息";
    }
}

- (void)operationToServerComplete:(id)result
{
    NSLog(@"parseUseLocationInfoComplete:%@", result);
    NSNumber *resultCode = result[@"result"];
    
    if(resultCode != nil
       && resultCode.intValue == 0)
    {
        NSLog(@"parseUseLocationInfoCompleteSuccess");
        self.noticeText = @"成功发送请求位置信息";
    }
    else
    {
        self.noticeText = @"获取儿童位置失败";
    }
    [self progressHUDHideImmediately];
}

- (void)cleanCollectPlace
{
    if(self.collectedPointAnnotation.count > 0)
    {
        [self.mapView removeAnnotations:self.collectedPointAnnotation];
        _iscollectedPointsExist = NO;
    }
}

#pragma mark - MAMapViewDelegate

//处理位置坐标更新
- (void)mapView:(MAMapView *)mapView didUpdateUserLocation:(MAUserLocation *)userLocation;
{
    NSLog(@"didUpdateUserLocation lat %f,long %f, speed %f horizontalAccuracy %f verticalAccuracy %f",userLocation.location.coordinate.latitude,userLocation.location.coordinate.longitude, userLocation.location.speed, userLocation.location.horizontalAccuracy, userLocation.location.verticalAccuracy);
    self.mapView.centerCoordinate = userLocation.location.coordinate;
//    if(!self.isFirstLocation)
//    {
//        [self showLocationPlace];
//    }
    self.mapView.showsUserLocation = NO;
}

- (MAOverlayView *)mapView:(MAMapView *)map viewForOverlay:(id<MAOverlay>)overlay
{
    if([overlay isKindOfClass:[MAPolyline class]])
    {
        MAPolylineView *polylineView = [[MAPolylineView alloc] initWithOverlay:overlay];
        polylineView.strokeColor = [[UIColor redColor] colorWithAlphaComponent:0.7];
        polylineView.lineJoin = kCGLineJoinRound;//连接类型
        polylineView.lineWidth = 5.0;
        return polylineView;
    }
    return nil;
}

- (MAAnnotationView *)mapView:(MAMapView *)mapView viewForAnnotation:(id <MAAnnotation>)annotation
{
    if ([annotation isKindOfClass:[MAPointAnnotation class]])
    {
        static NSString *reuseIndetifier = @"annotationReuseIndetifier";
        MAAnnotationView *annotationView = (MAAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:reuseIndetifier];
        if (annotationView == nil)
        {
            annotationView = [[MAAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:reuseIndetifier];
            UIButton *button = [UIButton new];
            button.frame = CGRectMake(0, 0, 30, 30);
            [button addTarget:self action:@selector(changeAnnotationView:) forControlEvents:UIControlEventTouchUpInside];
            [annotationView addSubview:button];
            if([annotation.title isEqualToString:@"selected"])
            {
                annotationView.centerOffset = CGPointMake(0, -38);
                annotationView.image = [UIImage imageNamed:@"main_location_point_big"];
                annotationView.selected = YES;
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
            }
            else
            {
                annotationView.image = [UIImage imageNamed:@"main_location_point"];
                //设置中⼼心点偏移，使得标注底部中间点成为经纬度对应点
                annotationView.centerOffset = CGPointMake(0, -15);
                annotationView.selected = NO;
            }
            [self.collectedAnnotation addObject:annotationView];
        }
        return annotationView;
    }
    return nil;
}

- (void)mapView:(MAMapView *)mapView didSelectAnnotationView:(MAAnnotationView *)view
{

}
- (void)changeAnnotationView:(UIButton *)sender
{
    for(MAAnnotationView *annotationView in self.collectedAnnotation)
    {
        if(annotationView.selected == YES)
        {
            annotationView.selected = NO;
            annotationView.centerOffset = CGPointMake(0, -15);
            annotationView.image = [UIImage imageNamed:@"main_location_point"];
            for(UIImageView * imageView in annotationView.subviews)
            {
                if(imageView.tag == sLocationIconImageViewTag)
                {
                    [imageView removeFromSuperview];
                }
            }
        }
    }
    MAAnnotationView *annotationView = (MAAnnotationView *)sender.superview;
    annotationView.centerOffset = CGPointMake(0, -38);
    annotationView.image = [UIImage imageNamed:@"main_location_point_big"];
    annotationView.selected = YES;
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
    
    NSInteger index = [self.collectedAnnotation indexOfObject:annotationView];
    self.currentKidTrackInfo = self.userlocationPointArray[index];
    
    CLLocationCoordinate2D coord = [annotationView.annotation coordinate];
    [self clickReverseGeoCode:coord];
    self.currentCoord = coord;
}

#pragma mark - MAGeoCodeSearchDelegate

//获取反编码状态
-(void)clickReverseGeoCode:(CLLocationCoordinate2D)coordinate
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
        [self changeUserLocationInfo:[NSString stringWithFormat:@"%@%@%@号", addressComponent.district, addressComponent.streetNumber.street, addressComponent.streetNumber.number]];
    }
}

- (void)changeUserLocationInfo:(NSString *)locationString
{
    //修改地址
    self.markInfoLabel.text = locationString;
    [self.markInfoLabel sizeToFit];
    self.locationInfoLabel.text = [NSString stringWithFormat:@"%@",[BOTimeStampAssistor getHourStringWithTimeStamp:[self.currentKidTrackInfo.infoCreateTime integerValue]]];
    self.collectionButton.selected = NO;
    self.infoTimeLabel.text = @"";
    [self.infoTimeLabel sizeToFit];
    [self changeMarkLabelInfo];
}

- (void)changeMarkLabelInfo
{
    //修改备注信息
    if(self.userCollectionPointArray.count > 0)
    {
        for(TYDEnshrineLocationInfo *kidcollectionInfo in self.userCollectionPointArray)
        {
            CLLocationCoordinate2D coord = self.currentCoord;
            if([kidcollectionInfo.locationLatitude  isEqual: @(coord.latitude)]
               && [kidcollectionInfo.locationLongitude  isEqual: @(coord.longitude)])
            {
                self.markInfoLabel.text = kidcollectionInfo.locationMemo;
                self.locationInfoLabel.text = kidcollectionInfo.locationName;
                self.infoTimeLabel.text = [NSString stringWithFormat:@"%@",[BOTimeStampAssistor getHourStringWithTimeStamp:[self.currentKidTrackInfo.infoCreateTime integerValue]]];
                [self.infoTimeLabel sizeToFit];
                self.infoTimeLabel.left = self.collectionButton.left - 10 - self.infoTimeLabel.size.width;
                
                self.currentEnshrineInfo = kidcollectionInfo;
                [self.markInfoLabel sizeToFit];
                self.collectionButton.selected = YES;
            }
        }
    }
}

- (void)addCollectedAnnotationToArray:(CLLocationCoordinate2D )coord address:(NSString *)address time:(NSNumber *)time withlocationID:(NSInteger )locationID
{
    TYDEnshrineLocationInfo *kidcollectionInfo = [TYDEnshrineLocationInfo new];
    kidcollectionInfo.kidID = [NSString stringWithFormat:@"%ld",(long)self.currentKidId];
    kidcollectionInfo.locationID = [NSString stringWithFormat:@"%ld",(long)locationID];
    kidcollectionInfo.locationName = address;
    kidcollectionInfo.locationMemo = self.currentTextFieldtext;
    kidcollectionInfo.infoCreateTime = time;
    kidcollectionInfo.locationLatitude = @(coord.latitude);
    kidcollectionInfo.locationLongitude = @(coord.longitude);
    [self.userCollectionPointArray addObject:kidcollectionInfo];
}

#pragma mark - Connect To Server

- (void)getLocationInfo
{
    NSTimeInterval endTime = [BOTimeStampAssistor getCurrentTime];
    NSTimeInterval startTime = endTime - nTimeIntervalSecondsPerDay;
    TYDKidInfo *kidInfo =  [[TYDDataCenter defaultCenter]currentKidInfo];
    
    NSDictionary *params = @{@"childid"  :@(kidInfo.kidID.integerValue),
                             @"stime"    :@(startTime),
                             @"etime"    :@(endTime)
                             };
    
    [self postURLRequestWithMessageCode:ServiceMsgCodeKidTrackRequest
                           HUDLabelText:nil
                                 params:[params mutableCopy]
                          completeBlock:^(id result) {
                              [self parseUseLocationInfo:result];
                          }];
}

- (void)parseUseLocationInfo:(id)result
{
    NSLog(@"parseUseLocationInfoComplete:%@", result);
    NSDictionary *dic = result;
    NSNumber *resultCode = result[@"result"];
    
    if(resultCode != nil
       && resultCode.intValue == 0)
    {
        NSArray *locationPointarray = [dic objectForKey:@"historyposition"];
        if(locationPointarray.count > 0)
        {
            for(NSDictionary *detailDic in locationPointarray)
            {
                TYDKidTrackInfo *kidTrackInfo = [TYDKidTrackInfo new];
                kidTrackInfo.kidID = detailDic[@"childid"];
                kidTrackInfo.infoCreateTime = detailDic[@"time"];
                kidTrackInfo.trackLatitude = detailDic[@"latitude"];
                kidTrackInfo.trackLongitude = detailDic[@"longitude"];
                [self.userlocationPointArray addObject:kidTrackInfo];
                [self getCollectionLocationInfo];
            }
        }
        else
        {
            self.noticeText = @"没有当前儿童定位信息";
        }
    }
    else
    {
        self.noticeText = @"获取定位信息失败";
    }
    [self progressHUDHideImmediately];
}

- (void)getCollectionLocationInfo
{
    NSTimeInterval endTime = (long)[BOTimeStampAssistor getCurrentTime];
    NSString *openId = [[TYDUserInfo sharedUserInfo] openID];
    NSDictionary *params = @{@"childid"  :@(self.currentKidId),
                             @"openid"   :openId,
                             @"stime"    :@((long)NSTimeIntervalSince1970),
                             @"etime"    :@(endTime)
                             };
    [self postURLRequestWithMessageCode:ServiceMsgCodeEnshrineLocationRequest
                           HUDLabelText:nil
                                 params:[params mutableCopy]
                          completeBlock:^(id result) {
                              [self parseUseCollectionLocationInfo:result];
                          }];
}

- (void)parseUseCollectionLocationInfo:(id)result
{
    NSLog(@"parseUseCollectionLocationInfoInfoComplete:%@", result);
    NSDictionary *dic = result;
    NSNumber *resultCode = result[@"result"];
    
    if(resultCode != nil
       && resultCode.intValue == 0)
    {
        NSArray *collectionPointarray = [dic objectForKey:@"position"];
        if(collectionPointarray.count > 0)
        {
            for(NSDictionary *detailDic in collectionPointarray)
            {
                TYDEnshrineLocationInfo *kidcollectionInfo = [TYDEnshrineLocationInfo new];
                [kidcollectionInfo setAttributes:detailDic];
                [self.userCollectionPointArray addObject:kidcollectionInfo];
            }
        }
//        [self showLocationPlace];
    }
    else
    {
        self.noticeText = @"获取定位信息失败";
    }
    [self progressHUDHideImmediately];
}

- (void)saveCollectionPointToServer
{
    NSString *address = self.markInfoLabel.text;
    NSString *description = self.currentTextFieldtext;
    NSString *latitude = [NSString stringWithFormat:@"%f",self.currentCoord.latitude];
    NSString *longitude = [NSString stringWithFormat:@"%f",self.currentCoord.longitude];
    NSString *openId = [[TYDUserInfo sharedUserInfo] openID];
    NSDictionary *params = @{@"childid"     :@(self.currentKidId),
                             @"openid"      :openId,
                             @"address"     :address,
                             @"latitude"    :latitude,
                             @"longitude"   :longitude,
                             @"description" :description
                             };
    
    [self postURLRequestWithMessageCode:ServiceMsgCodeEnshrineLocation
                           HUDLabelText:nil
                                 params:[params mutableCopy]
                          completeBlock:^(id result) {
                              [self saveCollectionPointToServerComplete:result];
                          }];
}

- (void)saveCollectionPointToServerComplete:(id)result
{
    NSLog(@"saveCollectionPointToServerComplete:%@", result);
    NSNumber *resultCode = result[@"result"];
    
    if(resultCode != nil
       && resultCode.intValue == 0)
    {
        [self progressHUDShowWithCompleteText:@"收藏成功" isSucceed:YES];
        self.collectionButton.selected = YES;
        NSInteger locationID = [result[@"id"] integerValue];
        [self addCollectedAnnotationToArray:self.currentCoord address:self.markInfoLabel.text time:self.currentKidTrackInfo.infoCreateTime withlocationID:locationID];
        [self changeMarkLabelInfo];
    }
    else
    {
        [self progressHUDShowWithCompleteText:@"收藏失败" isSucceed:NO];
    }
}

- (void)removeCollectionPointToServer
{
    NSDictionary *params = @{@"id" :@(self.currentEnshrineInfo.locationID.integerValue)};
    
    [self postURLRequestWithMessageCode:ServiceMsgCodeRemoveEnshrineLocation
                           HUDLabelText:nil
                                 params:[params mutableCopy]
                          completeBlock:^(id result) {
                              [self removeCollectionPointToServerComplete:result];
                          }];
}

- (void)removeCollectionPointToServerComplete:(id)result
{
    NSLog(@"removeCollectionPointToServerComplete:%@", result);
    NSNumber *resultCode = result[@"result"];
    
    if(resultCode != nil
       && resultCode.intValue == 0)
    {
        [self.userCollectionPointArray removeObject:self.currentEnshrineInfo];
        [self changeUserLocationInfo:self.currentEnshrineInfo.locationName];
        [self progressHUDShowWithCompleteText:@"取消收藏成功" isSucceed:YES];
    }
    else
    {
        [self progressHUDShowWithCompleteText:@"取消收藏失败" isSucceed:NO];
    }
}

@end
