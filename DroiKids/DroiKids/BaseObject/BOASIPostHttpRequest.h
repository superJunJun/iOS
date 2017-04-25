//
//  BOASIPostHttpRequest.h
//
//  网络连接辅助模块
//

#import <Foundation/Foundation.h>
#import "ASIFormDataRequest.h"

typedef void(^PostHttpRequestCompletionBlock)(id result);
typedef void(^PostHttpRequestFailedBlock)(NSUInteger msgCode, id result);

@interface BOASIPostHttpRequest : NSObject

//网络连接是否有效
+ (BOOL)networkConnectionIsAvailable;

//发起网络连接
+ (ASIHTTPRequest *)requestWithMessageCode:(NSUInteger)msgCode
                                    params:(NSMutableDictionary *)params
                             completeBlock:(PostHttpRequestCompletionBlock)completionBlock
                               failedBlock:(PostHttpRequestFailedBlock)failedBlock;

@end
