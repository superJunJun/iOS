//
//  DESUtil.h
//

#import <Foundation/Foundation.h>

@interface DESUtil : NSObject

+ (NSData *)DESEncrypt:(NSData *)data WithKey:(NSString *)key;
+ (NSData *)DESDecrypt:(NSData *)data WithKey:(NSString *)key;

@end
