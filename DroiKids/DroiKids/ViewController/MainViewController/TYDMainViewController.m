//
//  ViewController.m
//  DroiKids
//
//  Created by superjunjun on 15/8/5.
//  Copyright (c) 2015年 superjunjun. All rights reserved.
//

#import "TYDMainViewController.h"
#import "TYDDrawerViewController.h"
#import "TYDNoticeViewController.h"
#import "TYDLeftDrawerViewController.h"
#import "TYDLocationViewController.h"
#import <MAMapKit/MAMapKit.h>
#import <AMapSearchKit/AMapSearchAPI.h>
#import "AppDelegate.h"
#import "SBJson.h"
#import "TYDKidTrackInfo.h"
#import "TYDBabyDetailView.h"
#import "TYDQRCodeViewController.h"
#import "TYDDataCenter.h"
#import "UIButton+WebCache.h"
#import "BOOnceTimer.h"
#import <CoreTelephony/CTCallCenter.h>
#import <CoreTelephony/CTCall.h>
#import "BOCoordinateTransformation.h"
#import "TYDKidMessageInfo.h"

#define sButtonTag                          10000
#define sButtonWeight                       100
#define sButtonHeight                       60
#define sSingleDailIntervalTime             70
#define nSheetButtonShowedHeight            60
#define nPlusViewAnimationDuration          0.4//3//0.35//0.25

@interface TYDMainViewController ()<MAMapViewDelegate, AMapSearchDelegate ,TYDBabyDetailDelegate, UIAlertViewDelegate>

@property (strong, nonatomic) MAPinAnnotationView   *myAnnotation;
@property (strong, nonatomic) AMapSearchAPI         *search;
@property (strong, nonatomic) MAPointAnnotation     *startAnnotation;
@property (strong, nonatomic) MAPointAnnotation     *endAnnotation;
@property (strong, nonatomic) MAPointAnnotation     *currentPointAnnotation;

@property (strong, nonatomic) MAMapView             *mapView;
@property (strong, nonatomic) UIView                *overlayView;
@property (strong, nonatomic) UIView                *circleView;
@property (strong, nonatomic) NSMutableArray        *kidInfoArray;
@property (strong, nonatomic) NSMutableArray        *locationPointArray;
@property (assign, nonatomic) BOOL                  isFirstLocation;
@property (assign, nonatomic) BOOL                  isButtonViewExpanded;
@property (strong, nonatomic) UILabel               *timeLabel;
@property (strong, nonatomic) UILabel               *locationLabel;
@property (strong, nonatomic) UIButton              *namebutton;
@property (strong, nonatomic) TYDBabyDetailView     *detailView;
@property (strong, nonatomic) TYDKidTrackInfo       *currentKidTrackInfo;
@property (strong, nonatomic) UIButton              *showLeftButton;
@property (strong, nonatomic) UIButton              *showRightButton;
@property (strong, nonatomic) UIImageView           *batteryImageView;
@property (strong, nonatomic) UIImageView           *avatarImageView;
@property (assign, nonatomic) BOOL                  singleDailIsLock;
@property (strong, nonatomic) BOOnceTimer           *singleDailTimer;
@property (strong, nonatomic) CTCallCenter          *callCenter;

@end
@implementation TYDMainViewController

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
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    [self readRemoteNotification];

    [self getLocationAndBettaryLeft];
    [self reloadKidInfo];
    TYDLeftDrawerViewController *leftViewController = self.childViewControllers.firstObject;
    [leftViewController.tableView reloadData];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}
- (void)localDataInitialize
{
    self.kidInfoArray = [[[TYDDataCenter defaultCenter] kidInfoList] mutableCopy];
    self.locationPointArray = [NSMutableArray new];
    self.isNeedToHideNavigationBar = YES;
    
    self.singleDailIsLock = NO;
}

- (void)navigationBarItemsLoad
{
    
}

- (void)subviewsLoad
{
    [self mapViewLoad];
    [self overlayViewLoad];
    [self leftViewControllerLoad];
}

- (void)readRemoteNotification
{
    NSMutableArray *noticeArray = [[[TYDDataCenter defaultCenter]messageInfoList] mutableCopy];
    BOOL isInfoNotReadExist = NO;
    for(TYDKidMessageInfo *messageInfo in noticeArray)
    {
        if(messageInfo.infoType.integerValue == 103011
           ||messageInfo.infoType.integerValue == 103014
           ||messageInfo.infoType.integerValue == 103020
           ||messageInfo.infoType.integerValue == 103021
           ||messageInfo.infoType.integerValue == 103022
           ||messageInfo.infoType.integerValue == 103004
           ||messageInfo.infoType.integerValue == 103007
           ||messageInfo.infoType.integerValue == 103015
           ||messageInfo.infoType.integerValue == 103016)
        {
            if(messageInfo.messageUnreadFlag.integerValue == 0)
            {
                isInfoNotReadExist = YES;
            }

        }
    }
    if(isInfoNotReadExist)
    {
        //闪烁
        [self.showRightButton setBackgroundImage:[UIImage imageNamed:@"main_notice_on"] forState:UIControlStateNormal];
        self.noticeText = @"有新消息！";
    }
    else
    {
        [self.showRightButton setBackgroundImage:[UIImage imageNamed:@"main_notice_on"] forState:UIControlStateNormal];
    }
}

- (void)mapViewLoad
{
    CGRect frame = self.view.bounds;
    MAMapView *mapView = [MAMapView new];
    mapView.frame = frame;
    //不显示精度圈
    MAUserLocationRepresentation *representation = [MAUserLocationRepresentation new];
    representation.showsAccuracyRing = NO;
    representation.image = [UIImage imageNamed:@"login_qqBtn"];
    representation.showsHeadingIndicator = YES;
    [mapView updateUserLocationRepresentation:representation];
    mapView.showsUserLocation = YES;//显示定位图层
    mapView.userTrackingMode = MAUserTrackingModeFollow;//设置定位的状态
    //设置地图缩放级别
    [mapView setZoomLevel:16.1 animated:YES];
    mapView.distanceFilter = 5.0;
    mapView.desiredAccuracy = kCLLocationAccuracyBest;
    _search = [[AMapSearchAPI alloc] initWithSearchKey:sGaodeMapSDKAppKey Delegate:self];
    mapView.showsCompass = NO;
    mapView.showsScale = NO;
    mapView.delegate = self;
    mapView.pausesLocationUpdatesAutomatically = NO;
    mapView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    [self.view addSubview:mapView];
    
    self.mapView = mapView;
//    CLLocationCoordinate2D testq = [BOCoordinateTransformation changeWGS84ToGcj02WithLatitude:31.166335 withLongitude:121.398001];
//    NSLog(@"x=%f %f",testq.latitude,testq.longitude);
//    
//    NSLog(@"  %@",[BOCoordinateTransformation changeGcj02ToWGS84WithLatitude:testq.latitude withLongitude:testq.longitude]);
}

- (void)overlayViewLoad
{
    //默认第一个孩子显示
    TYDKidInfo *kidInfo = [[TYDDataCenter defaultCenter]currentKidInfo];
    
    CGRect frame = self.view.bounds;
    UIView *overlayView = [[UIView alloc] initWithFrame:frame];
    overlayView.alpha = 1.0f;
    overlayView.backgroundColor = cBasicGreenColor;
    overlayView.userInteractionEnabled = YES;
    overlayView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    [self.view addSubview:overlayView];
    //显示宝贝头像
    UIButton *showLeftButton = [UIButton buttonWithType:UIButtonTypeCustom];
    showLeftButton.left = 17;
    showLeftButton.top = 30;
    showLeftButton.size = CGSizeMake(60, 60);
//    [showLeftButton setBackgroundImage:[UIImage imageNamed:@"main_left_babyMale"] forState:UIControlStateNormal];
    [showLeftButton addTarget:self action:@selector(showLeftButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    showLeftButton.layer.cornerRadius = showLeftButton.size.width / 2;
    showLeftButton.layer.masksToBounds = YES;
    [overlayView addSubview:showLeftButton];
    
    UIImageView *batteryImageView = [UIImageView new];
    batteryImageView.image = [UIImage imageNamed:@"main_battery_empty"];
    batteryImageView.top = showLeftButton.bottom + 5;
    [batteryImageView sizeToFit];
    batteryImageView.xCenter = showLeftButton.xCenter;
    [overlayView addSubview:batteryImageView];
    
    //title 宝贝名字
    UIButton *namebutton = [UIButton new];
    UIImage *image = [UIImage imageNamed:@"main_pop_arrow_down"];
    UIImage *imageH = [UIImage imageNamed:@"main_pop_arrow_up"];
    NSString *nameString = kidInfo.kidName;
    namebutton.titleLabel.font = [UIFont systemFontOfSize:16.0];
    [namebutton setTitle:nameString forState:UIControlStateNormal];
    NSInteger imageWidth = image.size.width;
    CGSize stringSize = [BOAssistor string:nameString sizeWithFont:[UIFont systemFontOfSize:16.0]];
    NSInteger titleWidth = stringSize.width;
    NSInteger titleHeight = stringSize.height;
    namebutton.size = CGSizeMake(140, titleHeight + 40);
    [namebutton setContentHorizontalAlignment:UIControlContentHorizontalAlignmentCenter];
    [namebutton setImage:image forState:UIControlStateNormal];
    [namebutton setImage:imageH forState:UIControlStateSelected];
    [namebutton setTitleEdgeInsets:UIEdgeInsetsMake(0, 30 - imageWidth, 0, imageWidth)];
    [namebutton setImageEdgeInsets:UIEdgeInsetsMake(0, titleWidth + 20, 0, -titleWidth)];
    namebutton.center = CGPointMake(self.view.xCenter, showLeftButton.yCenter);
    [namebutton addTarget:self action:@selector(changeBaby:) forControlEvents:UIControlEventTouchUpInside];
    [overlayView addSubview:namebutton];
    
    //显示右侧界面button
    UIButton *showRightButton = [UIButton buttonWithType:UIButtonTypeCustom];
    showRightButton.left = self.view.right - 50;
    showRightButton.size = CGSizeMake(34, 34);
    showRightButton.yCenter = showLeftButton.yCenter;
    [showRightButton setBackgroundImage:[UIImage imageNamed:@"main_notice_on"] forState:UIControlStateNormal];
    [showRightButton addTarget:self action:@selector(showRightButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    [overlayView addSubview:showRightButton];
    
    NSInteger circleViewWidth = frame.size.width - 30;
    NSInteger originalY = self.view.center.y - circleViewWidth / 2;
    UIView *circleView = [[UIView alloc] initWithFrame:CGRectMake(15, originalY, circleViewWidth, circleViewWidth)];
    circleView.layer.borderColor = [UIColor colorWithRed:236.0 / 255 green:223.0 / 255 blue:64.0 / 255 alpha:1.0].CGColor;
    circleView.layer.borderWidth = 5.0f;
    circleView.layer.cornerRadius = circleViewWidth / 2;
    circleView.autoresizingMask = UIViewAutoresizingNone;
    circleView.userInteractionEnabled = NO;
    [overlayView addSubview:circleView];
    
    
    UIView *grayview = [UIView new];
    grayview.top = circleView.top;
    grayview.left = 0;
    grayview.width = frame.size.width;
    grayview.height = 70;
    grayview.backgroundColor = [UIColor blackColor];
    grayview.alpha = 0.5;
    [self.view insertSubview:grayview belowSubview:overlayView];
    
    NSArray *nameArray = @[@"通话", @"单向通话"];
    NSArray *imageArray = @[@"main_call", @"main_callOnceWay"];
    NSArray *imagePushArray = @[@"main_call_push", @"main_callOnceWay_push"];
    NSInteger topGap = frame.size.height>480?38:20;
    NSInteger leftGap = 17;
    NSInteger buttonWidth = 132;
    NSInteger buttonHeight = 41;
    NSInteger buttonGap = frame.size.width - (leftGap + buttonWidth) * 2;
    for(int i = 0; i < nameArray.count; i++)
    {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        [button setBackgroundImage:[UIImage imageNamed:imageArray[i]] forState:UIControlStateNormal];
        [button setBackgroundImage:[UIImage imageNamed:imagePushArray[i]] forState:UIControlStateHighlighted];
        button.left = leftGap + (buttonWidth + buttonGap) * i;
        button.top = circleView.bottom + topGap;
        button.width = buttonWidth;
        button.height = buttonHeight;
        button.tag = sButtonTag + i;
        [button addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
        [overlayView addSubview:button];
        
        UILabel *label = [UILabel new];
        label.text = nameArray[i];
        label.font = [UIFont systemFontOfSize:14.0];
        label.textColor = [UIColor whiteColor];
        [label sizeToFit];
        label.top = button.bottom + 12;
        label.xCenter = button.xCenter;
        [overlayView addSubview:label];
    }
    UILabel *timeLabel = [UILabel new];
    timeLabel.text = @" ";
    timeLabel.font = [UIFont systemFontOfSize:12.0];
    [timeLabel sizeToFit];
    timeLabel.top = 20;
    timeLabel.xCenter = self.view.xCenter;
    timeLabel.textColor = [UIColor whiteColor];
    [grayview addSubview:timeLabel];
    
    UILabel *locationLabel = [UILabel new];
    locationLabel.text = @"未获取到定位地点";
    locationLabel.font = [UIFont systemFontOfSize:16.0];
    [locationLabel sizeToFit];
    locationLabel.top = timeLabel.bottom + 5;
    locationLabel.xCenter = timeLabel.xCenter;
    locationLabel.textColor = [UIColor whiteColor];
    [grayview addSubview:locationLabel];
    
    self.showLeftButton = showLeftButton;
    self.showRightButton = showRightButton;
    self.batteryImageView = batteryImageView;
    self.namebutton = namebutton;
    self.circleView = circleView;
    self.overlayView = overlayView;
    self.timeLabel = timeLabel;
    self.locationLabel = locationLabel;

    [self overlayClip];
    [self reloadKidInfo];
}

- (void)overlayClip
{
    CGFloat radius = (self.circleView.frame.size.width - 10)/ 2;
    CGPoint point = self.circleView.center;
    UIBezierPath *maskPath = [UIBezierPath bezierPathWithRect:self.view.bounds];
    [maskPath appendPath:[UIBezierPath bezierPathWithArcCenter:point radius:radius startAngle:0 endAngle:2 * M_PI clockwise:NO]];
    
    CAShapeLayer *shapeLayer = [CAShapeLayer layer];
    shapeLayer.path = maskPath.CGPath;
    
    self.overlayView.layer.mask = shapeLayer;
}

- (void)leftViewControllerLoad
{
    CGRect frame = self.view.frame;
    UIView *grayView = [[UIView alloc]initWithFrame:frame];
    grayView.backgroundColor = [UIColor colorWithHex:0x000000];
    grayView.hidden = YES;
    grayView.alpha = 0;
    [self.view insertSubview:grayView aboveSubview:self.circleView];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(grayViewDismiss)];
    [grayView addGestureRecognizer:tap];
    self.grayView = grayView;
    
    UIViewController *LeftViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"LeftViewController"];
    [self addChildViewController:LeftViewController];
    LeftViewController.view.frame = CGRectMake(-frame.size.width, 0, frame.size.width, frame.size.height);
    [self.view addSubview:LeftViewController.view];
}


- (void)getLocationAndBettaryLeft
{
    [self operationToServerWithType:TYDGetBettaryLeft];
    [self operationToServerWithType:TYDGetKidLocationInfo];
}

- (void)reloadKidInfo
{
    TYDLeftDrawerViewController *leftViewController = self.childViewControllers.firstObject;
    if(leftViewController.view.frame.origin.x != 0)
    {
        [self grayViewDismiss];
    }
    TYDKidInfo *kidInfo = [[TYDDataCenter defaultCenter]currentKidInfo];
    [self.namebutton setTitle:kidInfo.kidName forState:UIControlStateNormal];
    CGSize stringSize = [BOAssistor string:kidInfo.kidName sizeWithFont:[UIFont systemFontOfSize:16.0]];
    [self.namebutton setImageEdgeInsets:UIEdgeInsetsMake(0, stringSize.width + 20, 0, -stringSize.width)];
    if(kidInfo.kidAvatarPath.length > 0)
    {
        if(kidInfo.kidGender.integerValue == TYDKidGenderTypeBoy)
        {
            [self.avatarImageView setImageWithURL:[NSURL URLWithString:kidInfo.kidAvatarPath] placeholderImage:[UIImage imageNamed:@"main_left_babyMale"]];
            [self.showLeftButton setImageWithURL:[NSURL URLWithString:kidInfo.kidAvatarPath] forState:UIControlStateNormal placeholderImage:[UIImage imageNamed:@"main_left_babyMale"]];
        }
        else
        {
            [self.avatarImageView setImageWithURL:[NSURL URLWithString:kidInfo.kidAvatarPath] placeholderImage:[UIImage imageNamed:@"main_left_babyFemale"]];
            [self.showLeftButton setImageWithURL:[NSURL URLWithString:kidInfo.kidAvatarPath] forState:UIControlStateNormal placeholderImage:[UIImage imageNamed:@"main_left_babyFemale"]];
        }
    }
    else if(kidInfo.kidGender.integerValue == TYDKidGenderTypeBoy)
    {
        self.avatarImageView.image = [UIImage imageNamed:@"main_left_babyMale"];
        [self.showLeftButton setImage:[UIImage imageNamed:@"main_left_babyMale"] forState:UIControlStateNormal];
    }
    else if(kidInfo.kidGender.integerValue == TYDKidGenderTypeGirl)
    {
        self.avatarImageView.image = [UIImage imageNamed:@"main_left_babyFemale"];
        [self.showLeftButton setImage:[UIImage imageNamed:@"main_left_babyFemale"] forState:UIControlStateNormal];
    }
    [self reloadLocation:kidInfo.currentLocation];
    [self reloadBettry:kidInfo.batteryLeft.integerValue];
}

- (void)reloadLocation:(NSString *)currentLocation
{
    if(currentLocation)
    {
        NSArray *array = [currentLocation componentsSeparatedByString:@","];
        if(array.count == 3)
        {
            if(self.currentPointAnnotation)
            {
                [self.mapView removeAnnotations:@[self.currentPointAnnotation]];
            }
            CLLocationCoordinate2D coord = [BOCoordinateTransformation changeWGS84ToGcj02WithLatitude:[array.firstObject doubleValue] withLongitude:[array[1] doubleValue]];
            [self clickReverseGeoCode:coord];
            MAPointAnnotation *pointAnnotation = [[MAPointAnnotation alloc] init];
            pointAnnotation.coordinate = coord;
            self.currentPointAnnotation = pointAnnotation;
            [self.mapView addAnnotation:pointAnnotation];
        }
        self.timeLabel.text = [BOTimeStampAssistor getHourStringWithTimeStamp:[array.lastObject integerValue]];
    }
}
- (void)reloadBettry:(NSInteger )batteryLeft
{
    if(batteryLeft)
    {
        NSArray *imageArray = @[@"main_battery_empty", @"main_battery_low", @"main_battery_abundant",@"main_battery_full"];
        self.batteryImageView.image = [UIImage imageNamed:imageArray[batteryLeft]];
    }
}

#pragma mark - Touch Event


#pragma mark - ShowViewController

- (void)showLeftButtonClick:(UIButton *)sender
{
    NSInteger width = self.view.width;
    TYDLeftDrawerViewController *leftViewController = self.childViewControllers.firstObject;
    self.grayView.hidden = NO;
    [leftViewController.tableView reloadData];
    [UIView animateWithDuration:.3 animations:^{
        CATransform3D transform = CATransform3DMakeTranslation(width, 0, 0);
        leftViewController.view.layer.transform = transform;
        self.grayView.alpha = 0.5;
    } completion:^(BOOL finished) {
    }];
}

- (void)showRightButtonClick:(UIButton *)sender
{
    TYDNoticeViewController *vc = [TYDNoticeViewController new];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)buttonClick:(UIButton *)sender
{
    switch(sender.tag - sButtonTag)
    {
        case 0:
        {
            //直接拨打 没有弹出框 通话
            NSLog(@"通话");
            NSMutableString *numberStr = [[NSMutableString alloc] initWithFormat:@"tel:%@", [[[TYDDataCenter defaultCenter]currentKidInfo] phoneNumber]];
            UIWebView * callWebview = [[UIWebView alloc] init];
            [callWebview loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:numberStr]]];
            [self.view addSubview:callWebview];
            break;
        }
        case 1:
        {
            //单向通话
            NSLog(@"单向通话");
            [self telephoneCallHandle];
            
            break;
        }
            
        default:
            break;
    }
}

- (void)showLocationPlace
{
    NSArray *array = self.locationPointArray;
    if (array.count > 0)
    {
        self.currentKidTrackInfo = array.lastObject;
        
        NSInteger coordCount = array.count;
        CLLocationCoordinate2D coords[coordCount];
        for(int i = 0; i < coordCount; i++)
        {
            TYDKidTrackInfo *kidTrackInfo = array[i];
            double latitude = [kidTrackInfo.trackLatitude doubleValue];
            double longitude = [kidTrackInfo.trackLongitude doubleValue];
            coords[i].latitude = latitude;
            coords[i].longitude = longitude;
            
            MAPointAnnotation *pointAnnotation = [[MAPointAnnotation alloc] init];
            pointAnnotation.coordinate = [BOCoordinateTransformation changeWGS84ToGcj02WithLatitude:latitude withLongitude:longitude];
            if(i == coordCount - 1)
            {
                self.mapView.centerCoordinate = pointAnnotation.coordinate;
                pointAnnotation.title = @"selected";
                self.timeLabel.text = [BOTimeStampAssistor getHourStringWithTimeStamp:kidTrackInfo.infoCreateTime.integerValue];
                [self clickReverseGeoCode:pointAnnotation.coordinate];
            }
            [self.mapView addAnnotation:pointAnnotation];
        }
//        MACoordinateRegion region = MACoordinateRegionMake(coords[2], MACoordinateSpanMake(0.05,  0.05));
//        [self.mapView setRegion:[self.mapView regionThatFits:region] animated:YES];
    }
    else
    {
        self.noticeText = @"没有当前儿童定位信息";
    }
}

#pragma mark - TelephoneCallHandle

- (void)telephoneCallHandle
{
    if(!self.callCenter)
    {
        self.callCenter = [[CTCallCenter alloc] init];
    }
    
    if(self.callCenter.currentCalls.count == 0)
    {
        if(self.singleDailIsLock)
        {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"单向通话" message:@"正在连接，请稍后再拨" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
            
            [alertView show];
        }
        else
        {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"单向通话" message:@"是否进行单向通话" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
            
            [alertView show];
        }
    }
    else
    {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"单向通话" message:@"通话正忙，请稍后再拨" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        
        [alertView show];
    }
}

- (void)singleDailHandle
{
    if(self.singleDailIsLock)
    {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"单向通话" message:@"正在连接，请稍后再拨" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        
        [alertView show];
    }
    else
    {
        self.singleDailIsLock = YES;
        self.singleDailTimer = [[BOOnceTimer alloc] initWithTitle:@"singleDailIntervalTimer" target:self selector:@selector(communicateTimeoutEvent) object:nil delay:sSingleDailIntervalTime];
        [self.singleDailTimer onceTimerStart];
        //请求服务器...
        [self operationToServerWithType:TYDTelephoneConversations];
    }
}

- (void)communicateTimeoutEvent
{
    [self.singleDailTimer onceTimerCancel];
    
    self.singleDailIsLock = NO;
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    CGPoint point = [touch locationInView:self.view];
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathAddEllipseInRect(path, NULL, self.circleView.frame);
    if(touch.tapCount == 1 && CGPathContainsPoint(path, NULL, point, NULL))
    {
        NSLog(@"在圆内");
        NSLog(@"%@", event);
        TYDLocationViewController *vc = [TYDLocationViewController new];
        [self.navigationController pushViewController:vc animated:YES];
    }
    else
    {
        NSLog(@"在圆外");
    }
    NSLog(@"touchesEnded");
}

- (void)changeBaby:(UIButton *)sender
{
    self.grayView.hidden = NO;
    self.grayView.alpha = 0.5;
    self.namebutton.selected = YES;
    NSArray *array = [[TYDDataCenter defaultCenter] kidInfoList];
    TYDBabyDetailView *detailView = [[TYDBabyDetailView alloc]initWithkidInfoArray:array];
    detailView.alpha = 0;
    [UIView animateWithDuration:.3 animations:^{
        detailView.alpha = 1.0;
    } completion:^(BOOL finished) {
    }];
    detailView.kidInfoArray = [array mutableCopy];
//    detailView.currentBabyName = sender.titleLabel.text;
    detailView.delegate = self;
    detailView.top = sender.bottom - 20;
    detailView.xCenter = sender.xCenter;
    [self.view addSubview:detailView];
    self.detailView = detailView;
}

- (void)grayViewDismiss
{
    self.grayView.hidden = YES;
    self.namebutton.selected = NO;
    [UIView animateWithDuration:.3 animations:^{
        self.detailView.alpha = 0;
    } completion:^(BOOL finished) {
        [self.detailView removeFromSuperview];
    }];
}

#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if([alertView.title isEqualToString:@"单向通话"])
    {
        if(buttonIndex != alertView.cancelButtonIndex)
        {
            NSString *buttonTitle = [alertView buttonTitleAtIndex:buttonIndex];
            
            if([buttonTitle isEqualToString:@"确定"])
            {
                [self singleDailHandle];
            }
        }
    }
}

#pragma mark - TYDBabyDetailDelegate

- (void)switchBaby:(NSString *)baby
{
    [self getLocationAndBettaryLeft];
    [self reloadKidInfo];
}

- (void)addBaby
{
    TYDQRCodeViewController *vc = [TYDQRCodeViewController new];
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - BMKMapViewDelegate

//处理位置坐标更新
- (void)mapView:(MAMapView *)mapView didUpdateUserLocation:(MAUserLocation *)userLocation;
{
    NSLog(@"didUpdateUserLocation lat %f,long %f, speed %f horizontalAccuracy %f verticalAccuracy %f",userLocation.location.coordinate.latitude,userLocation.location.coordinate.longitude, userLocation.location.speed, userLocation.location.horizontalAccuracy, userLocation.location.verticalAccuracy);
    if(!self.isFirstLocation)
    {
        CLLocationCoordinate2D coor;
        coor.latitude = userLocation.location.coordinate.latitude;
        coor.longitude = userLocation.location.coordinate.longitude;
        self.isFirstLocation = YES;
        MAPointAnnotation *pointAnnotation = [[MAPointAnnotation alloc] init];
        pointAnnotation.coordinate = [BOCoordinateTransformation changeWGS84ToGcj02WithLatitude:coor.latitude withLongitude:coor.longitude];
        [_mapView addAnnotation:pointAnnotation];
        self.mapView.showsUserLocation = NO;
    }
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
        circleView.fillColor = [[UIColor redColor]colorWithAlphaComponent:0.5];
        circleView.strokeColor = [[UIColor blueColor]colorWithAlphaComponent:0.5];
        circleView.lineWidth = 5.0;
        return circleView;
    }
    return nil;
}

- (MAAnnotationView *)mapView:(MAMapView *)mapView viewForAnnotation:(id<MAAnnotation>)annotation
{
    if ([annotation isKindOfClass:[MAPointAnnotation class]])
    {
        static NSString *reuseIndetifier = @"annotationReuseIndetifier";
        MAAnnotationView *annotationView = (MAAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:reuseIndetifier];
        if (annotationView == nil)
        {
            annotationView = [[MAAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:reuseIndetifier];
        }
        annotationView.image = [UIImage imageNamed:@"main_location_point_big"];
        //设置中⼼心点偏移，使得标注底部中间点成为经纬度对应点
        annotationView.centerOffset = CGPointMake(0, -15);
        annotationView.canShowCallout= YES;       //设置气泡可以弹出，默认为NO
        annotationView.draggable = YES;
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
        [annotationView addSubview:imageView];
        self.avatarImageView = imageView;
        //设置标注可以拖动，默认为NO
        return annotationView;
    }
    return nil;
}

#pragma mark - BMKGeoCodeSearchDelegate

//获取反编码状态
- (void)clickReverseGeoCode:(CLLocationCoordinate2D)coordinate
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
//    self.timeLabel.text = ;
    self.locationLabel.text = locationString;
    [self.locationLabel sizeToFit];
}

#pragma mark - Connect To Server

//- (void)getLocationInfo
//{
//    NSTimeInterval endTime = [BOTimeStampAssistor getCurrentTime];
//    NSTimeInterval startTime = endTime - nTimeIntervalSecondsPerDay;
//    TYDKidInfo *kidInfo =  [[TYDDataCenter defaultCenter]currentKidInfo];
//    
//    NSDictionary *params = @{@"childid"  :@(kidInfo.kidID.integerValue),
//                             @"stime"    :@(startTime),
//                             @"etime"    :@(endTime)
//                            };
//
//    [self postURLRequestWithMessageCode:ServiceMsgCodeKidTrackRequest
//                           HUDLabelText:nil
//                                 params:[params mutableCopy]
//                          completeBlock:^(id result) {
//                              [self parseUseLocationInfo:result];
//                          }];
//}
//
//- (void)parseUseLocationInfo:(id)result
//{
//    NSLog(@"parseUseLocationInfoComplete:%@", result);
//    NSDictionary *dic = result;
//    NSNumber *resultCode = result[@"result"];
//
//    if(resultCode != nil
//       && resultCode.intValue == 0)
//    {
//        NSArray *locationPointarray = [dic objectForKey:@"historyposition"];
//        if(locationPointarray.count > 0)
//        {
//            for(NSDictionary *detailDic in locationPointarray)
//            {
//                TYDKidTrackInfo *kidTrackInfo = [TYDKidTrackInfo new];
//                [kidTrackInfo setAttributes:detailDic];
//                [self.locationPointArray addObject:kidTrackInfo];
//            }
//            [self showLocationPlace];
//        }
//        else
//        {
//            self.noticeText = @"没有当前儿童定位信息";
//        }
//    }
//    else
//    {
//        self.noticeText = @"获取定位信息失败";
//    }
//    [self progressHUDHideImmediately];
//}

// 请求电量  单向通话  获取定位点
- (void)operationToServerWithType:(NSInteger )type
{
    NSDictionary *params = @{@"openid"  :[[TYDUserInfo sharedUserInfo] openID],
                             @"watchid" :[[[TYDDataCenter defaultCenter]currentKidInfo] watchID],
                             @"type"    :@(type)
                             };
    [self postURLRequestWithMessageCode:ServiceMsgCodeSetWatchOperate
                           HUDLabelText:nil
                                 params:[params mutableCopy]
                          completeBlock:^(id result) {
                              [self operationToServerComplete:result];
                          }];
    [self progressHUDHideImmediately];
}

- (void)operationToServerComplete:(id)result
{
    NSLog(@"parseUseLocationInfoComplete:%@", result);
    NSNumber *resultCode = result[@"result"];
    
    if(resultCode != nil
       && resultCode.intValue == 0)
    {
        NSLog(@"parseUseLocationInfoCompleteSuccess");
    }
//     [self progressHUDHideImmediately];
}

@end
