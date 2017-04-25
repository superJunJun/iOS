//
//  TYDAMPostUrlRequest.h
//  DroiKids
//
//  Created by macMini_Dev on 15/8/20.
//  Copyright (c) 2015年 superjunjun. All rights reserved.
//
//  AccountManage : AM


#import <Foundation/Foundation.h>
#import "ServerUrlInfoDefines.h"

@interface TYDAMPostUrlRequest : NSObject

+ (void)amRequestWithURL:(NSString *)url
                  params:(NSMutableDictionary *)params
           completeBlock:(AMPostHttpRequestCompletionBlock)completionBlock
             failedBlock:(AMPostHttpRequestFailedBlock)failedBlock;

+ (NSString *)deviceInfoEncode:(NSString *)deviceInfo;
+ (NSString *)deviceInfoDecode:(NSString *)deviceInfo;
+ (NSString *)signInfoCreateWithInfos:(NSArray *)stringArray;

@end
