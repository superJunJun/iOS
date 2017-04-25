//
//  BOUserDefaultKeysInfo.h
//

#ifndef __BOUserDefaultKeysInfo_H__
#define __BOUserDefaultKeysInfo_H__

//TYDUserInfo.h
//管理本地缓存的用户基本信息
#define sUserInfoDicKey                         @"userInfoDicKey"

//TYDDataCenter.m
//本地儿童信息ID管理
#define sMessageIndexMarkedKey                  @"messageIndexMarked"

//记录是否为首次使用，以确定是否导入应用简介页面
#define sFirstTimeLaunchedMarkKey               @"firstTimeLaunchedMark"

//账号管理
#define sEnrollTokenKey                         @"enrollToken"

#define sResetPasswordTokenKey                  @"resetPasswordToken"

#define sResetPwdThroughOldPwdTokenKey          @"resetPwdThroughOldPwdTokenKey"

//消息推送
#define sRemoteNotificationDeviceToken          @"remoteNotificationDeviceToken"
#define sRemoteNotificationInfoDicKey           @"remoteNotificationInfoDicKey"
#define sRemoteNotificationSentAdmin            @"remoteNotificationIsAdminAgreen"

#endif//__BOUserDefaultKeysInfo_H__
