//
//  NSString+MD5Addition.h
//
//  NSString MD5加密
//

#import <Foundation/Foundation.h>

@interface NSString (MD5Addition)

//MD5加密
- (NSString *)MD5String;

//自身字串MD5加密后是否与目标MD5String相等
- (BOOL)isMD5EqualTo:(NSString *)MD5String;

@end
