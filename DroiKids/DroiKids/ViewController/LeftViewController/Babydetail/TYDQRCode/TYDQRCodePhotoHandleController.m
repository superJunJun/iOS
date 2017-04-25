//
//  TYDQRCodePhotoHandleController.m
//  DroiKids
//
//  Created by wangchao on 15/9/24.
//  Copyright © 2015年 TYDTech. All rights reserved.
//

#import "TYDQRCodePhotoHandleController.h"
#import "ZBarReaderController.h"
#import "BOOnceTimer.h"
#import "MBProgressHUD.h"
#import "TYDDataCenter.h"
#import "TYDBindAuthorizeController.h"
#import "TYDKidContactInfo.h"

#define sScanTimeOut                10

@interface TYDQRCodePhotoHandleController () <ZBarReaderDelegate, UIAlertViewDelegate>

@property (assign, nonatomic) BOOL scanTimeOut;
@property (strong, nonatomic) NSString *qrText;

@end

@implementation TYDQRCodePhotoHandleController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self localDataInitialize];
    [self navigationBarItemsLoad];
    [self subviewLoad];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [self scanPhotoQrCode];
}

- (void)localDataInitialize
{
}

- (void)navigationBarItemsLoad
{
    self.title = @"二维码照片";
}

- (void)subviewLoad
{
    UIImageView *imageView = [UIImageView new];
    imageView.image = self.QrCodeImage;
    imageView.size = CGSizeMake(self.baseView.width * 2 / 3, self.baseView.width * 2 / 3);
    imageView.center = CGPointMake(self.baseView.width / 2, ([UIScreen mainScreen].bounds.size.height - 64) / 2);
    
    [self.baseView addSubview:imageView];
    self.baseViewBaseHeight = imageView.bottom;
}

- (void)scanPhotoQrCode
{
    ZBarReaderController *read = [ZBarReaderController new];
    read.readerDelegate = self;

    CGImageRef cgImageRef = self.QrCodeImage.CGImage;

    ZBarSymbol *symbol = nil;

    [self progressHUDShowWithText:nil];
    
    for(symbol in [read scanImage:cgImageRef])
    {
        break;
    }
    
    [self progressHUDHideImmediately];

    self.qrText  = symbol.data;
    
    if ([BOAssistor numberStringValid:self.qrText]
        && [BOAssistor textLength:self.qrText] == 8
        && self.qrText)
    {
        NSString *message = [NSString stringWithFormat:@"是否绑定：%@", self.qrText];
        
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"扫描照片" message:message delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
        
        [alertView show];
    }
    else
    {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"检测失败" message:@"扫描二维码照片失败，请重新选择照片再试" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        
        [alertView show];
    }
}

#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if([alertView.title isEqualToString:@"扫描照片"])
    {
        NSString *buttonTitle = [alertView buttonTitleAtIndex:buttonIndex];
        
        if(buttonIndex == alertView.cancelButtonIndex)
        {
            [super popBackEventWillHappen];
        }
        if([buttonTitle isEqualToString:@"确定"])
        {
            [self bindingChild];
        }
    }
    else if([alertView.title isEqualToString:@"检测失败"])
    {
        [super popBackEventWillHappen];
    }
}

#pragma mark - ConnectServer

- (void)bindingChild
{
    NSMutableDictionary *params = [NSMutableDictionary new];
    [params setValue:[TYDUserInfo sharedUserInfo].openID forKey:sPostUrlRequestUserOpenIDKey];
    [params setValue:@"其他" forKey:@"relationship"];
    [params setValue:self.qrText forKey:@"watchid"];
    [params setValue:@(TYDKidContactOther) forKey:@"imgid"];
    
    [self postURLRequestWithMessageCode:ServiceMsgCodeBindWatchNormal
                           HUDLabelText:nil
                                 params:params
                          completeBlock:^(id result) {
                              [self bindWatchNormalComplete:result];
                          }];

}

- (void)bindWatchNormalComplete:(id)result
{
    NSLog(@"bindWatchNormalComplete:%@", result);
    
    NSNumber *value = result[@"result"];
    NSDictionary *childInfo = result[@"watchChild"];
    
    if(value.intValue == 0)
    {
        self.noticeText = @"绑定成功";
        
        [self bindingSucceedWithChildInfo:childInfo];
    }
    else if(value.intValue == 4)
    {
        if([TYDDataCenter defaultCenter].currentKidInfo)
        {
            [self.navigationController popToRootViewControllerAnimated:YES];
        }
        else
        {
            TYDBindAuthorizeController *vc = [TYDBindAuthorizeController new];
            [self.navigationController pushViewController:vc animated:YES];
        }
        
        self.noticeText = @"等待管理员审核";
    }
    else
    {
        NSArray *viewControllerList = self.navigationController.viewControllers;
        
        UIViewController *destVC = nil;
        if(viewControllerList.count >= 2)
        {
            destVC = viewControllerList[1];
        }
        if(destVC)
        {
            [self.navigationController popToViewController:destVC animated:YES];
        }
        
        self.noticeText = @"绑定失败";
    }
    
    [self progressHUDHideImmediately];
}

- (void)bindingSucceedWithChildInfo:(NSDictionary *)childInfo
{
    TYDDataCenter *dataCenter = [TYDDataCenter defaultCenter];
    NSMutableArray *kidInfoList = dataCenter.kidInfoList.mutableCopy;
    
    TYDKidInfo *kidInfo = [TYDKidInfo new];
    [kidInfo setAttributes:childInfo];
    
    [kidInfoList addObject:kidInfo];
    [dataCenter saveKidInfoList:kidInfoList];
    dataCenter.currentKidInfo = kidInfo;
    
    if(self.isFirstLoginSituation)
    {
        UINavigationController *mainNavigationController = [self.storyboard instantiateViewControllerWithIdentifier:@"mainNavigationController"];
        [self presentViewController:mainNavigationController animated:YES completion:^{
            [self.navigationController popViewControllerAnimated:NO];
        }];
    }
    else
    {
        [self.navigationController popToRootViewControllerAnimated:YES];
    }
}

@end
