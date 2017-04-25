//
//  TYDFenceViewController.m
//  DroiKids
//
//  Created by superjunjun on 15/8/18.
//  Copyright (c) 2015年 superjunjun. All rights reserved.
//

#import "TYDFenceViewController.h"
#import <MAMapKit/MAMapKit.h>
#import <AMapSearchKit/AMapSearchAPI.h>
#import "TYDDrawView.h"
#import "TYDDataCenter.h"
#import "TYDKidTrackInfo.h"
#import "BOCoordinateTransformation.h"

#define sLocalFenceKey [[[TYDDataCenter defaultCenter] currentKidInfo] watchID]

@interface TYDFenceViewController ()<MAMapViewDelegate, AMapSearchDelegate, TYDDrawViewDelegate, UIGestureRecognizerDelegate>

{
    CGFloat _lastPinchScale;
}
@property (strong, nonatomic) MAPinAnnotationView   *myAnnotation;
@property (strong, nonatomic) AMapSearchAPI         *search;
@property (strong, nonatomic) MAPointAnnotation     *startAnnotation;
@property (strong, nonatomic) MAPointAnnotation     *endAnnotation;
@property (strong, nonatomic) MAMapView             *mapView;
@property (strong, nonatomic) MACircle              *circleView;
@property (strong, nonatomic) TYDDrawView           *drawView;
@property (strong, nonatomic) UIView                *fenceView;
@property (strong, nonatomic) UIView                *infoContentView;
@property (strong, nonatomic) UILabel               *infoLabel;
@property (strong, nonatomic) UIButton              *nextButton;
@property (strong, nonatomic) UIButton              *setButton;
@property (strong, nonatomic) UIButton              *switchButton;
@property (strong, nonatomic) UIButton              *closeButton;
@property (strong, nonatomic) NSMutableArray        *userlocationPointArray;//服务器请求来的定位点数组
@property (strong, nonatomic) TYDKidInfo            *kidInfo;

@property (assign, nonatomic) BOOL                  fenceState;
@property (assign, nonatomic) CGFloat               radius;
@property (assign, nonatomic) CGFloat               zoomLevel;
@property (assign, nonatomic) CLLocationCoordinate2D                coord;

@end

@implementation TYDFenceViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self localDataInitialize];
    [self subviewsLoad];
    [self navigationBarItemsLoad];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self getLocationInfo];
}

- (void)localDataInitialize
{
//    NSUserDefaults *useDefault = [NSUserDefaults standardUserDefaults];
//    NSString *detailString = [useDefault objectForKey:sLocalFenceKey];
//    if(detailString)
//    {
//        NSArray *array = [detailString componentsSeparatedByString:@","];
//        self.radius = [array[1] doubleValue];
//        self.coord = CLLocationCoordinate2DMake([array[2] doubleValue], [array[3] doubleValue]);
//        self.fenceState = [array.firstObject boolValue];
//    }
    self.kidInfo = [[TYDDataCenter defaultCenter]currentKidInfo];
    self.radius = self.kidInfo.fenceRadius.integerValue;
    if(self.kidInfo.fenceCenterPoint.length > 0)
    {
        NSArray *array = [self.kidInfo.fenceCenterPoint componentsSeparatedByString:@" "];
        self.coord = CLLocationCoordinate2DMake([array[1] doubleValue],[array.firstObject doubleValue]);
        self.zoomLevel = [array.lastObject doubleValue];
    }
    self.fenceState = self.kidInfo.electronicFenceState.boolValue;
}

- (void)navigationBarItemsLoad
{
    self.title = @"电子栅栏";
}

- (void)subviewsLoad
{
    [self mapViewLoad];
    [self fenceViewLoad];
    if(self.radius > 0 && self.coord.latitude && self.coord.longitude)
    {
        [self addFenceToMapViewWithCoord:self.coord withRadius:self.radius];
    }
    [self fenceInfoBarLoad];
}

- (void)mapViewLoad
{
    MAMapView *mapView  = [[MAMapView alloc] initWithFrame:self.view.frame];
    mapView.height = self.view.frame.size.height - 60;
    mapView.delegate = self;
    if(self.radius > 0 && self.kidInfo.fenceCenterPoint.length > 0)
    {
        mapView.showsUserLocation = NO;
        [mapView setZoomLevel:self.zoomLevel animated:YES];
        [mapView setCenterCoordinate:self.coord animated:YES];
    }
    else
    {
        mapView.showsUserLocation = YES;
        [mapView setZoomLevel:16.1 animated:YES];
    }
    mapView.showsCompass = NO;
    [self.view addSubview:mapView];
    // 为mapView添加pinch手势
    UIPinchGestureRecognizer *pinch = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(handlePinch:)];//添加手势
    pinch.delegate = self;
    [mapView addGestureRecognizer:pinch];
    
    self.mapView = mapView;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    return YES;
}
- (void)handlePinch:(UIPinchGestureRecognizer *)recognizer
{
    NSInteger meter = [self.mapView metersPerPointForCurrentZoomLevel];
    NSLog(@"  %ld  %f" ,(long)meter, self.mapView.zoomLevel);
    if(self.mapView.zoomLevel - 14 < 0.001)
    {
        self.mapView.zoomLevel = 14;
    }
}

- (void)fenceViewLoad
{
    CGFloat circleViewWidth = self.view.size.width - 80;
    NSInteger verCap = 124;
    NSInteger yCenter = (self.view.size.height - verCap)/ 2;
    UIView *infoContentView = [UIView new];
    infoContentView.left = 40;
    infoContentView.width = circleViewWidth;
    infoContentView.height = circleViewWidth;
    infoContentView.yCenter = yCenter;
    infoContentView.layer.cornerRadius = circleViewWidth / 2;
    infoContentView.layer.masksToBounds = YES;
    infoContentView.backgroundColor = [UIColor colorWithHex:0x16aff5 andAlpha:0.2];
    infoContentView.userInteractionEnabled = NO;
    [self.view addSubview:infoContentView];
    self.fenceView = infoContentView;
}

- (void)fenceInfoBarLoad
{
    CGRect frame = self.view.frame;
    NSInteger verCap = 64;
    UIView *infoBarView = [UIView new];
    infoBarView.top = self.view.bottom - 60 -verCap;
    infoBarView.left = 0;
    infoBarView.height = 60;
    infoBarView.width = self.view.width;
    infoBarView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:infoBarView];
    
    CGFloat infoBarYCenter = infoBarView.height / 2;
    CGFloat infoBarXCenter = infoBarView.width / 2;
    NSInteger leftCap = 17;
    NSInteger buttonWidth = 45;
    
    UILabel *infoLabel = [UILabel new];
    infoLabel.text = @"圆圈是安全区域，可手动缩放、移动";
    infoLabel.font = [UIFont systemFontOfSize:14.0];
    [infoLabel sizeToFit];
    infoLabel.left = leftCap;
    infoLabel.yCenter = infoBarYCenter;
    infoLabel.hidden = NO;
    [infoBarView addSubview:infoLabel];
    
    UIButton *nextButton = [UIButton new];
    nextButton.left = frame.size.width - leftCap - buttonWidth;
    nextButton.width = nextButton.height = buttonWidth;
    nextButton.yCenter = infoBarYCenter;
    nextButton.layer.cornerRadius = buttonWidth / 2;
    nextButton.layer.masksToBounds = YES;
    nextButton.backgroundColor = cBasicGreenColor;
    [nextButton setTitle:@"设定围栏" forState:UIControlStateNormal];
    nextButton.titleLabel.font = [UIFont systemFontOfSize:10.0];
    [nextButton addTarget:self action:@selector(nextButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    nextButton.hidden = NO;
    [infoBarView addSubview:nextButton];
    
    UIButton *setButton = [UIButton new];
    setButton.titleLabel.font = [UIFont systemFontOfSize:14.0];
    [setButton setTitleColor:UIColorWithHex(0x686868) forState:UIControlStateNormal];
    [setButton setTitle:@"重新设定" forState:UIControlStateNormal];
    [setButton sizeToFit];
    setButton.left = 63;
    setButton.yCenter = infoBarYCenter;
    [setButton addTarget:self action:@selector(editFenceButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    setButton.hidden = YES;
    [infoBarView addSubview:setButton];
    
    UIButton *switchButton = [UIButton new];
    [switchButton setTitle:@"开启栅栏" forState:UIControlStateNormal];
    switchButton.titleLabel.font = [UIFont systemFontOfSize:14.0];
    [switchButton setTitleColor:UIColorWithHex(0x6cbb52) forState:UIControlStateNormal];
    [switchButton sizeToFit];
    switchButton.left = frame.size.width - 63 - switchButton.size.width;
    switchButton.yCenter = infoBarYCenter;
    [switchButton addTarget:self action:@selector(switchButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    switchButton.hidden = YES;
    [infoBarView addSubview:switchButton];
    
    self.infoLabel = infoLabel;
    self.nextButton = nextButton;
    self.setButton = setButton;
    self.switchButton = switchButton;
    
    if(self.fenceState)
    {
        UIButton *closeButton = [UIButton new];
        closeButton.titleLabel.font = [UIFont systemFontOfSize:20.0];
        [closeButton setTitleColor:UIColorWithHex(0x686868) forState:UIControlStateNormal];
        [closeButton setTitle:@"关闭栅栏" forState:UIControlStateNormal];
        [closeButton sizeToFit];
        closeButton.center = CGPointMake(infoBarXCenter, infoBarYCenter);
        [closeButton addTarget:self action:@selector(nextButtonClick:) forControlEvents:UIControlEventTouchUpInside];
        [infoBarView addSubview:closeButton];
        self.closeButton = closeButton;
        
        infoLabel.hidden = YES;
        nextButton.hidden = YES;
        setButton.hidden = YES;
        switchButton.hidden = YES;
    }
    else if(self.radius > 0 && self.coord.latitude && self.coord.longitude)
    {
        infoLabel.hidden = YES;
        nextButton.hidden = YES;
        setButton.hidden = NO;
        switchButton.hidden = NO;
    }
}

#pragma mark - BMKMapViewDelegate

//处理位置坐标更新
- (void)mapView:(MAMapView *)mapView didUpdateUserLocation:(MAUserLocation *)userLocation;
{
    NSLog(@"didUpdateUserLocation lat %f,long %f, speed %f horizontalAccuracy %f verticalAccuracy %f",userLocation.location.coordinate.latitude,userLocation.location.coordinate.longitude, userLocation.location.speed, userLocation.location.horizontalAccuracy, userLocation.location.verticalAccuracy);
    self.mapView.centerCoordinate = userLocation.location.coordinate;
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
        [_mapView showAnnotations:@[self.startAnnotation,self.endAnnotation]
                         animated:NO];
        return polylineView;
    }
    if([overlay isKindOfClass:[MACircle class]])
    {
        MACircleView *circleView = [[MACircleView alloc]initWithOverlay:overlay];
        circleView.fillColor = [UIColor colorWithHex:0x16aff5 andAlpha:0.2];
        //        circleView.strokeColor = [[UIColor blueColor]colorWithAlphaComponent:0.5];
        //        circleView.lineWidth = 5.0;
        return circleView;
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
            annotationView.centerOffset = CGPointMake(0, -38);
            annotationView.image = [UIImage imageNamed:@"main_location_point_big"];
            annotationView.selected = YES;
            UIImageView *imageView = [[UIImageView alloc]initWithFrame:CGRectMake(5, 5, 45, 45)];
            
            if(self.kidInfo.kidAvatarPath.length > 0)
            {
                if(self.kidInfo.kidGender.integerValue == TYDKidGenderTypeBoy)
                {
                    NSURL *avatarUrl = [[NSURL alloc]initWithString:self.kidInfo.kidAvatarPath];
                    [imageView setImageWithURL:avatarUrl placeholderImage:[UIImage imageNamed:@"main_left_babyMale"]];
                }
                else
                {
                    NSURL *avatarUrl = [[NSURL alloc]initWithString:self.kidInfo.kidAvatarPath];
                    [imageView setImageWithURL:avatarUrl placeholderImage:[UIImage imageNamed:@"main_left_babyFemale"]];
                }
            }
            else if(self.kidInfo.kidGender.integerValue == TYDKidGenderTypeBoy)
            {
                imageView.image = [UIImage imageNamed:@"main_left_babyMale"];
            }
            else if(self.kidInfo.kidGender.integerValue == TYDKidGenderTypeGirl)
            {
                imageView.image = [UIImage imageNamed:@"main_left_babyFemale"];
            }
            imageView.layer.cornerRadius = imageView.width / 2;
            imageView.layer.masksToBounds = YES;
            [annotationView addSubview:imageView];
        }
        return annotationView;
    }
    return nil;
}

- (void)showLocationPlace
{
    TYDKidTrackInfo *kidTrackInfo = [self.userlocationPointArray lastObject];
    double latitude = [kidTrackInfo.trackLatitude doubleValue];
    double longitude = [kidTrackInfo.trackLongitude doubleValue];
    
    MAPointAnnotation *pointAnnotation = [[MAPointAnnotation alloc] init];
    pointAnnotation.coordinate = [BOCoordinateTransformation changeWGS84ToGcj02WithLatitude:latitude withLongitude:longitude];
    [self.mapView addAnnotation:pointAnnotation];
    
//    CLLocationCoordinate2D coord = CLLocationCoordinate2DMake(latitude, longitude);
//    MACoordinateRegion region = MACoordinateRegionMake(coord, MACoordinateSpanMake(0.05,  0.05));
//    [self.mapView setRegion:[self.mapView regionThatFits:region] animated:YES];
}

#pragma mark - Touch Event

- (void)editFenceButtonClick:(UIButton *)sender
{
    self.radius = 0;
    [self saveFenceToSeviceWithOptionType:FenceOptionReset];
}

- (void)addFenceToMapViewWithCoord:(CLLocationCoordinate2D )coord withRadius:(CGFloat )radius
{
    MACircle *circle = [MACircle circleWithCenterCoordinate:coord radius:radius];
    [self.mapView addOverlay:circle];
    self.fenceView.hidden = YES;
    self.circleView = circle;
}

- (void)addDrawView
{
    TYDDrawView *drawView = [TYDDrawView new];
    drawView.draweDlegate = self;
    drawView.frame = self.mapView.frame;
    drawView.backgroundColor = [UIColor grayColor];
    drawView.alpha = 0.3;
    [self.mapView addSubview:drawView];
    self.drawView = drawView;
}

- (void)changeInfoContentView
{
    for(UIView *view in self.infoContentView.subviews)
    {
        [view removeFromSuperview];
    }
}

- (void)nextButtonClick:(UIButton *)sender
{
    NSInteger optionType;
    if([sender.titleLabel.text isEqualToString:@"关闭栅栏"])
    {
        optionType = FenceOptionClose;
    }
    else
    {
        //下一步
        CGFloat circleViewWidth = self.view.size.width - 80;
        CGFloat perPointMeter = self.mapView.metersPerPointForCurrentZoomLevel;
        CGFloat radius = perPointMeter * circleViewWidth / 2;
        CLLocationCoordinate2D coord = self.mapView.centerCoordinate;
        self.coord = coord;
        self.radius = radius;
        optionType = FenceOptionSet;
    }
    self.fenceState = NO;
    [self saveFenceToSeviceWithOptionType:optionType];
}

//点击开启栅栏
- (void)switchButtonClick:(UIButton *)sender
{
    self.fenceState = YES;
    [self saveFenceToSeviceWithOptionType:FenceOptionOpen];
}

- (void)setFenceView
{
    self.infoLabel.hidden = YES;
    self.nextButton.hidden = YES;
    self.setButton.hidden = NO;
    self.switchButton.hidden = NO;
    [self addFenceToMapViewWithCoord:self.coord withRadius:self.radius];
    self.fenceView.hidden = YES;
}

- (void)reSetFenceView
{
    self.infoLabel.hidden = NO;
    self.nextButton.hidden = NO;
    self.setButton.hidden = YES;
    self.switchButton.hidden = YES;
    [self.mapView removeOverlay:self.circleView];
    self.fenceView.hidden = NO;
//    [sender sizeToFit];
}

- (void)closeFenceView
{
    self.infoLabel.hidden = YES;
    self.nextButton.hidden = YES;
    self.setButton.hidden = NO;
    self.switchButton.hidden = NO;
    //关闭栅栏
    if(self.closeButton)
    {
        [self.closeButton removeFromSuperview];
    }
}

#pragma mark - TYDDrawViewDelegate

- (void)drawEnd
{
    [self changeInfoContentView];
    UIButton *button = [UIButton new];
    button.frame = CGRectMake(40, 20, 10, 10);
    button.backgroundColor = [UIColor whiteColor];
    [button setTitle:@"确定" forState:UIControlStateNormal];
    [self.infoContentView addSubview:button];
}
#pragma mark - Connect To Server

- (void)saveFenceToSeviceWithOptionType:(NSInteger )type
{
    TYDKidInfo *kidInfo = self.kidInfo;
    NSNumber *electronicFenceState = self.fenceState ? @(1) : @(0);
    NSString *fenceCenterPoint = [NSString stringWithFormat:@"%@%f",[BOCoordinateTransformation changeGcj02ToWGS84WithLatitude:self.coord.latitude withLongitude:self.coord.longitude],self.mapView.zoomLevel];
    NSNumber *fenceRadius = @(self.radius);
    NSDictionary *params = @{ @"childid"              :kidInfo.kidID,
                              @"childname"            :kidInfo.kidName,
                              @"phone"                :kidInfo.phoneNumber,
                              @"sex"                  :kidInfo.kidGender,
                              @"birthday"             :kidInfo.kidBirthday,
                              @"weight"               :kidInfo.kidWeight,
                              @"height"               :kidInfo.kidHeight,
                              @"color"                :kidInfo.kidColorType,
                              @"address"              :kidInfo.homeAddress,
                              @"school"               :kidInfo.schoolAddress,
                              @"img"                  :kidInfo.kidAvatarPath,
                              @"relationship"         :kidInfo.kidGuardianRelationShip,
                              @"type"                 :kidInfo.kidGuardianType,
                              @"watchid"              :kidInfo.watchID,
                              @"autoconnect"          :kidInfo.autoConnectState,
                              @"silentstatus"         :kidInfo.silentState,
                              @"silenttime"           :kidInfo.silentTime,
                              @"backlighttime"        :kidInfo.backlightTime,
                              @"watchsound"           :kidInfo.watchSoundState,
                              @"watchshock"           :kidInfo.watchShockState,
                              @"cpinterval"           :kidInfo.capInterval,
                              @"electronicfence"      :electronicFenceState,
                              @"electronicFencePoints":fenceCenterPoint,
                              @"radius"               :fenceRadius,
                              @"castoff"              :kidInfo.castOff
                              };
    
    [self postURLRequestWithMessageCode:ServiceMsgCodeKidInfoUpdate
                           HUDLabelText:nil
                                 params:[params mutableCopy]
                          completeBlock:^(id result) {
                              [self saveFenceToSeviceComplete:result withOptionType:type];
                          }];
}

- (void)saveFenceToSeviceComplete:(id)result withOptionType:(NSInteger )type
{
    NSLog(@"saveCollectionPointToServerComplete:%@", result);
    NSNumber *resultCode = result[@"result"];
    
    if(resultCode != nil
       && resultCode.intValue == 0)
    {
        self.kidInfo.electronicFenceState = self.fenceState ? @(1) : @(0);
        self.kidInfo.fenceCenterPoint = [NSString stringWithFormat:@"%@%f",[BOCoordinateTransformation changeGcj02ToWGS84WithLatitude:self.coord.latitude withLongitude:self.coord.longitude],self.mapView.zoomLevel];
        self.kidInfo.fenceRadius = @(self.radius);
        if(self.fenceState)
        {
            [self progressHUDShowWithCompleteText:@"开启栅栏成功" isSucceed:YES additionalTarget:self.navigationController action:@selector(popViewControllerAnimated:) object:@YES];
        }
        else
        {
            switch(type)
            {
                case FenceOptionClose:
                {
                    [self progressHUDShowWithCompleteText:@"关闭栅栏成功" isSucceed:YES additionalTarget:self action:@selector(closeFenceView) object:@YES];
                    break;
                }
                case FenceOptionReset:
                {
                    [self progressHUDShowWithCompleteText:@"重新设定栅栏成功" isSucceed:YES additionalTarget:self action:@selector(reSetFenceView) object:@YES];
                    break;
                }
                case FenceOptionSet:
                {
                    [self progressHUDShowWithCompleteText:@"设定栅栏成功" isSucceed:YES additionalTarget:self action:@selector(setFenceView) object:@YES];
                    break;
                }
                default:
                    break;
            }
        }
    }
    else
    {
        [self progressHUDShowWithCompleteText:@"保存栅栏失败" isSucceed:NO];
    }
}


//- (void)saveFenceToLocal
//{
//    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
//    NSString *detailString = [NSString stringWithFormat:@"0,%@,%@,%@,%@",@(self.radius) ,@(self.coord.latitude) ,@(self.coord.longitude) ,@(self.mapView.zoomLevel)];
//    [userDefault setObject:detailString forKey:sLocalFenceKey];
//    [userDefault synchronize];
//    NSLog(@" saveFenceToLocal radius  %f %f",self.radius , self.mapView.zoomLevel);
//}
//
//- (void)openFenceToLocal
//{
//    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
//    NSString *detailString = [NSString stringWithFormat:@"1,%@,%@,%@,%@",@(self.radius) ,@(self.coord.latitude) ,@(self.coord.longitude) ,@(self.mapView.zoomLevel)];
//    [userDefault setObject:detailString forKey:sLocalFenceKey];
//    [userDefault synchronize];
//    [super popBackDirectly];
//}
//
//- (void)closeFenceToLocal
//{
//    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
//    NSString *detailString = [NSString stringWithFormat:@"0,%@,%@,%@,%@",@(self.radius) ,@(self.coord.latitude) ,@(self.coord.longitude) ,@(self.mapView.zoomLevel)];
//    [userDefault setObject:detailString forKey:sLocalFenceKey];
//    [userDefault synchronize];
//    [userDefault synchronize];
//}
//
//- (void)removeLocalFence
//{
//    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
//    [userDefault removeObjectForKey:sLocalFenceKey];
//    [userDefault synchronize];
//}

- (void)getLocationInfo
{
    NSTimeInterval endTime = [BOTimeStampAssistor getCurrentTime];
    NSTimeInterval startTime = endTime - nTimeIntervalSecondsPerDay;
    
    NSDictionary *params = @{@"childid"  :@(self.kidInfo.kidID.integerValue),
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
            }
            [self showLocationPlace];
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

@end
