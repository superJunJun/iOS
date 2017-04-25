//
//  AppDelegate.m
//  DroiKids
//
//  Created by superjunjun on 15/8/5.
//  Copyright (c) 2015年 superjunjun. All rights reserved.
//

#import "AppDelegate.h"
#import <MAMapKit/MAMapKit.h>
#import "VirgoPush.h"
#import "TYDAMPostUrlRequest.h"
#import "TYDPostUrlRequest.h"
#import "TYDUserInfo.h"
#import "TYDDataCenter.h"
#import "BONoticeBar.h"
#import "TYDKidMessageInfo.h"
#import "TYDMainViewController.h"

@interface AppDelegate ()<UIAlertViewDelegate>

@property (strong, nonatomic)  NSDictionary   *remoteNotificationDic;//收到推送消息（一个）处理

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
     NSLog(@"didFinishLaunching");
    [MAMapServices sharedServices].apiKey = sGaodeMapSDKAppKey;
//    [self registerRemoteNotification:application withLaunchOptions:launchOptions];
    [[VirgoPush shared] registerForRemoteNotifications];
    NSSetUncaughtExceptionHandler(&uncaughtExceptionHandler);
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    NSLog(@"applicationDidEnterBackground");
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
     application.applicationIconBadgeNumber = 0;
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
     NSLog(@"applicationDidBecomeActive");
//    处理直接点击应用图标，未点击推送消息情况的清0
    if (application.applicationIconBadgeNumber>0)
    {  //badge number 不为0，说明程序有那个圈圈图标
        NSLog(@"我可能收到了推送");
        //这里进行有关处理
        [application setApplicationIconBadgeNumber:0];   //将图标清零。
    }
    
}

- (void)applicationWillTerminate:(UIApplication *)application
{
//    [[TYDDataCenter defaultCenter] saveContext];
}

#pragma mark - remoteNotification

- (void)registerRemoteNotification:(UIApplication *)application withLaunchOptions:(NSDictionary *)launchOptions
{
    //注册推送通知（iOS8注册方法发生了变化）
    if([application respondsToSelector:@selector(isRegisteredForRemoteNotifications)])
    {
        //创建UIUserNotificationSettings，并设置消息的显示类类型
        [application registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeAlert|UIUserNotificationTypeBadge|UIUserNotificationTypeSound categories:nil]];
        [application registerForRemoteNotifications];
    }
    else
    {
        [application registerForRemoteNotificationTypes:(UIRemoteNotificationTypeBadge|UIRemoteNotificationTypeSound|UIRemoteNotificationTypeAlert)];
    }
    
//    [[UIApplication sharedApplication]setApplicationIconBadgeNumber:0];
//    [[UIApplication sharedApplication] unregisterForRemoteNotifications];
//    if (&UIApplicationOpenSettingsURLString != NULL)
//        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];

    
//    if (launchOptions) {
//        NSDictionary* pushNotificationKey = [launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey];
//        if (pushNotificationKey)
//        {
//            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"推送通知"
//                                                           message:@"这是通过推送窗口启动的程序，你可以在这里处理推送内容"
//                                                          delegate:nil
//                                                 cancelButtonTitle:@"知道了"
//                                                 otherButtonTitles:nil, nil];
//            [alert show];
//        }
//    }

}

//注册通知后在此接收设备令牌
- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
    [[VirgoPush shared] registerDeviceToken:deviceToken];//某个设备安装一次应用后只会发送一次
    
    NSString *tokenString = [VirgoPush deviceTokenFromData:deviceToken];
    [[NSUserDefaults standardUserDefaults] setObject:tokenString forKey:sRemoteNotificationDeviceToken];
    NSLog(@"data:%@",deviceToken);
    NSLog(@"tokenString:%@", tokenString);
//
//    NSData *oldToken= [[NSUserDefaults standardUserDefaults] objectForKey:sRemoteNotificationDeviceToken];
//    //如果偏好设置中的已存储设备令牌和新获取的令牌不同则存储新令牌并且发送给服务器端
//    if (![oldToken isEqualToData:deviceToken])
//    {
//        [[NSUserDefaults standardUserDefaults] setObject:deviceToken forKey:sRemoteNotificationDeviceToken];
//    }
}

//令牌获取失败
-(void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error
{
    NSLog(@"didFailToRegisterForRemoteNotificationsWithError:%@", error.localizedDescription);
}

//接收到推送通知之后

//- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
//
//    // Required
//    NSLog(@"in iOS 6 mode");
//    [[VirgoPush shared] handleRemoteNotification:userInfo];
//}
//
//- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler
//{
//    // IOS 7 Support Required
//    NSLog(@"in iOS 7 mode");
//    application.applicationIconBadgeNumber += 1;
//    [[VirgoPush shared] handleRemoteNotification:userInfo];
//    completionHandler(UIBackgroundFetchResultNewData);
//}

-(void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
{
    NSLog(@"didReceiveRemoteNotification:%@", userInfo);
    NSString *alertString = [NSString stringWithFormat:@"%@",
                             [[userInfo objectForKey:@"aps"] objectForKey:@"alert"]];
    NSLog(@"收到推送消息，标题为：\n[%@]",alertString);
    //    [self LoadRemoteNotificationInfo];
    [self getNotificationInfo];
    
    if([TYDUserInfo sharedUserInfo].isUserAccountEnable)
    {
        self.remoteNotificationDic =  [[[userInfo objectForKey:@"aps"]objectForKey:@"body"]
                                       objectForKey:@"content"];
        NSNumber *operateCodeNumber =[self.remoteNotificationDic objectForKey:@"operatecode"];
        NSInteger operateCode = operateCodeNumber.integerValue;
        
        if(operateCode == RemoteNotificationUserBindWatchRequest)
        {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"温馨提示"
                                                                message:alertString
                                                               delegate:self
                                                      cancelButtonTitle:@"拒绝"
                                                      otherButtonTitles:@"同意申请", nil];
            alertView.delegate = self;
            [alertView show];
        }
        else if(operateCode == RemoteNotificationUserBindWatchSuccess
                ||operateCode == RemoteNotificationUserBindWatchFailed
                ||operateCode == RemoteNotificationUserBindWatchOther)
        {
            BOOL isAllow = operateCode == RemoteNotificationUserBindWatchSuccess? YES : NO;
            
            NSString *watchId = [self.remoteNotificationDic objectForKey:@"watchid"];
            if([TYDDataCenter defaultCenter].currentKidInfo)
            {
                if(isAllow)
                {
                    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"温馨提示"
                                                                    message:@"恭喜你，管理员已允许绑定，是否现在更新儿童列表？"
                                                                   delegate:self
                                                          cancelButtonTitle:@"否"
                                                          otherButtonTitles:@"是", nil];
                    alertView.delegate = self;
                    [alertView show];
                }
                else
                {
                    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"温馨提示"
                                                                        message:alertString
                                                                       delegate:self
                                                              cancelButtonTitle:@"确定"
                                                              otherButtonTitles:nil];
                    alertView.delegate = self;
                    [alertView show];
                }
            }
            else
            {
                if([self.eventDelegate respondsToSelector:@selector(applicationDidReceiveRemoteNotification:withWatchId:)])
                {
                    [self.eventDelegate applicationDidReceiveRemoteNotification:isAllow withWatchId:watchId];
                }
            }
        }
        else if(operateCode == RemoteNotificationChildInfoUpdate)
        {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"温馨提示"
                                                                message:@"儿童信息有更新，是否现在更新？"
                                                               delegate:self
                                                      cancelButtonTitle:@"暂不更新"
                                                      otherButtonTitles:@"更新", nil];
            alertView.delegate = self;
            [alertView show];
        }
        else if(operateCode == RemoteNotificationAdminReleaseOther)
        {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"温馨提示"
                                                                message:@"管理员已经解除了你与手表的绑定"
                                                               delegate:self
                                                      cancelButtonTitle:@"确定"
                                                      otherButtonTitles:nil];
            alertView.delegate = self;
            [alertView show];

        }
        else if(operateCode == RemoteNotificationAdminReleaseWatch)
        {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"温馨提示"
                                                                message:@"管理员注销设备！"
                                                               delegate:self
                                                      cancelButtonTitle:@"确定"
                                                      otherButtonTitles:nil];
            alertView.delegate = self;
            [alertView show];
            
        }
        else if(operateCode == RemoteNotificationAdminTransferOther)
        {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"温馨提示"
                                                                message:@"你已成为管理员！"
                                                               delegate:self
                                                      cancelButtonTitle:@"确定" otherButtonTitles:nil];
            alertView.delegate = self;
            [alertView show];
        }
        else if(operateCode == RemoteNotificationWatchTransferElectricity
                ||operateCode == RemoteNotificationWatchTimingPosition)
        {
            //在主页的时候获取到通知
            TYDKidInfo *currentKidInfo = [[TYDDataCenter defaultCenter]currentKidInfo];
            UINavigationController *mainNavigationController = [[UIStoryboard storyboardWithName:sMainStoryboardName bundle:[NSBundle mainBundle]] instantiateViewControllerWithIdentifier:@"mainNavigationController"];
            TYDMainViewController *mainVC = (TYDMainViewController *)mainNavigationController.viewControllers.firstObject;
            
            for (TYDKidInfo *kidInfo in [[TYDDataCenter defaultCenter]kidInfoList])
            {
                if(operateCode == RemoteNotificationWatchTransferElectricity)
                {
                    NSString *watchId = self.remoteNotificationDic[@"watchid"];
                    if([kidInfo.watchID isEqualToString:watchId])
                    {
                        kidInfo.batteryLeft = self.remoteNotificationDic[@"electricity"];
                    }
                    if([watchId isEqualToString:currentKidInfo.watchID])
                    {
                        [mainVC reloadBettry:kidInfo.batteryLeft.integerValue];
                    }
                }
                else
                {
                    NSString *childId = self.remoteNotificationDic[@"childid"];
                    NSString *locationString = [NSString stringWithFormat:@"%@,%@,%@",self.remoteNotificationDic[@"latitude"],self.remoteNotificationDic[@"longitude"],[[[userInfo objectForKey:@"aps"]objectForKey:@"body"]                                                                                     objectForKey:@"createtime"]];;
                    if([kidInfo.kidID isEqualToString:childId])
                    {
                        kidInfo.currentLocation = locationString;
                    }
                    if([childId isEqualToString:currentKidInfo.kidID])
                    {
                        [mainVC reloadLocation:locationString];
                    }
                }
            }
        }
        else
        {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"温馨提示"
                                                                message:alertString
                                                               delegate:self
                                                      cancelButtonTitle:@"确定" otherButtonTitles:nil];
            alertView.delegate = self;
            [alertView show];
        }
 
    }
}

//获取当前屏幕显示的viewcontroller
- (UIViewController *)getCurrentVC
{
    UIViewController *result = nil;
    
    UIWindow * window = [[UIApplication sharedApplication] keyWindow];
    if (window.windowLevel != UIWindowLevelNormal)
    {
        NSArray *windows = [[UIApplication sharedApplication] windows];
        for(UIWindow * tmpWin in windows)
        {
            if (tmpWin.windowLevel == UIWindowLevelNormal)
            {
                window = tmpWin;
                break;
            }
        }
    }
    
    UIView *frontView = [[window subviews] lastObject];
    id nextResponder = [frontView nextResponder];
    
    if([nextResponder isKindOfClass:[UIViewController class]])
    {
        result = nextResponder;
    }
    else
    {
        result = window.rootViewController;
    }
    return result;
}

#pragma mark -UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(buttonIndex == alertView.cancelButtonIndex)
    {
        if([alertView.message isEqualToString:@"用户请求绑定，请审批"])
        {
            [self bindWatchAdminEvent:0];
        }
        else if([alertView.message isEqualToString:@"管理员已经解除了你与手表的绑定"]
                ||[alertView.message isEqualToString:@"管理员注销设备！"]
                ||[alertView.message isEqualToString:@"你已成为管理员！"])
        {
            [self loadBabyInfoList];
        }
    }
    else if (buttonIndex == alertView.firstOtherButtonIndex)
    {
       if([alertView.message isEqualToString:@"用户请求绑定，请审批"])
       {
           [self bindWatchAdminEvent:1];
//           [self loadBabyInfoList];
       }
       else if ([alertView.message isEqualToString:@"儿童信息有更新，是否现在更新？"])
       {
           [self loadBabyInfoList];
       }
       else if ([alertView.message isEqualToString:@"恭喜你，管理员已允许绑定，是否现在更新儿童列表？"])
       {
           [self loadBabyInfoList];//[self addChildInfo];
       }
    }
}

#pragma mark - ConnectToSever

- (void)getNotificationInfo
{
    NSDictionary *params = @{@"openid"  :[[TYDUserInfo sharedUserInfo]openID]
                             };
    [TYDPostUrlRequest postUrlRequestWithMessageCode:102039 params:params completeBlock:^(id result) {
        [self parseUseNotificationInfo:result];
    } failedBlock:^(NSUInteger msgCode, id result) {
    }];
}

- (void)bindWatchAdminEvent:(NSInteger)isAllow
{
    NSString *watchId = [self.remoteNotificationDic objectForKey:@"watchid"];
    NSString *fromOpenId = [self.remoteNotificationDic objectForKey:@"fromid"];
    NSMutableDictionary *params = [NSMutableDictionary new];
    [params setValue:[TYDUserInfo sharedUserInfo].openID forKey:sPostUrlRequestUserOpenIDKey];
    [params setValue:fromOpenId forKey:@"fromopenid"];
    [params setValue:watchId forKey:@"watchid"];
    [params setValue:@"其他" forKey:@"relationship"];
    [params setValue:@(isAllow) forKey:@"permission"];
    [params setValue:@4 forKey:@"imgid "];
    [TYDPostUrlRequest postUrlRequestWithMessageCode:102017 params:params completeBlock:^(id result) {
        [self bindWatchAdminComplete:result];
    } failedBlock:^(NSUInteger msgCode, id result) {
        
    }];
}

- (void)loadBabyInfoList//儿童信息重新加载刷新
{
    NSMutableDictionary *params = [NSMutableDictionary new];
    [params setValue:[TYDUserInfo sharedUserInfo].openID forKey:@"openid"];
    [TYDPostUrlRequest postUrlRequestWithMessageCode:ServiceMsgCodeKidListInfoDownload params:params completeBlock:^(id result) {
        [self babyInfoDownloadComplete:result];
    } failedBlock:^(NSUInteger msgCode, id result) {
        
    }];
}

- (void)addChildInfo
{
    NSString *watchId = [self.remoteNotificationDic objectForKey:@"watchid"];
    NSMutableDictionary *params = [NSMutableDictionary new];
    [params setValue:watchId forKey:@"watchid"];
    [TYDPostUrlRequest postUrlRequestWithMessageCode:ServiceMsgCodeKidInfoRequest params:params completeBlock:^(id result) {
        [self addChildInfoListComplete:result];
    } failedBlock:^(NSUInteger msgCode, id result) {
        
    }];
}

- (void)LoadRemoteNotificationInfo
{
    NSMutableDictionary *params = [NSMutableDictionary new];
    [params setValue:[TYDUserInfo sharedUserInfo].openID forKey:sPostUrlRequestUserOpenIDKey];
    [TYDPostUrlRequest postUrlRequestWithMessageCode:ServiceMsgCodePushInfoDownload params:params completeBlock:^(id result) {
        [self pushInfoDownloadComplete:result];
    } failedBlock:^(NSUInteger msgCode, id result) {
        
    }];
}

#pragma mark - SuspendEvent

- (void)parseUseNotificationInfo:(id)result
{
    NSLog(@"parseUseLocationInfoComplete:%@", result);
    NSDictionary *dic = result;
    NSNumber *resultCode = result[@"result"];
    if(resultCode != nil
       && resultCode.intValue == 0)
    {
        NSArray *pushsArray = [dic objectForKey:@"pushs"];
        if(pushsArray.count > 0)
        {
            for(NSDictionary *detailDic in pushsArray)
            {
                TYDKidMessageInfo *messageInfo = [TYDKidMessageInfo new];
                NSString *contentString = detailDic[@"content"];
                NSData *data = [contentString dataUsingEncoding:NSUTF8StringEncoding];
                NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
                NSDictionary *contentDic = dic[@"content"];
                messageInfo.kidID = [[[TYDDataCenter defaultCenter]currentKidInfo] kidID];
                messageInfo.messageUnreadFlag = @(0);
                messageInfo.messageContent = contentString;
                messageInfo.infoType = @([contentDic[@"operatecode"] intValue]);
                messageInfo.infoCreateTime = detailDic[@"createtime"];
                [[TYDDataCenter defaultCenter]saveMessageInfo:messageInfo];
            }
        }
    }
}

- (void)bindWatchAdminComplete:(id)result
{
    NSLog(@"bindWatchAdminComplete:%@", result);
    NSNumber *resultStatus = [result objectForKey:@"result"];
    NSString *message = nil;
    if(resultStatus != nil)
    {
        if(resultStatus.intValue == 0)
        {
            message = @"已允许用户成为监护人。";
        }
        else if(resultStatus.integerValue == 6)
        {
            message = @"已拒绝用户成为监护人。";
        }
        else if (resultStatus.integerValue)
        {
            message = @"非管理员";
        }
        [BONoticeBar defaultBar].noticeText = message;
    }
}

- (void)babyInfoDownloadComplete:(id)result
{
    NSLog(@"babyInfoDownloadComplete:%@", result);
    NSNumber *resultCode = result[@"result"];
    if(resultCode != nil
       && resultCode.intValue == 0)
    {
        [[TYDDataCenter defaultCenter]clearKidInfoList];
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
            [BONoticeBar defaultBar].noticeText =  @"儿童信息已更新";
        }
    }
}

- (void)addChildInfoListComplete:(id)result
{
    NSNumber *resultStatus = [result objectForKey:@"result"];
    if(resultStatus != nil && resultStatus.intValue == 0)
    {
        NSDictionary *dic = [result objectForKey:@"watchChild"];
        TYDKidInfo *kidInfo = [TYDKidInfo new];
        [kidInfo setAttributes:dic];
        [[TYDDataCenter defaultCenter]saveKidInfoList:@[kidInfo]];
        [BONoticeBar defaultBar].noticeText =  @"儿童信息已更新";
    }
}

- (void)pushInfoDownloadComplete:(id)result
{
    NSNumber *resultStatus = [result objectForKey:@"result"];
    if(resultStatus != nil && resultStatus.intValue == 0)
    {
        NSMutableDictionary *localPushDic = [[NSUserDefaults standardUserDefaults]objectForKey:[TYDUserInfo sharedUserInfo].openID];
        if(!localPushDic)
        {
            localPushDic = [NSMutableDictionary new];
        }
        
        NSArray *pushArray = [result objectForKey:@"pushs"];
        for(NSDictionary *dic in pushArray)
        {
            NSNumber *operateCodeNumber =[[dic objectForKey:@"content"] objectForKey:@"operatecode"];
            [localPushDic setValue:dic forKey:operateCodeNumber.stringValue];
        }
    }
}

#pragma mark - Exception

void uncaughtExceptionHandler(NSException *exception)
{
    NSArray *callStack = [exception callStackSymbols];//得到当前调用栈信息
    NSString *reason = [exception reason];//非常重要，就是崩溃的原因
    NSString *name = [exception name];//异常类型
    NSLog(@"exceptionType:%@/ncrashReason:%@/ncallStackInfo:%@", name, reason, callStack);
}

@end
