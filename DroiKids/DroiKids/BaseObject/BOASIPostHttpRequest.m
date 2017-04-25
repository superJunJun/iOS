//
//  BOASIPostHttpRequest.m
//
//  网络连接辅助模块
//

#import "BOASIPostHttpRequest.h"
#import <SystemConfiguration/SystemConfiguration.h>
#import "SBJson.h"

#define sPostHttpMethodName     @"POST"
#define sTestServerUrl          @"wap.baidu.com"
#define sServerUrlBasic         @"http://121.40.28.8:2461"

@implementation BOASIPostHttpRequest

+ (NSDictionary *)requestHeadDictionaryCreateWithMessageCode:(NSUInteger)msgCode
{
    NSDictionary *headDic =
    @{
        @"mcd"      :@(msgCode),
        @"ver"      :@1,
        @"type"     :@1,
        @"lsb"      :@(-9153731842417392736),
        @"msb"      :@(4696390634531605470)
    };
    
    return headDic;
}

+ (ASIHTTPRequest *)requestWithMessageCode:(NSUInteger)msgCode
                                    params:(NSMutableDictionary *)params
                             completeBlock:(PostHttpRequestCompletionBlock)completionBlock
                               failedBlock:(PostHttpRequestFailedBlock)failedBlock
{
    if(!params)
    {
        params = [NSMutableDictionary new];
    }
    NSDictionary *headDic = [self requestHeadDictionaryCreateWithMessageCode:msgCode];
    [params addEntriesFromDictionary:headDic];
    
    NSLog(@"params:%@", params);
    
    __block ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:sServerUrlBasic]];
    //请求超时时间
    [request setTimeOutSeconds:60];
    [request setRequestMethod:sPostHttpMethodName];
    
    //POST请求
    for(NSString *key in params)
    {
        id value = [params objectForKey:key];
        if([value isKindOfClass:[NSData class]])
        {
            [request addData:value forKey:key];
        }
        else
        {
            [request addPostValue:value forKey:key];
        }
    }
    
    //设置请求完成的block
    __weak ASIFormDataRequest *requestTemp = request;
    [request setCompletionBlock:^{
        NSData *data = requestTemp.responseData;
        NSString *str = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        NSLog(@"str:%@", str);
//        id result = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
//        NSError *error;
//        id result = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&error];
        id result = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
        if(completionBlock != nil)
        {
            completionBlock(result);
        }
    }];
    
    //设置请求失败的block
    [request setFailedBlock:^{
        NSError *error = requestTemp.error;
        if(failedBlock != nil)
        {
            failedBlock(msgCode, error);
        }
    }];
    
    [request startAsynchronous];
    return request;
}

//网络连接是否有效
+ (BOOL)networkConnectionIsAvailable
{
    SCNetworkReachabilityFlags flags;
    
    // Recover reachability flags
    SCNetworkReachabilityRef reachability = SCNetworkReachabilityCreateWithName(CFAllocatorGetDefault(), [sTestServerUrl UTF8String]);
    //获得连接的标志
    BOOL didRetrieveFlags = SCNetworkReachabilityGetFlags(reachability, &flags);
    CFRelease(reachability);
    //如果不能获取连接标志，则不能连接网络，直接返回
    if(!didRetrieveFlags)
    {
        return NO;
    }
    //根据获得的连接标志进行判断
    BOOL isReachable = flags & kSCNetworkFlagsReachable;
    BOOL needsConnection = flags & kSCNetworkFlagsConnectionRequired;
    return (isReachable && !needsConnection) ? YES : NO;
}

@end
