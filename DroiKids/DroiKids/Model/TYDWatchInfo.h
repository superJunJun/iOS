//
//  TYDWatchInfo.h
//  DroiKids
//
//  Created by superjunjun on 15/9/25.
//  Copyright © 2015年 TYDTech. All rights reserved.
//

#import "TYDBaseModel.h"

#define nwatchStateDefaultValue          @(0)


@interface TYDWatchInfo : TYDBaseModel

@property (strong, nonatomic) NSNumber *stateID;             //自增id 为null 表示同步，不为null 表示更新
@property (strong, nonatomic) NSString *openID;              //管理员id
@property (strong, nonatomic) NSString *watchID;             //儿童手表Id
@property (strong, nonatomic) NSNumber *autoConnectState;    //手表自动接通 0  关  1 开
@property (strong, nonatomic) NSNumber *silentState;         //静音状态   0  关  1  开
@property (strong, nonatomic) NSString *silentTime;          //静音时间段，中间空格隔开
@property (strong, nonatomic) NSNumber *backlightTime;       //背光时间  min
@property (strong, nonatomic) NSNumber *watchSoundState;     //铃声  0 关  1  开
@property (strong, nonatomic) NSNumber *watchShockState;     //震动 0 关  1  开
@property (strong, nonatomic) NSNumber *capTime;              //手表上传位置信息的间隔时间  min
@property (strong, nonatomic) NSNumber *electronicFenceState;    //电子围栏开关  0  关  1  开
@property (strong, nonatomic) NSString *fenceCenterPoint;      //点（当前为圆心坐标，经纬度之间空格隔开）
@property (strong, nonatomic) NSNumber *fenceRadius;             //半径，单位待定

- (void)watchAttributeSetDefaultValue;
- (BOOL)isEqual:(TYDWatchInfo *)object;


@end
