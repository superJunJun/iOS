//
//  TYDPostUrlRequest.h
//

#import <Foundation/Foundation.h>

@interface TYDPostUrlRequest : NSObject

//网络连接是否有效
+ (BOOL)networkConnectionIsAvailable;

//发起网络连接
+ (void)postUrlRequestWithMessageCode:(NSUInteger)msgCode
                               params:(NSDictionary *)params
                        completeBlock:(PostUrlRequestCompleteBlock)completionBlock
                          failedBlock:(PostUrlRequestFailedBlock)failedBlock;

@end
