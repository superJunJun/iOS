//
//  TYDHistoricalTrackViewController.m
//  DroiKids
//
//  Created by superjunjun on 15/8/18.
//  Copyright (c) 2015年 superjunjun. All rights reserved.
//

#import "TYDHistoricalTrackViewController.h"
#import <MAMapKit/MAMapKit.h>
#import <AMapSearchKit/AMapSearchAPI.h>
#import "TYDHistoricalTrackCalendarView.h"
#import "SBJson.h"
#import "TYDKidTrackInfo.h"
#import "TYDDataCenter.h"
#import "BOCoordinateTransformation.h"

@interface TYDHistoricalTrackViewController ()<MAMapViewDelegate, AMapSearchDelegate,TYDHistoricalTrackCalendarViewDelegate>

@property (strong, nonatomic) MAPinAnnotationView   *myAnnotation;
@property (strong, nonatomic) AMapSearchAPI         *search;
@property (strong, nonatomic) MAPointAnnotation     *startAnnotation;
@property (strong, nonatomic) MAPointAnnotation     *endAnnotation;
@property (strong, nonatomic) MAMapView             *mapView;
@property (strong, nonatomic) MAPolyline            *polyLine;

@property (strong, nonatomic) NSMutableArray        *locationPointArray;
@property (strong, nonatomic) NSMutableArray        *pointAnnotation;

@property (strong, nonatomic) TYDHistoricalTrackCalendarView *calendarView;
@property (nonatomic) BOOL isCalendarOpen;

@property (strong, nonatomic) UIView *calendarBgView;
@end

@implementation TYDHistoricalTrackViewController

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
    //默认的是今天的定位信息
    [self getLocationInfo:[BOTimeStampAssistor getCurrentTime]];
}

- (void)localDataInitialize
{
    self.locationPointArray = [NSMutableArray new];
    self.pointAnnotation = [NSMutableArray new];
    self.isCalendarOpen = NO;
}

- (void)navigationBarItemsLoad
{
    self.title = @"历史记录";
}

- (void)subviewsLoad
{
    [self mapViewLoad];
    self.calendarView.hidden = NO;
}

- (void)mapViewLoad
{
    CGRect frame = self.view.bounds;
    MAMapView *mapView = [MAMapView new];
    mapView.frame = frame;
    mapView.showsUserLocation = YES;
//    //不显示精度圈
//    MAUserLocationRepresentation *representation = [MAUserLocationRepresentation new];
//    representation.showsAccuracyRing = NO;
//    representation.image = [UIImage imageNamed:@"login_qqBtn"];
//    representation.showsHeadingIndicator = YES;
//    [mapView updateUserLocationRepresentation:representation];
//    mapView.showsUserLocation = YES;//显示定位图层
//    mapView.userTrackingMode = MAUserTrackingModeFollow;//设置定位的状态
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
}

#pragma mark - MapOverLay

- (void)showLocationPoint
{
    NSArray *array = self.locationPointArray;
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
        [_mapView addAnnotation:pointAnnotation];
        [self.pointAnnotation addObject:pointAnnotation];
    }
    // 添加路线overlay
    MAPolyline *polyLine = [MAPolyline polylineWithCoordinates:coords count:coordCount];
    [self.mapView addOverlay:polyLine];
    MACoordinateRegion region = MACoordinateRegionMake(coords[2], MACoordinateSpanMake( 0.05,  0.05));
    [self.mapView setRegion:[self.mapView regionThatFits:region] animated:YES];
    self.polyLine = polyLine;
}

- (void)cleanOverLay
{
    if(self.polyLine)
    {
        [self.mapView removeOverlay:self.polyLine];
        [self.mapView removeAnnotations:self.pointAnnotation];
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
        }
        annotationView.image = [UIImage imageNamed:@"main_location_point"];
        //设置中⼼心点偏移，使得标注底部中间点成为经纬度对应点
        annotationView.centerOffset = CGPointMake(0, -18);
        annotationView.canShowCallout= YES;       //设置气泡可以弹出，默认为NO
        annotationView.draggable = YES;        //设置标注可以拖动，默认为NO
        return annotationView;
    }
    return nil;
}

#pragma mark - HistoricalCalendar

- (TYDHistoricalTrackCalendarView *)calendarView
{
    if(!_calendarView)
    {
        UIView *baseView = self.view;
        CGRect frame = baseView.bounds;
        frame.size.height = 65;
        TYDHistoricalTrackCalendarView *calendarView = [[TYDHistoricalTrackCalendarView alloc] initWithFrame:frame];
        calendarView.bottom = baseView.height;
        calendarView.delegate = self;
        calendarView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
        calendarView.backgroundColor = [UIColor clearColor];
        [baseView addSubview:calendarView];
        _calendarView = calendarView;
        
        UIView *calendarBgView = [[UIView alloc]initWithFrame:baseView.bounds];
        calendarBgView.backgroundColor = [UIColor colorWithHex:0x0 andAlpha:0.3];
        calendarBgView.top = self.view.bottom;
        calendarBgView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
        UITapGestureRecognizer *tapGr = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(calendarBgViewTapEvent:)];
        [calendarBgView addGestureRecognizer:tapGr];
        UISwipeGestureRecognizer *swipeGr = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(swipeTapEvent)];
        [swipeGr setDirection:UISwipeGestureRecognizerDirectionDown];
        [calendarBgView addGestureRecognizer:swipeGr];
        [self.view addSubview:calendarBgView];
        
        self.calendarBgView.hidden = YES;
        self.calendarBgView.alpha = 0;
        self.calendarBgView = calendarBgView;
    }
    return _calendarView;
}


- (void)calendarBgViewTapEvent:(UITapGestureRecognizer *)sender
{
    [self historicalTrackCalendarViewBelowViewAction:self.calendarView];
}

- (void)historicalTrackCalendarViewBelowViewAction:(TYDHistoricalTrackCalendarView *)calendarView
{
    self.isCalendarOpen = !self.isCalendarOpen;
    if(self.isCalendarOpen)
    {
        self.calendarBgView.alpha = 0;
        self.calendarBgView.hidden = NO;
        self.calendarBgView.bottom = self.view.bottom;
        [UIView animateWithDuration:0.25
                              delay:0
                            options:UIViewAnimationOptionCurveEaseInOut
                         animations:^{
                             self.calendarBgView.alpha = 1;
                             [self.view insertSubview:self.calendarView aboveSubview:self.calendarBgView];
                         }
                         completion:nil];
        CGRect frame = self.view.bounds;
        frame.size.height = 65 + 36 * 6;
        calendarView.frame = frame;
        calendarView.bottom = self.view.height;
        calendarView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
        [calendarView  openCalendar];
    }
    else
    {
        [self closeCalenderEvent];
    }
}

- (void)swipeTapEvent
{
    if(self.isCalendarOpen)
    {
        self.isCalendarOpen = NO;
        [self closeCalenderEvent];
        NSLog(@"swipeTapEvent");
    }
}

- (void)closeCalenderEvent
{
    [UIView animateWithDuration:0.25
                          delay:0
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         self.calendarBgView.top = self.view.bottom;
                         self.calendarBgView.alpha = 0;
                         self.calendarBgView.hidden = YES;
                     }
                     completion:nil];
    
    CGRect frame = self.view.bounds;
    frame.size.height = 65;
    self.calendarView.frame = frame;
    self.calendarView.bottom = self.view.height;
    self.calendarView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
    [self.calendarView closeCalendar];
}

- (void)dateBlockSelectedIndex:(NSInteger)index withDate:(NSDate *)date withDay:(NSInteger)day
{
    NSInteger newDateBeginningTimeStamp = [BOTimeStampAssistor timeStampOfMonthBeginningWithTimerStamp:[date timeIntervalSince1970]] + (day-1) * nTimeIntervalSecondsPerDay;//点击某个日期得到该天的开始时间戳
    NSLog(@"%ld,%ld",(long)newDateBeginningTimeStamp,(long)day);
    //每点击一天取一天的数据
    [self getLocationInfo:newDateBeginningTimeStamp];
}

- (void)weekdayTitleBarSelectedWithIntervalToToday:(NSInteger)interval
{
    NSInteger newDateBeginningTimeStamp = [BOTimeStampAssistor timeStampOfDayBeginningForToday] - interval *nTimeIntervalSecondsPerDay;
    NSLog(@"%ld", (long)newDateBeginningTimeStamp);
}


#pragma mark - Connect To Server

- (void)getLocationInfo:(NSTimeInterval )timeInterval
{
    NSTimeInterval startTime = timeInterval;
    NSTimeInterval endTime = timeInterval + nTimeIntervalSecondsPerDay;
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
                [kidTrackInfo setAttributes:detailDic];
                [self.locationPointArray addObject:kidTrackInfo];
            }
            //获取历史记录成功，删除前一天的数据，然后加载当前的数据
            [self cleanOverLay];
            [self showLocationPoint];
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
