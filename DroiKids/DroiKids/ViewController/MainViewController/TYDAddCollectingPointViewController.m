//
//  TYDAddCollectingPointViewController.m
//  DroiKids
//
//  Created by superjunjun on 15/9/2.
//  Copyright (c) 2015年 TYDTech. All rights reserved.
//

#import "TYDAddCollectingPointViewController.h"
#import "TYDCollectingListViewController.h"
#import "TYDSearchAddressResultController.h"
#import <MAMapKit/MAMapKit.h>
#import <AMapSearchKit/AMapSearchAPI.h>
#import "TYDGeocodeAnnotation.h"
#import "TYDMapCommonUtility.h"
#import "TYDKidInfo.h"
#import "TYDDataCenter.h"
@interface TYDAddCollectingPointViewController ()<MAMapViewDelegate, AMapSearchDelegate, UISearchBarDelegate,UISearchResultsUpdating ,TYDSearchAddressResultSelectDelegate>

@property (strong, nonatomic) MAMapView             *mapView;
@property (strong, nonatomic) AMapSearchAPI         *mapSearch;
@property (strong, nonatomic) UISearchController    *addressSearchController;
@property (strong, nonatomic) NSMutableArray        *addressDataArray;
@property (strong, nonatomic) UILabel               *locationInfoLabel;
@property (strong, nonatomic) UILabel               *markInfoLabel;
@property (strong, nonatomic) UIButton              *collectionButton;
@property (assign, nonatomic) NSInteger             currentKidId;
@property (strong, nonatomic) NSString              *currentMark;
@property (assign, nonatomic) NSInteger             currentEnshrineLocationId;

@property (assign, nonatomic) CLLocationCoordinate2D     currentCoord;

@end

@implementation TYDAddCollectingPointViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self localDataInitialize];
    [self navigationBarItemsLoad];
    [self subviewsLoad];
}

- (void)localDataInitialize
{
    self.addressDataArray = [NSMutableArray array];
    TYDKidInfo *kidInfo =  [[TYDDataCenter defaultCenter]currentKidInfo];
    self.currentKidId = [kidInfo.kidID integerValue];
}

- (void)navigationBarItemsLoad
{
    self.title = @"选择地址";
}

- (void)subviewsLoad
{
    [self initMapView];
    [self searchViewLoad];
    [self locationInfoBarLoad];
}

- (void)initMapView
{
    CGRect frame = self.view.frame;
    frame.origin.y = 44;
    MAMapView *mapView = [[MAMapView alloc] initWithFrame:frame];
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
    mapView.showsCompass = NO;
    mapView.showsScale = NO;
    mapView.delegate = self;
    mapView.pausesLocationUpdatesAutomatically = NO;
    mapView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    [self.view addSubview:mapView];
    self.mapView = mapView;
    [self initMapSearch];
}

- (void)initMapSearch
{
    self.mapSearch = [[AMapSearchAPI alloc] initWithSearchKey:[MAMapServices sharedServices].apiKey Delegate:self];
}

- (void)searchViewLoad
{
    TYDSearchAddressResultController *resultController = [TYDSearchAddressResultController new];
    resultController.delegate = self;
    self.addressSearchController = [[UISearchController alloc] initWithSearchResultsController:resultController];
    self.addressSearchController.searchResultsUpdater = self;
//    self.addressSearchController.searchBar.placeholder = self.addressString;
    self.addressSearchController.searchBar.delegate = self;
    self.addressSearchController.searchBar.barStyle = UIBarStyleDefault;
    self.addressSearchController.searchBar.translucent = YES;
    self.addressSearchController.searchBar.tintColor = [UIColor colorWithHex:0x6cbb52];
    [self.addressSearchController.searchBar sizeToFit];
    self.definesPresentationContext = YES;
    
    [self.view addSubview:self.addressSearchController.searchBar];
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
    
    UILabel *locationInfoLabel = [UILabel new];
    locationInfoLabel.text = @"";
    locationInfoLabel.font = [UIFont systemFontOfSize:14.0];
    [locationInfoLabel sizeToFit];
    locationInfoLabel.left = locationImageView.right +leftCap;
    locationInfoLabel.yCenter = infoBarYCenter - 10;
    [infoBarView addSubview:locationInfoLabel];
    self.locationInfoLabel = locationInfoLabel;
    
    UILabel *markInfoLabel = [UILabel new];
    markInfoLabel.text = @"";
    markInfoLabel.font = [UIFont systemFontOfSize:11.0];
    [markInfoLabel sizeToFit];
    markInfoLabel.left = locationImageView.right +leftCap;
    markInfoLabel.yCenter = infoBarYCenter + 5;
    [infoBarView addSubview:markInfoLabel];
    self.markInfoLabel = markInfoLabel;
    
    UIButton *collectionButton = [UIButton new];
    collectionButton.left = frame.size.width - leftCap - buttonWidth;
    collectionButton.width = collectionButton.height = buttonWidth;
    collectionButton.yCenter = infoBarYCenter;
    [collectionButton setBackgroundImage:[UIImage imageNamed:@"main_location_uncollection"] forState:UIControlStateNormal];
    [collectionButton setBackgroundImage:[UIImage imageNamed:@"main_location_collection"] forState:UIControlStateSelected];
    [collectionButton addTarget:self action:@selector(collectionButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    [infoBarView addSubview:collectionButton];
    self.collectionButton = collectionButton;
}

#pragma mark - UISearchResultsUpdating

- (void)updateSearchResultsForSearchController:(UISearchController *)searchController
{
    NSLog(@"updateSearchResultsForSearchController");
}

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar
{
    NSLog(@"searchBarTextDidBeginEditing");
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    NSLog(@"searchBarTextDidChange");
    [self searchAddressWithKey:searchText];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    NSString *key = searchBar.text;
    
    [self clearAndSearchGeocodeWithKey:key adcode:nil cityName:nil];
    
    self.addressSearchController.searchBar.placeholder = key;
    self.addressSearchController.active = NO;
}

#pragma mark - MAMapViewDelegate

//处理位置坐标更新
- (void)mapView:(MAMapView *)mapView didUpdateUserLocation:(MAUserLocation *)userLocation;
{
    NSLog(@"didUpdateUserLocation lat %f,long %f, speed %f horizontalAccuracy %f verticalAccuracy %f",userLocation.location.coordinate.latitude,userLocation.location.coordinate.longitude, userLocation.location.speed, userLocation.location.horizontalAccuracy, userLocation.location.verticalAccuracy);
    if (![self collectionPointExistWithCoord:userLocation.location.coordinate])
    {
        [self clickReverseGeoCode:self.currentCoord];
    }
    self.mapView.centerCoordinate = userLocation.location.coordinate;
    self.mapView.showsUserLocation = NO;
}

- (void)mapView:(MAMapView *)mapView annotationView:(MAAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control
{
    if ([view.annotation isKindOfClass:[TYDGeocodeAnnotation class]])
    {
        [self gotoDetailForGeocode:[(TYDGeocodeAnnotation*)view.annotation geocode]];
    }
}

- (MAAnnotationView *)mapView:(MAMapView *)mapView viewForAnnotation:(id<MAAnnotation>)annotation
{
    if ([annotation isKindOfClass:[TYDGeocodeAnnotation class]])
    {
        static NSString *geoCellIdentifier = @"geoCellIdentifier";
        
        MAPinAnnotationView *poiAnnotationView = (MAPinAnnotationView*)[self.mapView dequeueReusableAnnotationViewWithIdentifier:geoCellIdentifier];
        if (poiAnnotationView == nil)
        {
            poiAnnotationView = [[MAPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:geoCellIdentifier];
        }
        
        poiAnnotationView.canShowCallout = YES;
        poiAnnotationView.rightCalloutAccessoryView = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
        
        return poiAnnotationView;
    }
    
    return nil;
}

#pragma mark - AMapSearchDelegate

/* 地理编码回调.*/
- (void)onGeocodeSearchDone:(AMapGeocodeSearchRequest *)request response:(AMapGeocodeSearchResponse *)response
{
    if(response.geocodes.count == 0)
    {
        return;
    }
    
    NSMutableArray *annotations = [NSMutableArray array];
    
    [response.geocodes enumerateObjectsUsingBlock:^(AMapGeocode *obj, NSUInteger idx, BOOL *stop) {
        TYDGeocodeAnnotation *geocodeAnnotation = [[TYDGeocodeAnnotation alloc] initWithGeocode:obj];
        
        [annotations addObject:geocodeAnnotation];
    }];
    
    if(annotations.count == 1)
    {
        [self.mapView setCenterCoordinate:[annotations[0] coordinate] animated:YES];
    }
    else
    {
        [self.mapView setVisibleMapRect:[TYDMapCommonUtility minMapRectForAnnotations:annotations] animated:YES];
    }
    CLLocationCoordinate2D coord = [annotations.firstObject coordinate];
    [self.mapView addAnnotation:annotations.firstObject];
//    [self collectionPointExistWithCoord:coord];
    if (![self collectionPointExistWithCoord:coord])
    {
        [self clickReverseGeoCode:self.currentCoord];
    }
}

/* 输入提示回调. */
- (void)onInputTipsSearchDone:(AMapInputTipsSearchRequest *)request response:(AMapInputTipsSearchResponse *)response
{
    NSLog(@"response:%@",response);
    
    [self.addressDataArray setArray:response.tips];
    
    TYDSearchAddressResultController *addressResultController = (TYDSearchAddressResultController *)self.addressSearchController.searchResultsController;
    addressResultController.addressDataArray = [NSArray arrayWithArray:self.addressDataArray];
    addressResultController.searchTipsArray = response.tips;
    [addressResultController.tableView reloadData];
}

- (void)searchRequest:(id)request didFailWithError:(NSError *)error
{
    NSLog(@"addressSearchRequesterror:%@",error);
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
    [_mapSearch AMapReGoecodeSearch: regeoRequest];
}

//实现逆地理编码的回调函数
- (void)onReGeocodeSearchDone:(AMapReGeocodeSearchRequest *)request response:(AMapReGeocodeSearchResponse *)response
{
    if(response.regeocode != nil)
    {
        //获取起始位置
        AMapAddressComponent *addressComponent = response.regeocode.addressComponent;
        //台湾
        NSString *locationString;
        if(addressComponent.district.length > 0)
        {
            locationString = [NSString stringWithFormat:@"%@%@%@", addressComponent.district, addressComponent.streetNumber.street, addressComponent.streetNumber.number];
        }
        else
        {
            locationString = addressComponent.province;
        }
        [self changeUserLocationInfo:locationString];
    }
}

- (void)changeUserLocationInfo:(NSString *)locationString
{
    //修改地址
    self.locationInfoLabel.text = locationString;
    [self.locationInfoLabel sizeToFit];
    self.markInfoLabel.text = @"";
    self.collectionButton.selected = NO;
}

#pragma mark - TYDSearchAddressResultSelectDelegate

- (void)addressResultSelect:(NSString *)address searchTipAdCode:(NSString *)searchTipAdCode cityName:(NSString *)cityName
{
    NSLog(@"addressResultSelect");
    
    if(address.length == 0)
    {
        return;
    }
    NSLog(@"%@",searchTipAdCode);
    [self clearAndSearchGeocodeWithKey:address adcode:searchTipAdCode cityName:cityName];
    
    self.addressSearchController.searchBar.placeholder = address;
    self.addressSearchController.active = NO;
}
#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(buttonIndex != alertView.cancelButtonIndex)
    {
        UITextField *textField=[alertView textFieldAtIndex:0];
        self.currentMark = textField.text;
        [self saveCollectionPointToServer];
    }
}

#pragma mark - Utility

- (void)searchAddressWithKey:(NSString *)key
{
    if(key.length == 0)
    {
        return;
    }
    
    AMapInputTipsSearchRequest *tips = [[AMapInputTipsSearchRequest alloc] init];
    tips.keywords = key;
    [self.mapSearch AMapInputTipsSearch:tips];
}

- (void)gotoDetailForGeocode:(AMapGeocode *)geocode
{
    NSLog(@"gotoDetailForGeocode");
}

- (void)clearAnnotation
{
    [self.mapView removeAnnotations:self.mapView.annotations];
}

- (void)clearAndSearchGeocodeWithKey:(NSString *)key adcode:(NSString *)adcode cityName:(NSString *)cityName
{
    [self clearAnnotation];
    
    [self searchGeocodeWithKey:key adcode:adcode cityName:cityName];
}

/* 地理编码 搜索. */
- (void)searchGeocodeWithKey:(NSString *)key adcode:(NSString *)adcode cityName:(NSString *)cityName
{
    if (key.length == 0)
    {
        return;
    }
    
    AMapGeocodeSearchRequest *geo = [[AMapGeocodeSearchRequest alloc] init];
    geo.address = key;
    
    NSMutableArray *cityArray = nil;
    if (adcode.length > 0)
    {
        [cityArray addObject:adcode];
    }
    
    if(cityName.length > 0)
    {
        [cityArray addObject:cityName];
    }
    geo.city = cityArray;
    
    [self.mapSearch AMapGeocodeSearch:geo];
}

#pragma mark - TouchEvent

- (void)collectionButtonClick:(UIButton *)sender
{
    if(self.currentCoord.latitude && self.currentCoord.longitude)
    {
        if(sender.selected == NO)
        {
            NSString *locationString = [NSString stringWithFormat:@"地址:%@",self.locationInfoLabel.text];
            UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"添加备注" message:locationString delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"好的", nil];
            alertView.alertViewStyle = UIAlertViewStylePlainTextInput;
            
//            UITextField *textField = [alertView textFieldAtIndex:0];
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
        self.noticeText = @"未选择收藏点";
    }
}

- (BOOL )collectionPointExistWithCoord:(CLLocationCoordinate2D )coord
{
    self.currentCoord = coord;
    //修改备注信息
    if(self.userCollectionPointArray.count > 0)
    {
        for(TYDEnshrineLocationInfo *kidcollectionInfo in self.userCollectionPointArray)
        {
            float latitude = coord.latitude;
            float longitude = coord.longitude;

            if(kidcollectionInfo.locationLatitude.floatValue  == latitude
               && kidcollectionInfo.locationLongitude.floatValue  == longitude)
            {
                self.markInfoLabel.text = kidcollectionInfo.locationName;
                self.locationInfoLabel.text = kidcollectionInfo.locationMemo;
                [self.markInfoLabel sizeToFit];
                [self.locationInfoLabel sizeToFit];
                self.collectionButton.selected = YES;
                self.currentEnshrineLocationId = kidcollectionInfo.locationID.integerValue;
                return YES;
            }
        }
    }
    return NO;
}

#pragma mark - Connect To Server

- (void)saveCollectionPointToServer
{
    NSString *address = self.locationInfoLabel.text;
    NSString *description = self.currentMark;
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
        [self progressHUDShowWithCompleteText:@"收藏成功" isSucceed:YES additionalTarget:self.navigationController action:@selector(popViewControllerAnimated:) object:@YES];
        self.markInfoLabel.text = self.currentMark;
        [self.markInfoLabel sizeToFit];
        self.collectionButton.selected = YES;

    }
    else
    {
        [self progressHUDShowWithCompleteText:@"收藏失败" isSucceed:YES additionalTarget:self.navigationController action:@selector(popViewControllerAnimated:) object:@YES];
//        [self progressHUDShowWithCompleteText:@"收藏失败" isSucceed:NO];
    }
}

- (void)removeCollectionPointToServer
{
    NSDictionary *params = @{@"id" :@(self.currentEnshrineLocationId)};
    
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
    NSString *text;
    if(resultCode != nil
       && resultCode.intValue == 0)
    {
        text = @"取消收藏成功";
//        [self progressHUDShowWithCompleteText:@"取消收藏成功" isSucceed:YES];
    }
    else
    {
        text = @"取消收藏失败";
//        [self progressHUDShowWithCompleteText:@"取消收藏失败" isSucceed:NO];
    }
    [self progressHUDShowWithCompleteText:text isSucceed:YES additionalTarget:self.navigationController action:@selector(popViewControllerAnimated:) object:@YES];
}


@end

