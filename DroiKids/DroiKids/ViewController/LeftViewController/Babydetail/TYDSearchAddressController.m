//
//  TYDSearchAddressController.m
//  DroiKids
//
//  Created by wangchao on 15/8/17.
//  Copyright (c) 2015年 superjunjun. All rights reserved.
//

#import "TYDSearchAddressController.h"
#import "TYDSearchAddressResultController.h"
#import <MAMapKit/MAMapKit.h>
#import <AMapSearchKit/AMapSearchAPI.h>
#import "TYDGeocodeAnnotation.h"
#import "TYDMapCommonUtility.h"
#import "BOCoordinateTransformation.h"
#import "POIAnnotation.h"

@interface TYDSearchAddressController () <MAMapViewDelegate, AMapSearchDelegate, UISearchBarDelegate, UISearchResultsUpdating, TYDSearchAddressResultSelectDelegate, UIAlertViewDelegate>

@property (strong, nonatomic) MAMapView *mapView;
@property (strong, nonatomic) AMapSearchAPI *mapSearch;
@property (strong, nonatomic) UISearchController *addressSearchController;
@property (strong, nonatomic) NSMutableArray *addressDataArray;
@property (strong, nonatomic) NSArray *searchTipsArray;
@property (strong, nonatomic) TYDGeocodeAnnotation *geocodeAnnotation;
@property (strong, nonatomic) POIAnnotation *POIAnnotation;

@property (strong, nonatomic) UILabel *addressLabel;
@property (strong, nonatomic) NSString *addressString;
@property (assign, nonatomic) CLLocationCoordinate2D addressCoordinate;
@property (assign, nonatomic) BOOL addressIsChange;

@end

@implementation TYDSearchAddressController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self localDataInitialize];
    [self navigationBarItemsLoad];
    [self subviewsLoad];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self updateData];
}

- (void)updateData
{
    MAPointAnnotation *pointAnnotation = [[MAPointAnnotation alloc] init];
    pointAnnotation.coordinate = self.addressCoordinate;
    [self.mapView addAnnotation:pointAnnotation];
}

- (void)localDataInitialize
{
    self.addressDataArray = [NSMutableArray array];
    self.addressIsChange = NO;
    
    self.addressString = self.addressArray[0];
    if(self.addressArray.count == 3)
    {
        NSString *latitude = self.addressArray[1];
        NSString *longitude = self.addressArray[2];
        self.addressCoordinate = CLLocationCoordinate2DMake(latitude.doubleValue, longitude.doubleValue);
    }
}

- (void)navigationBarItemsLoad
{
    self.title = @"选择地址";
}

- (void)subviewsLoad
{
    [self initMapView];
    [self searchViewLoad];
    [self saveBottomBarLoad];
}

- (void)initMapView
{
    CGRect frame = self.view.frame;
    frame.origin.y = 20;
    
    self.mapView = [[MAMapView alloc] initWithFrame:frame];
    self.mapView.delegate = self;
    self.mapView.showsCompass = NO;
    self.mapView.distanceFilter = 5.0;
    self.mapView.desiredAccuracy = kCLLocationAccuracyBest;
    [self.mapView setZoomLevel:16.1 animated:YES];
    
    if(self.addressArray.count == 3)
    {
        self.mapView.centerCoordinate = self.addressCoordinate;
    }
    else
    {
        self.mapView.showsUserLocation = YES;
    }
    
    [self.view addSubview:self.mapView];
    
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
    self.addressSearchController.searchBar.placeholder = @"搜索地址";
    self.addressSearchController.searchBar.delegate = self;
    self.addressSearchController.searchBar.translucent = YES;
    self.addressSearchController.searchBar.tintColor = [UIColor colorWithHex:0x6cbb52];
    [self.addressSearchController.searchBar sizeToFit];
    self.definesPresentationContext = YES;
    
    [self.view addSubview:self.addressSearchController.searchBar];
}

- (void)saveBottomBarLoad
{
    UIView *bottomBarView = [UIView new];
    bottomBarView.backgroundColor = [UIColor colorWithHex:0x0 andAlpha:0.5];
    bottomBarView.size = CGSizeMake(self.view.width, 60);
    bottomBarView.bottom = self.view.bottom - 64;
    [self.view addSubview:bottomBarView];
    
    UIImageView *annotationView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"babyDetail_annotation"]];
    annotationView.size = CGSizeMake(22, 30);
    annotationView.left = 17;
    annotationView.yCenter = bottomBarView.height / 2;
    
    [bottomBarView addSubview:annotationView];
    
    UILabel *addressLabel = [UILabel new];
    addressLabel.backgroundColor = [UIColor clearColor];
    addressLabel.textColor = [UIColor whiteColor];
    addressLabel.font = [UIFont systemFontOfSize:16];
    addressLabel.text = (self.addressString.length == 0) ? @"请搜索地址" : self.addressString;
    [addressLabel sizeToFit];
    addressLabel.width = (addressLabel.width < 200) ? addressLabel.width : 200;
    addressLabel.left = annotationView.right + 10;
    addressLabel.yCenter = bottomBarView.height / 2;
    
    [bottomBarView addSubview:addressLabel];
    self.addressLabel = addressLabel;
    
    UIButton *saveButton = [UIButton new];
    [saveButton setBackgroundImage:[UIImage imageNamed:@"babyDetail_address_save"] forState:UIControlStateNormal];
    [saveButton setBackgroundImage:[UIImage imageNamed:@"babyDetail_address_saveH"] forState:UIControlStateHighlighted];
    [saveButton setTitle:@"保存" forState:UIControlStateNormal];
    [saveButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    saveButton.size = CGSizeMake(45, 45);
    saveButton.right = bottomBarView.width - 17;
    saveButton.yCenter = bottomBarView.height / 2;
    [saveButton addTarget:self action:@selector(confirmButtonTap:) forControlEvents:UIControlEventTouchUpInside];
    
    [bottomBarView addSubview:saveButton];
}

- (void)addressLabelUpdateString:(NSString *)addressString
{
    self.addressLabel.text = addressString;
    [self.addressLabel sizeToFit];
    self.addressLabel.width = (self.addressLabel.width < 200) ? self.addressLabel.width : 200;
    
    self.addressString = addressString;
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
    NSString *searchTipAdCode = nil;
    NSString *cityName = nil;
    
    for(AMapTip *searchTip in self.searchTipsArray)
    {
        if([searchTip.name isEqualToString:key])
        {
            searchTipAdCode = searchTip.adcode;
            cityName = searchTip.district;
            
            break;
        }
    }
    
    [self clearAndSearchGeocodeWithKey:key adcode:searchTipAdCode cityName:cityName];
    
    self.addressSearchController.searchBar.placeholder = key;
    self.addressSearchController.active = NO;
}

#pragma mark - MAMapViewDelegate

- (void)mapView:(MAMapView *)mapView annotationView:(MAAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control
{
    if([view.annotation isKindOfClass:[TYDGeocodeAnnotation class]])
    {
        [self gotoDetailForGeocode:[(TYDGeocodeAnnotation *)view.annotation geocode]];
    }
}

//处理位置坐标更新
- (void)mapView:(MAMapView *)mapView didUpdateUserLocation:(MAUserLocation *)userLocation;
{
    self.mapView.centerCoordinate = userLocation.coordinate;
    self.mapView.showsUserLocation = NO;
}

- (MAAnnotationView *)mapView:(MAMapView *)mapView viewForAnnotation:(id<MAAnnotation>)annotation
{
    if([annotation isKindOfClass:[TYDGeocodeAnnotation class]])
    {
        static NSString *geoCellIdentifier = @"geoCellIdentifier";
        
        MAPinAnnotationView *poiAnnotationView = (MAPinAnnotationView*)[self.mapView dequeueReusableAnnotationViewWithIdentifier:geoCellIdentifier];
        if(poiAnnotationView == nil)
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
        AMapPlaceSearchRequest *poiRequest = [[AMapPlaceSearchRequest alloc] init];
        
        poiRequest.searchType = AMapSearchType_PlaceKeyword;
        poiRequest.keywords = request.address;
        poiRequest.city = request.city;
        poiRequest.requireExtension = YES;
        [self.mapSearch AMapPlaceSearch:poiRequest];
        
        return;
    }
    
    [response.geocodes enumerateObjectsUsingBlock:^(AMapGeocode *obj, NSUInteger idx, BOOL *stop) {
        self.geocodeAnnotation = [[TYDGeocodeAnnotation alloc] initWithGeocode:obj];
    }];
    
    [self.mapView setCenterCoordinate:self.geocodeAnnotation.coordinate animated:YES];
    [self.mapView addAnnotations:@[self.geocodeAnnotation]];
    
    self.addressCoordinate = self.geocodeAnnotation.coordinate;
}

- (void)onPlaceSearchDone:(AMapPlaceSearchRequest *)request response:(AMapPlaceSearchResponse *)response
{
    if (response.pois.count == 0)
    {
        return;
    }
    
    NSMutableArray *poiAnnotations = [NSMutableArray arrayWithCapacity:response.pois.count];
    
    [response.pois enumerateObjectsUsingBlock:^(AMapPOI *obj, NSUInteger idx, BOOL *stop) {
        
        [poiAnnotations addObject:[[POIAnnotation alloc] initWithPOI:obj]];
        
    }];
    
    /* 将结果以annotation的形式加载到地图上. */
    [self.mapView addAnnotations:poiAnnotations];
    
    /* 如果只有一个结果，设置其为中心点. */
    if (poiAnnotations.count == 1)
    {
        self.mapView.centerCoordinate = [poiAnnotations[0] coordinate];
    }
    /* 如果有多个结果, 设置地图使所有的annotation都可见. */
    else
    {
        [self.mapView showAnnotations:poiAnnotations animated:NO];
    }
    
    self.POIAnnotation = poiAnnotations[0];
    self.addressCoordinate = self.POIAnnotation.coordinate;
}

/* 输入提示回调. */
- (void)onInputTipsSearchDone:(AMapInputTipsSearchRequest *)request response:(AMapInputTipsSearchResponse *)response
{
    NSLog(@"response:%@",response);
    
    [self.addressDataArray setArray:response.tips];
    self.searchTipsArray = response.tips;
    
    TYDSearchAddressResultController *addressResultController = (TYDSearchAddressResultController *)self.addressSearchController.searchResultsController;
    addressResultController.addressDataArray = self.addressDataArray;
    addressResultController.searchTipsArray = response.tips;
    [addressResultController.tableView reloadData];
}

- (void)searchRequest:(id)request didFailWithError:(NSError *)error
{
    NSLog(@"addressSearchRequesterror:%@",error);
}

#pragma mark - TYDSearchAddressResultSelectDelegate

- (void)addressResultSelect:(NSString *)address searchTipAdCode:(NSString *)searchTipAdCode cityName:(NSString *)cityName
{
    NSLog(@"addressResultSelect");
    
    if(address.length == 0)
    {
        return;
    }
    
    [self clearAndSearchGeocodeWithKey:address adcode:searchTipAdCode cityName:cityName];
    
    self.addressSearchController.searchBar.placeholder = address;
    self.addressSearchController.active = NO;
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
    self.geocodeAnnotation = nil;
    [self.mapView removeAnnotations:self.mapView.annotations];
}

- (void)clearAndSearchGeocodeWithKey:(NSString *)key adcode:(NSString *)adcode cityName:(NSString *)cityName
{
    [self clearAnnotation];
    [self addressLabelUpdateString:key];
    [self searchGeocodeWithKey:key adcode:adcode cityName:cityName];
}

/* 地理编码 搜索. */
- (void)searchGeocodeWithKey:(NSString *)key adcode:(NSString *)adcode cityName:(NSString *)cityName
{
    if(key.length == 0)
    {
        return;
    }
    
    AMapGeocodeSearchRequest *geo = [[AMapGeocodeSearchRequest alloc] init];
    geo.address = key;
    
    NSMutableArray *city = [NSMutableArray arrayWithCapacity:0];
    
    if(adcode.length > 0)
    {
        [city addObject:adcode];
    }
    if(cityName.length > 0)
    {
        [city addObject:cityName];
    }
    
    geo.city = city;
    
    [self.mapSearch AMapGeocodeSearch:geo];
    
    self.addressIsChange = YES;
}

#pragma mark - TouchEvent

- (void)confirmButtonTap:(UIButton *)button
{
    NSLog(@"confirmButtonTap");
    
    if(self.addressIsChange == NO)
    {
        [super popBackEventWillHappen];
    }
    else if([self.addressString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]].length == 0)
    {
        self.noticeText = @"保存地址不能为空！";
        return;
    }
    else if(!self.geocodeAnnotation && !self.POIAnnotation)
    {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"保存地址" message:@"地址在地图上未搜寻到定位点，是否继续保存？" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"保存", nil];
        
        [alertView show];
    }
    else if([self.delegate respondsToSelector:@selector(searchAddressComplete:)])
    {
        NSString *addressString = [NSString stringWithFormat:@"%@&%f&%f", self.addressString, self.addressCoordinate.latitude, self.addressCoordinate.longitude];
        [self.delegate searchAddressComplete:addressString];
        
        [super popBackEventWillHappen];
    }
}

#pragma mark UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if([alertView.title isEqualToString:@"保存地址"])
    {
        NSString *buttonTitle = [alertView buttonTitleAtIndex:buttonIndex];
        
        if([buttonTitle isEqualToString:@"取消"])
        {
            [super popBackEventWillHappen];
        }
        else if([buttonTitle isEqualToString:@"保存"])
        {
            if([self.delegate respondsToSelector:@selector(searchAddressComplete:)])
            {
                [self.delegate searchAddressComplete:self.addressString];
                
                [super popBackEventWillHappen];
            }
        }
    }
}

@end
