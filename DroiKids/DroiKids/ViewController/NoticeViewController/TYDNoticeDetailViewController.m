//
//  TYDNoticeDetailViewController.m
//  DroiKids
//
//  Created by superjunjun on 15/9/1.
//  Copyright (c) 2015年 TYDTech. All rights reserved.
//

#import "TYDNoticeDetailViewController.h"
#import "TYDDataCenter.h"
#import <MAMapKit/MAMapKit.h>
#import <AMapSearchKit/AMapSearchAPI.h>
#import "BOCoordinateTransformation.h"

#define sLocationButtonTag                          1000
#define sLocationIconImageViewTag                   10000

@interface TYDNoticeDetailViewController ()<MAMapViewDelegate, AMapSearchDelegate, UIGestureRecognizerDelegate>

@property (strong, nonatomic) MAPinAnnotationView   *myAnnotation;
@property (strong, nonatomic) AMapSearchAPI         *search;
@property (strong, nonatomic) MAPointAnnotation     *startAnnotation;
@property (strong, nonatomic) MAPointAnnotation     *endAnnotation;
@property (strong, nonatomic) MAAnnotationView      *currentAnnotationView;
@property (strong, nonatomic) MAMapView             *mapView;
@property (strong, nonatomic) MAPolyline            *polyLine;
@property (strong, nonatomic) UILabel               *locationInfoLabel;

@end

@implementation TYDNoticeDetailViewController

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
    //[self showCollectPlace];
}

- (void)localDataInitialize
{
//    self.pointAnnotation = [NSMutableArray new];
//    self.collectedPointAnnotation = [NSMutableArray new];
//    self.collectedAnnotation = [NSMutableArray new];
}

- (void)navigationBarItemsLoad
{
    self.title = self.noticeType;
}

- (void)subviewsLoad
{
    [self mapViewLoad];
    [self locationInfoBarLoad];
}

- (void)mapViewLoad
{
    MAMapView *mapView = [[MAMapView alloc]initWithFrame:self.view.frame];
    [self.view addSubview:mapView];
    //设置地图缩放级别
    [mapView setZoomLevel:16.1 animated:YES];
    _search = [[AMapSearchAPI alloc] initWithSearchKey:sGaodeMapSDKAppKey Delegate:self];
    mapView.showsCompass = NO;
    mapView.showsScale = NO;
    mapView.delegate = self;
    self.mapView = mapView;
    if(self.noticeLocation.length > 0)
    {
        NSArray *array = [self.noticeLocation componentsSeparatedByString:@","];
        if(array.count == 2)
        {
            CLLocationCoordinate2D coord = CLLocationCoordinate2DMake([array.firstObject doubleValue], [array.lastObject doubleValue]);
            mapView.centerCoordinate = coord;
            MAPointAnnotation *pointAnnotation = [[MAPointAnnotation alloc] init];
            pointAnnotation.coordinate = [BOCoordinateTransformation changeWGS84ToGcj02WithLatitude:coord.latitude withLongitude:coord.longitude];
            [mapView addAnnotation:pointAnnotation];
        }
    }
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
    NSInteger buttonWidth = 50;
    
    UILabel *noticeTypeLabel = [UILabel new];
    noticeTypeLabel.text = [NSString stringWithFormat:@"%@%@",self.noticeTime, self.noticeType];
    noticeTypeLabel.font = [UIFont systemFontOfSize:14.0];
    [noticeTypeLabel sizeToFit];
    noticeTypeLabel.left = leftCap;
    noticeTypeLabel.yCenter = infoBarYCenter - 10;
    [infoBarView addSubview:noticeTypeLabel];
    
    UILabel *locationInfoLabel = [UILabel new];
    locationInfoLabel.text = @"获取定位地址";
    locationInfoLabel.font = [UIFont systemFontOfSize:11.0];
    [locationInfoLabel sizeToFit];
    locationInfoLabel.left = leftCap;
    locationInfoLabel.yCenter = infoBarYCenter + 15;
    [infoBarView addSubview:locationInfoLabel];
    self.locationInfoLabel = locationInfoLabel;
    
    UIButton *callButton = [UIButton new];
    callButton.left = frame.size.width - leftCap - buttonWidth;
    callButton.width = callButton.height = buttonWidth;
    callButton.yCenter = infoBarYCenter;
//    button.backgroundColor = cBasicGreenColor;
    callButton.layer.cornerRadius = buttonWidth / 2;
    callButton.layer.masksToBounds = YES;
    [callButton setBackgroundImage:[UIImage imageNamed:@"main_location_callIcon"] forState:UIControlStateNormal];
    [callButton addTarget:self action:@selector(callButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    [infoBarView addSubview:callButton];
}

#pragma mark - Touch Event

- (void)addOverLine
{
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
//        //        pointAnnotation.title = @"方恒国际";
//        //        pointAnnotation.subtitle = @"阜通东大街6号";
//        [_mapView addAnnotation:pointAnnotation];
//    }
}

- (void)callButtonClick:(UIButton *)sender
{
//    NSLog(@"通话");
//    NSMutableString * str=[[NSMutableString alloc] initWithFormat:@"tel:%@",@"15934874308"];
//    //            NSLog(@"str======%@",str);
//    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:str]];
    
//    NSMutableString * str=[[NSMutableString alloc] initWithFormat:@"telprompt://%@",@"15934874308"];
//    //            NSLog(@"str======%@",str);
//    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:str]];
//    
    NSMutableString *numberStr = [[NSMutableString alloc] initWithFormat:@"tel:%@", [[[TYDDataCenter defaultCenter]currentKidInfo] phoneNumber]];
    NSLog(@"numberStr %@",numberStr);
    UIWebView * callWebview = [[UIWebView alloc] init];
    [callWebview loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:numberStr]]];
    [self.view addSubview:callWebview];
}

#pragma mark - BMKMapViewDelegate
//处理位置坐标更新
- (void)mapView:(MAMapView *)mapView didUpdateUserLocation:(MAUserLocation *)userLocation;
{
    NSLog(@"didUpdateUserLocation lat %f,long %f, speed %f horizontalAccuracy %f verticalAccuracy %f",userLocation.location.coordinate.latitude,userLocation.location.coordinate.longitude, userLocation.location.speed, userLocation.location.horizontalAccuracy, userLocation.location.verticalAccuracy);
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
            [annotationView addSubview:button];
        }
        annotationView.image = [UIImage imageNamed:@"main_location_point"];
        //设置中⼼心点偏移，使得标注底部中间点成为经纬度对应点
        annotationView.centerOffset = CGPointMake(0, -15);
        annotationView.canShowCallout= YES;       //设置气泡可以弹出，默认为NO
        annotationView.draggable = YES;        //设置标注可以拖动，默认为NO
        annotationView.selected = NO;
        return annotationView;
    }
    return nil;
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
        self.locationInfoLabel.text = [NSString stringWithFormat:@"位置:%@",location];
    }
}

@end
