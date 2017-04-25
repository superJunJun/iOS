//
//  TYDBindAuthorizeController.m
//  DroiKids
//
//  Created by caiyajie on 15/9/22.
//  Copyright (c) 2015年 TYDTech. All rights reserved.
//

#import "TYDBindAuthorizeController.h"
#import "AppDelegate.h"
#import "TYDDataCenter.h"
@interface TYDBindAuthorizeController ()<TYDRemoteNotificationEventDelegate,UIAlertViewDelegate>

@property (strong, nonatomic)  UIImageView *centerImageView;
@property (strong, nonatomic)  UIImageView *animationImageView;
@property (strong, nonatomic)  UILabel *bottomLabel;
@property (strong, nonatomic)  NSString *watchId;

@end

@implementation TYDBindAuthorizeController

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
    AppDelegate *delegate = [UIApplication sharedApplication].delegate;
    delegate.eventDelegate = self;
    
    [self.animationImageView startAnimating];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    AppDelegate *delegate = [UIApplication sharedApplication].delegate;
    delegate.eventDelegate = nil;
}

- (void)localDataInitialize
{
    
}

- (void)navigationBarItemsLoad
{
    self.title = @"待授权";
    
    self.backButtonVisible = NO;
}

- (void)subviewsLoad
{
    CGRect frame = self.view.bounds;
    frame.size.height = 100;
    UIView *baseView = [[UIView alloc] initWithFrame:frame];
    baseView.backgroundColor = [UIColor clearColor];
    [self.baseView addSubview:baseView];
    
    UILabel *titleLabel = [UILabel new];
    titleLabel.backgroundColor = [UIColor clearColor];
    titleLabel.text = @"需要经过管理员允许，才能与手表进行绑定";
    titleLabel.font = [UIFont fontWithName:@"Arial" size:12];
    titleLabel.textColor = [UIColor colorWithHex:0xaaaaaa];
    [titleLabel sizeToFit];
    titleLabel.top = 20;
    titleLabel.left = 17;
    [baseView addSubview:titleLabel];
    
    UIImageView *centerImageView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"BindAuthorize_Waiting"]];
    centerImageView.size = centerImageView.image.size;
    centerImageView.center = self.view.center;
    [baseView addSubview:centerImageView];
    
    UIImageView *animationImageview = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"BindAuthorize_Step1"]];
    animationImageview.size = animationImageview.image.size;
    animationImageview.animationImages = @[[UIImage imageNamed:@"BindAuthorize_Step1"], [UIImage imageNamed:@"BindAuthorize_Step2"], [UIImage imageNamed:@"BindAuthorize_Step3"], [UIImage imageNamed:@"BindAuthorize_Step4"]];
    animationImageview.animationDuration = 1;
    animationImageview.animationRepeatCount = 0;
    [baseView addSubview:animationImageview];
    animationImageview.bottom = centerImageView.top + animationImageview.size.height * 0.5;
    animationImageview.right = centerImageView.right + animationImageview.size.width *0.5;
    
    UILabel *bottomLabel = [UILabel new];
    bottomLabel.backgroundColor = [UIColor clearColor];
    bottomLabel.text = @"嫌太慢？直接连接手表管理员，可以加快审核速度喔！";
    bottomLabel.size = CGSizeMake(self.view.width, 30);
    bottomLabel.textColor = [UIColor colorWithHex:0xaaaaaa];
    bottomLabel.font = [UIFont fontWithName:@"Arial" size:12];
    bottomLabel.textAlignment = NSTextAlignmentCenter;
    bottomLabel.center = self.view.center;
    bottomLabel.bottom = self.view.height - 120;
    [baseView addSubview:bottomLabel];
    baseView.height = bottomLabel.bottom;
    self.baseViewBaseHeight = baseView.bottom;
    
    self.centerImageView = centerImageView;
    self.animationImageView = animationImageview;
    self.bottomLabel = bottomLabel;
}

#pragma mark - TYDRemoteNotificationEvent

- (void)applicationDidReceiveRemoteNotification:(BOOL)isAllow withWatchId:(NSString *)watchId
{
    self.watchId = watchId;
    [self.animationImageView stopAnimating];
    self.animationImageView.hidden = YES;
    if(isAllow)
    {
        self.centerImageView.image = [UIImage imageNamed:@"BindAuthorize_Success"];
        [self updateChildInfoList];
    }
    else
    {
        self.centerImageView.image = [UIImage imageNamed:@"BindAuthorize_Fail"];
        self.noticeText = @"管理员拒绝了你的请求，请绑定其他儿童或重新申请！";
        UINavigationController *loginNavigationController = [self.storyboard instantiateViewControllerWithIdentifier:@"loginNavigationController"];
        [self presentViewController:loginNavigationController animated:YES completion:nil];
    }
    
}

- (void)applicationDidFinishLaunching
{
    
}

#pragma mark - Suspendevent

- (void)updateChildInfoList
{
//    NSMutableDictionary *params = [NSMutableDictionary new];
//    [params setValue:self.watchId forKey:@"watchid"];
//    [self postURLRequestWithMessageCode:ServiceMsgCodeKidInfoRequest HUDLabelText:nil params:params completeBlock:^(id result) {
//         [self updateChildInfoListComplete:result];
//    }];
    NSMutableDictionary *params = [NSMutableDictionary new];
    [params setValue:[TYDUserInfo sharedUserInfo].openID forKey:@"openid"];
    [self postURLRequestWithMessageCode:ServiceMsgCodeKidListInfoDownload HUDLabelText:nil params:params completeBlock:^(id result) {
        [self updateChildInfoListComplete:result];
    }];
}

- (void)updateChildInfoListComplete:(id)result
{
//    NSNumber *resultStatus = [result objectForKey:@"result"];
//    if(resultStatus != nil && resultStatus.intValue == 0)
//    {
//        NSDictionary *dic = [result objectForKey:@"watchChild"];
//        TYDKidInfo *kidInfo = [TYDKidInfo new];
//        [kidInfo setAttributes:dic];
//        [[TYDDataCenter defaultCenter]saveKidInfoList:@[kidInfo]];
//        
//        [self progressHUDShowWithCompleteText:@"登录成功" isSucceed:YES additionalTarget:self action:@selector(loginActionSucceed) object:nil];
//    }
//    else
//    {
//        self.noticeText = @"获取儿童信息失败，重新登录即可。";
//        UINavigationController *loginNavigationController = [self.storyboard instantiateViewControllerWithIdentifier:@"loginNavigationController"];
//        [self presentViewController:loginNavigationController animated:YES completion:nil];
//    }
    [self progressHUDHideImmediately];
    NSLog(@"babyInfoDownloadComplete:%@", result);
    NSNumber *resultCode = result[@"result"];
    if(resultCode != nil
       && resultCode.intValue == 0)
    {
        NSArray *infoArray = result[@"childlist"];
        if(infoArray.count == 0)
        {
            //退出应用
        }
        else
        {
            NSMutableArray *childArray = [NSMutableArray new];
            for(NSDictionary *dic in infoArray)
            {
                TYDKidInfo *kidInfo = [TYDKidInfo new];
                [kidInfo setAttributes:dic];
                [childArray addObject:kidInfo];
            }
            [[TYDDataCenter defaultCenter]saveKidInfoList:childArray];
            [self progressHUDShowWithCompleteText:@"登录成功" isSucceed:YES additionalTarget:self action:@selector(loginActionSucceed) object:nil];
        }
    }
    else
    {
        self.noticeText = @"获取儿童信息失败，重新登录即可。";
        UINavigationController *loginNavigationController = [self.storyboard instantiateViewControllerWithIdentifier:@"loginNavigationController"];
        [self presentViewController:loginNavigationController animated:YES completion:nil];
    }
}

- (void)loginActionSucceed
{
    UINavigationController *mainNavigationController = [self.storyboard instantiateViewControllerWithIdentifier:@"mainNavigationController"];
    //    TYDMainViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:DrawerViewControllerIdentifier];
    [self presentViewController:mainNavigationController animated:YES completion:nil];
}
@end
