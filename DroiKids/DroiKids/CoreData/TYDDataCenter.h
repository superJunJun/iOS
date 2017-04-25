//
//  TYDDataCenter.h
//  DroiKids
//
//  Created by macMini_Dev on 15/8/31.
//  Copyright (c) 2015年 TYDTech. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TYDWatchInfo.h"

@class TYDKidInfo, TYDKidMessageInfo;

@protocol TYDDataCenterMessageDelegate <NSObject>
@optional
- (void)dataCenterReceivedNewMessage:(TYDKidInfo *)kidInfo;
@end

@interface TYDDataCenter : NSObject

//delegate应该放置在主页
@property (assign, nonatomic) id<TYDDataCenterMessageDelegate> messageDelegate;

@property (strong, nonatomic) TYDKidInfo *currentKidInfo;
@property (strong, nonatomic) NSArray *kidTrackInfoList;
@property (strong, nonatomic) NSArray *kidContactInfoList;
@property (strong, nonatomic) NSArray *enshrineLocationInfoList;

@property (assign, nonatomic) BOOL isContactInfoListModified;

+ (instancetype)defaultCenter;

- (NSArray *)kidInfoList;
- (void)saveKidInfoList:(NSArray *)kidInfos;
//有捆绑删除此儿童对应消息数据的功能，慎用
- (void)removeOneKidInfo:(TYDKidInfo *)kidInfo;

- (NSArray *)messageInfoList;
- (NSArray *)messageInfoListWithKidID:(NSString *)kidID;
- (void)saveMessageInfo:(TYDKidMessageInfo *)messageInfo;
- (void)removeOneMessageInfo:(TYDKidMessageInfo *)messageInfo;
- (void)removeMessageInfoListWithKidID:(NSString *)kidID;

//通过儿童ID获取儿童信息
- (TYDKidInfo *)kidInfoWithKidID:(NSString *)kidID;

//剔除非绑定儿童在数据库中的信息数据
//一般是在 解绑儿童、登录获得儿童列表信息时 使用
- (void)filterMessageInfoList;

//用户退出登录时使用，不删除信息数据
- (void)clearKidInfoList;
@end
