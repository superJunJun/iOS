//
//  NSString+MD5Addition.m
//
//  NSString MD5加密
//

#import "NSString+MD5Addition.h"
//#import <CommonCrypto/CommonDigest.h>

extern unsigned char *CC_MD5(const void *data, uint32_t len, unsigned char *md);

@implementation NSString (MD5Addition)

- (NSString *)MD5String
{
    if(self.length == 0)
    {
        return @"";
    }
    
    const char *cString = [self UTF8String];
    unsigned char result[16];//CC_MD5_DIGEST_LENGTH
    
    CC_MD5(cString, (uint32_t)strlen(cString), result);
    return [NSString stringWithFormat:
            @"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",
            result[0],  result[1],  result[2],  result[3],
            result[4],  result[5],  result[6],  result[7],
            result[8],  result[9],  result[10], result[11],
            result[12], result[13], result[14], result[15]
            ];
}

- (BOOL)isMD5EqualTo:(NSString *)MD5String
{
    return [[self MD5String] isEqualToString:MD5String];
}

@end
