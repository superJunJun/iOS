//
//  TYDCollectingPlaceViewController.m
//  DroiKids
//
//  Created by superjunjun on 15/8/18.
//  Copyright (c) 2015年 superjunjun. All rights reserved.
//

#import "TYDCollectingListViewController.h"
#import "TYDAddCollectingPointViewController.h"
#import "SBJson.h"
#import "TYDKidTrackInfo.h"
#import "TYDEnshrineLocationInfo.h"
#import "TYDCollectingDetailViewController.h"
#import <AMapSearchKit/AMapSearchAPI.h>
#import <CoreLocation/CoreLocation.h>
#import "TYDKidInfo.h"
#import "TYDDataCenter.h"

@interface TYDCollectingListViewController ()<AMapSearchDelegate>

@property (nonatomic, strong) NSMutableArray        *userCollectionPointArray;
@property (nonatomic, strong) NSMutableArray        *userCollectionPointNameArray;
@property (strong, nonatomic) AMapSearchAPI         *search;
@property (assign, nonatomic) NSInteger             currentKidId;
@property (assign, nonatomic) NSInteger             currentIndex;
@end

@implementation TYDCollectingListViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = cBasicBackgroundColor;
    [self localDataInitialize];
    [self navigationBarItemsLoad];
    [self subviewsLoad];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.userCollectionPointArray removeAllObjects];
    [self.userCollectionPointNameArray removeAllObjects];
    [self getCollectionLocationInfo];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self.tableView reloadData];
}
- (void)localDataInitialize
{
    TYDKidInfo *kidInfo =  [[TYDDataCenter defaultCenter]currentKidInfo];
    self.currentKidId = [kidInfo.kidID integerValue];
    //初始化检索对象
    _search = [[AMapSearchAPI alloc] initWithSearchKey:sGaodeMapSDKAppKey Delegate:self];
//    NSArray *array= @[@"爸爸家", @"妈妈家", @"奶奶家", @"爷爷家", @"外公家", @"外婆家"];
//    NSMutableArray *locationNameArray = [NSMutableArray new];
//    for(int i = 0; i < array.count; i++)
//    {
//        [locationNameArray addObject:@"未获取到定位信息"];
//    }
    self.userCollectionPointArray = [NSMutableArray new];
//    self.userCollectionPointNameArray = [NSMutableArray new];
//
//    NSArray *longitudeArray = @[@(121.419332), @(121.417358) ,@(121.404634) ,@(121.412659) ,@(121.404505) ,@(121.419182)];
//    NSArray *latitudeArray = @[@(31.150284), @(31.152846) ,@(31.1639) ,@(31.165663) ,@(31.161293) ,@(31.163973)];
//    for(int i = 0; i < 6; i++)
//    {
//        TYDEnshrineLocationInfo *kidcollectionInfo = [TYDEnshrineLocationInfo new];
////        kidcollectionInfo.locationID = array[i];
////        kidcollectionInfo.locationMemo = detailDic[@"openid"];
//        kidcollectionInfo.locationName = array[i];
////        kidcollectionInfo.infoCreateTime = detailDic[@"time"];
//        kidcollectionInfo.locationLatitude = latitudeArray[i];
//        kidcollectionInfo.locationLongitude = longitudeArray[i];
//        [self.userCollectionPointArray addObject:kidcollectionInfo];
//        CLLocationCoordinate2D coord = CLLocationCoordinate2DMake(kidcollectionInfo.locationLatitude.doubleValue, kidcollectionInfo.locationLongitude.doubleValue);
//        [self clickReverseGeoCode:coord withIndex:[NSString stringWithFormat:@"%d",i]];
//    }
}

- (void)navigationBarItemsLoad
{
    self.titleText = @"收藏地址";//NSLocalizedString(@"my_ranking", nil);//@"排名";
    self.editButtonItem.tintColor = [UIColor whiteColor];
    self.editButtonItem.title = @"编辑";
    self.navigationItem.rightBarButtonItem =self.editButtonItem;
}

- (void)subviewsLoad
{
    CGRect frame = self.view.bounds;
    UITableView *tableView = [[UITableView alloc] initWithFrame:frame style:UITableViewStyleGrouped];
    tableView.delegate = self;
    tableView.dataSource = self;
    tableView.backgroundColor = cBasicBackgroundColor;
    //tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    tableView.showsVerticalScrollIndicator = NO;
    tableView.bounces = YES;
    tableView.rowHeight = 66;
    [self.view addSubview:tableView];
    self.tableView = tableView;
}

#pragma mark -Touch event

- (void)addCollectionPoint
{
    NSLog(@"addCollectionPoint");
    TYDAddCollectingPointViewController *vc = [TYDAddCollectingPointViewController new];
    vc.userCollectionPointArray = self.userCollectionPointArray;
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - UITableViewDelegate & UITableViewDataSource

- (void)setEditing:(BOOL)editing animated:(BOOL)animated
{
    [super setEditing:editing animated:animated];
    [self.tableView setEditing:editing animated:animated];
    if(self.editing)
    {
        self.editButtonItem.title = @"完成";
    }
    else
    {
        self.editButtonItem.title = @"编辑";
    }
}

- (NSInteger )numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (CGFloat )tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 105;
}

- (CGFloat )tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 1;
}

- (CGFloat )tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 66;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    CGRect frame = self.view.frame;
    NSInteger baseViewHeight = 105;
    NSInteger contentViewHeight = 65;
    NSInteger topCap = 20;
    CGFloat xCenter = frame.size.width / 2 - 60;
    CGFloat yCenter = contentViewHeight / 2;
    
    UIView *baseView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, baseViewHeight)];
    baseView.backgroundColor = cBasicBackgroundColor;
    
    UIButton *baseButtonView = [[UIButton alloc]initWithFrame:CGRectMake(0, topCap, frame.size.width, contentViewHeight)];
    [baseButtonView addTarget:self action:@selector(addCollectionPoint) forControlEvents:UIControlEventTouchUpInside];
    baseButtonView.backgroundColor = [UIColor whiteColor];
    [baseView addSubview:baseButtonView];
  
    UIImageView *addLocationImageView = [UIImageView new];
    addLocationImageView.image = [UIImage imageNamed:@"main_collection_add"];
    addLocationImageView.size = CGSizeMake(30, 30);
    addLocationImageView.xCenter = xCenter;
    addLocationImageView.yCenter = yCenter;
    [baseButtonView addSubview:addLocationImageView];
    
    UILabel *addLocationLabel = [UILabel new];
    addLocationLabel.backgroundColor = [UIColor clearColor];
    addLocationLabel.textColor = [UIColor blackColor];
    addLocationLabel.font = [BOAssistor defaultTextStringFontWithSize:14];
    addLocationLabel.text = @"添加收藏地点";
    [addLocationLabel sizeToFit];
    addLocationLabel.left = addLocationImageView.right + 15;
    addLocationLabel.yCenter = yCenter;
    [baseButtonView addSubview:addLocationLabel];
  
    return baseView;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    return [UIView new];
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewCellEditingStyleDelete;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.userCollectionPointArray count];
}

// 插入删除
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete)
    {
        self.currentIndex = indexPath.row;
        TYDEnshrineLocationInfo *enshrineLocationInfo = self.userCollectionPointArray[indexPath.row];
        [self removeCollectionPointToServerWithLocationID:enshrineLocationInfo.locationID.integerValue];
    }
    else if (editingStyle == UITableViewCellEditingStyleInsert)
    {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }
}

// 移动
//- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath
//{
//    NSString* fromObj = [self.userCollectionPointArray objectAtIndex:sourceIndexPath.row];
//    [self.userCollectionPointArray insertObject:fromObj atIndex:destinationIndexPath.row];
//    [self.userCollectionPointArray removeObjectAtIndex:sourceIndexPath.row];
//}
//
//- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    return YES;
//}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell  = [tableView  dequeueReusableCellWithIdentifier:@"cell"];
    if(cell == nil)
    {
        cell = [[UITableViewCell alloc]initWithStyle:3 reuseIdentifier:@"cell"];
    }
    TYDEnshrineLocationInfo *kidcollectionInfo = self.userCollectionPointArray[indexPath.row];
    cell.textLabel.font = [UIFont systemFontOfSize:16.0];
    cell.textLabel.textColor = [UIColor blackColor];
    cell.detailTextLabel.textColor = [UIColor lightGrayColor];
    cell.detailTextLabel.font = [UIFont systemFontOfSize:11.0];
    cell.textLabel.text = kidcollectionInfo.locationMemo;
    cell.detailTextLabel.text = kidcollectionInfo.locationName;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    TYDCollectingDetailViewController *vc = [TYDCollectingDetailViewController new];
    vc.kidcollectionInfo = self.userCollectionPointArray[indexPath.row];
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - MAGeoCodeSearchDelegate

//获取反编码状态
-(void)clickReverseGeoCode:(CLLocationCoordinate2D )coordinate withIndex:(NSString *)index
{
    //构造AMapReGeocodeSearchRequest对象，location为必选项，radius为可选项
    AMapReGeocodeSearchRequest *regeoRequest = [[AMapReGeocodeSearchRequest alloc] init];
    regeoRequest.searchType = AMapSearchType_ReGeocode;
    regeoRequest.location = [AMapGeoPoint locationWithLatitude:coordinate.latitude longitude:coordinate.longitude];
    regeoRequest.radius = 10000;
    regeoRequest.requireExtension = YES;
    regeoRequest.poiIdFilter = index;
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
        NSInteger index = [request.poiIdFilter integerValue];
        TYDEnshrineLocationInfo *kidcollectionInfo = self.userCollectionPointArray[index];
        kidcollectionInfo.locationName = [NSString stringWithFormat:@"%@%@%@号", addressComponent.district, addressComponent.streetNumber.street, addressComponent.streetNumber.number];
    }
}

#pragma mark - Connect To Server

- (void)getCollectionLocationInfo
{
    NSTimeInterval endTime = (long)[BOTimeStampAssistor getCurrentTime];
    NSString *openId = [[TYDUserInfo sharedUserInfo] openID];
    NSDictionary *params = @{@"childid"  :@(self.currentKidId),
                             @"openid"   :openId,
                             @"stime"    :@((long)NSTimeIntervalSince1970),
                             @"etime"    :@(endTime)
                             };
    NSLog(@" %@",[BOTimeStampAssistor getDateStringWithTimeStamp:endTime]);
    NSLog(@" %@",[BOTimeStampAssistor getDateStringWithTimeStamp:(long)NSTimeIntervalSince1970]);
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
    }
    else
    {
        self.noticeText = @"获取收藏地点信息失败";
    }
//    [self getCollectionLocationName];
    [self progressHUDHideImmediately];
}

- (void)getCollectionLocationName
{
    for(TYDEnshrineLocationInfo *kidcollectionInfo in self.userCollectionPointArray)
    {
        CLLocationCoordinate2D coord = CLLocationCoordinate2DMake(kidcollectionInfo.locationLatitude.doubleValue, kidcollectionInfo.locationLongitude.doubleValue);
        NSUInteger index = [self.userCollectionPointArray indexOfObject:kidcollectionInfo];
        [self clickReverseGeoCode:coord withIndex:[NSString stringWithFormat:@"%lu",(unsigned long)index]];
    }
}

- (void)removeCollectionPointToServerWithLocationID:(NSInteger )locationID
{
    NSDictionary *params = @{@"id" :@(locationID)};
    
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
        [self progressHUDShowWithCompleteText:@"取消收藏成功" isSucceed:YES];
        [self.userCollectionPointArray removeObjectAtIndex:self.currentIndex];
        [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:self.currentIndex inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
    }
    else
    {
        [self progressHUDShowWithCompleteText:@"取消收藏失败" isSucceed:NO];
    }
}

@end

