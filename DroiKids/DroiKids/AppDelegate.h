//
//  AppDelegate.h
//  DroiKids
//
//  Created by superjunjun on 15/8/5.
//  Copyright (c) 2015年 superjunjun. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TYDDrawerViewController.h"

typedef NS_ENUM(NSInteger, TYDRemoteNotificationOperateCode){
    
    RemoteNotificationChildContractUpdate      = 103001, //儿童通讯录更新   （用户更新后，推送给手表）
    RemoteNotificationChildContractAdd         = 103002, //儿童通讯录添加   （用户更新后，推送给手表）
    RemoteNotificationChildContractDelete      = 103003, //儿童通讯录删除   （用户更新后，推送给手表）
    RemoteNotificationAdminReleaseOther        = 103004, //用户被管理员解绑 （推送给被解绑的用户）ok
    RemoteNotificationAdminReleaseWatch        = 103005, //管理员注销设备   （推送给所有用户）ok
    RemoteNotificationAdminTransferOther       = 103006, //管理员转移权限   （推送给所有用户和手表新的管理员）ok
    RemoteNotificationUserReleaseSelf          = 103007, //用户自己解绑     （推送给管理员用户解绑）ok
    RemoteNotificationUserBecomeAdmin          = 103008, //用户变为管理员    （推送给所有用户）与06重复
    RemoteNotificationChildInfoUpdate          = 103009, //儿童信息更新（推送给所有绑定用户）ok
    RemoteNotificationUserGetElectricity       = 103010, //用户获取手表电量（推送给手表）
    RemoteNotificationWatchTransferElectricity = 103011, //手表上传电量（推送给所有绑定用户）x--
    RemoteNotificationUserCallWatch            = 103012, //用户发起监听 （推送给手表）
    RemoteNotificationUserGetPosition          = 103013, //用户主动要求获取手表当前位置（推送给用户）x---
    RemoteNotificationWatchNoAnswerPosition    = 103014, //用户给手表打电话，儿童未接听，上传位置（推送给用户）x---
    RemoteNotificationWatchOutFence            = 103015, //电子围栏出上传位置（推送给用户）x--
    RemoteNotificationWatchInFence             = 103016, //电子围栏入上传位置（推送给用户）x---
    RemoteNotificationWatchTimingPosition      = 103017, //定时上传位置（推送给用户）x----
    RemoteNotificationWatchCastOff             = 103018, //防脱落（推送给用户）X
    RemoteNotificationUserBindWatchRequest     = 103019, //用户绑定手表请求（推送给管理员用户）OK
    RemoteNotificationUserBindWatchSuccess     = 103020, //管理员同意，用户绑定手表成功（推送给用户）ok
    RemoteNotificationUserBindWatchFailed      = 103021, //管理员拒绝，用户绑定手表失败（推送给用户）ok
    RemoteNotificationUserBindWatchOther       = 103022,  //未知原因绑定失败（推送给用户）ok
    RemoteNotificationAdminSetWatch            = 103023  //儿童信息被管理员修改（推送给用户）ok
    
};


@protocol TYDRemoteNotificationEventDelegate <NSObject>

@optional
- (void)applicationDidReceiveRemoteNotification:(BOOL)isAllow withWatchId:(NSString *)watchId;
- (void)applicationDidFinishLaunching;

@end

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (weak, nonatomic) TYDDrawerViewController *drawerViewController;
@property (assign, nonatomic) id<TYDRemoteNotificationEventDelegate> eventDelegate;

@end

