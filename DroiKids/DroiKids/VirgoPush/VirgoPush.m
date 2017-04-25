//
//  VirgoPush.m
//  VirgoPush
//
//  Created by Kevin on 15/9/22.
//  Copyright (c) 2015年 Kevin. All rights reserved.
//

#import "VirgoPush.h"
#import <CommonCrypto/CommonCryptor.h>
#import "NSData+Base64.h"
#include "DES56.h"

#define DESKEY @"new_push"


char* des56_decrypt( char * cypheredText, size_t cypherlen,  char *key )
{
    char* decypheredText;
    keysched KS;
    int rel_index, abs_index;
    
    /* Aloca array */
    decypheredText =
    (char *) malloc( (cypherlen+1) * sizeof(char));
    if(decypheredText == NULL) {
        return NULL;
    }
    
    /* Inicia decifragem */
    if (key && strlen(key) >= 8)
    {
        char k[8];
        int i;
        
        for (i=0; i<8; i++)
            k[i] = (unsigned char)key[i];
        fsetkey(k, &KS);
    } else {
        free( decypheredText );
        return NULL;
    }
    
    rel_index = 0;
    abs_index = 0;
    
    while (abs_index < (int) cypherlen)
    {
        decypheredText[abs_index] = cypheredText[abs_index];
        abs_index++;
        rel_index++;
        if( rel_index == 8 )
        {
            rel_index = 0;
            fencrypt(&(decypheredText[abs_index - 8]), 1, &KS);
        }
    }
    decypheredText[abs_index] = 0;
    return  decypheredText ;
}


char* des56_encrypt( char *plainText, size_t plainlen, char *key )
{
    keysched KS;
    char *cypheredText;
    int rel_index, pad, abs_index;
    
    cypheredText = (char *) malloc( (plainlen+8) * sizeof(char));
    if(cypheredText == NULL) {
        return NULL;
    }
    
    if (key && strlen(key) >= 8)
    {
        char k[8];
        int i;
        
        for (i=0; i<8; i++)
            k[i] = (unsigned char)key[i];
        fsetkey(k, &KS);
    } else {
        free (cypheredText);
        return NULL;
    }
    
    rel_index = 0;
    abs_index = 0;
    while (abs_index < (int) plainlen) {
        cypheredText[abs_index] = plainText[abs_index];
        abs_index++;
        rel_index++;
        if( rel_index == 8 ) {
            rel_index = 0;
            fencrypt(&(cypheredText[abs_index - 8]), 0, &KS);
        }
    }
    
    pad = 0;
    if(rel_index != 0) { /* Pads remaining bytes with zeroes */
        while(rel_index < 8)
        {
            pad++;
            cypheredText[abs_index++] = 0;
            rel_index++;
        }
        fencrypt(&(cypheredText[abs_index - 8]), 0, &KS);
    }
    cypheredText[abs_index] = pad;
    cypheredText[abs_index] = 0;
    
    return cypheredText ;
}

static NSString *const VirgoPushAPIURLHost = @"http://service-newpush.tt286.com:2400";
static NSString *const UsrDefaultKey = @"VirgoPush-DevToken-key";

@implementation VirgoPush

+ (VirgoPush *)shared
{
    static dispatch_once_t once;
    static id sharedInstance;
    dispatch_once(&once, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}


+ (NSString *)deviceTokenFromData:(NSData *)tokenData
{
    NSString *token = [tokenData description];
    token = [token stringByReplacingOccurrencesOfString:@"<" withString:@""];
    token = [token stringByReplacingOccurrencesOfString:@">" withString:@""];
    token = [token stringByReplacingOccurrencesOfString:@" " withString:@""];
    return token;
}

-(id)init {
    self = [super init];
    if (self) {
//        _operationQueue = [[NSOperationQueue alloc] init];
    }
    
    return self;
}

- (void)registerForRemoteNotificationTypes:(UIRemoteNotificationType)types;
{
    [[UIApplication sharedApplication] registerForRemoteNotificationTypes:types];
}

- (void)registerForRemoteNotifications
{
#ifdef __IPHONE_8_0
    if ([[UIApplication sharedApplication] respondsToSelector:@selector(registerUserNotificationSettings:)])
    {
        UIUserNotificationSettings *notificationSettings = [UIUserNotificationSettings settingsForTypes:(UIUserNotificationTypeAlert | UIUserNotificationTypeBadge | UIUserNotificationTypeSound) categories:nil];
        [[UIApplication sharedApplication] registerUserNotificationSettings:notificationSettings];
        [[UIApplication sharedApplication] registerForRemoteNotifications];
    }
    else
    {
        [[UIApplication sharedApplication] registerForRemoteNotificationTypes: (UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound | UIRemoteNotificationTypeAlert)];
    }
#else
    [[UIApplication sharedApplication] registerForRemoteNotificationTypes: (UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound | UIRemoteNotificationTypeAlert)];
#endif
}

- (void)handleRemoteNotification:(NSDictionary *)userInfo
{
    
}

- (NSString*) genSystemInfo:(NSString*) device_token channel:(NSString *)channel
{
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setObject:[NSNumber numberWithInteger:2] forKey:@"osType"];
    [params setObject:[NSNumber numberWithInteger:1] forKey:@"appId"];
    [params setObject:[NSNumber numberWithInteger:1] forKey:@"version"];
    
    [params setObject:device_token forKey:@"uuid"];
    
    if (channel) {
        [params setObject:channel forKey:@"chId"];
    }
    
    [params setObject:[[NSBundle mainBundle] bundleIdentifier] forKey:@"pName"];
    
    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
    [params setObject:[infoDictionary objectForKey:@"CFBundleVersion"] forKey:@"pVer"];
    
    UIDevice *device = [UIDevice currentDevice];
    [params setObject:[device systemVersion] forKey:@"osVer"];
    
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    CGFloat screenWidth = screenRect.size.width;
    CGFloat screenHeight = screenRect.size.height;
    [params setObject:[NSNumber numberWithInteger:screenWidth] forKey:@"sWidth"];
    [params setObject:[NSNumber numberWithInteger:screenHeight] forKey:@"sHeight"];
    
    
    NSError *jsonError;
    NSData *json = [NSJSONSerialization dataWithJSONObject:params options:0 error:&jsonError];
    if (jsonError) {
        return nil;
    } else {
        return [[NSString alloc]initWithData:json encoding:NSUTF8StringEncoding];
    }
}

- (void)registerDeviceToken:(NSData *)deviceToken
{
    [self registerDeviceToken:deviceToken channel:nil];
}

- (void)registerDeviceToken:(NSData *)deviceToken channel:(NSString *)channel
{
    bool regStatus = [[NSUserDefaults standardUserDefaults] boolForKey:UsrDefaultKey];
    if (regStatus) {
        return;
    }
    NSString *deviceTokenStr = [VirgoPush deviceTokenFromData:deviceToken];
    
    NSString *url = [NSString stringWithFormat:@"%@", VirgoPushAPIURLHost];
    
//    [self HTTPRequest:url data:[deviceTokenStr dataUsingEncoding:NSUTF8StringEncoding]];
    NSString *data = [self genSystemInfo:deviceTokenStr channel:channel];

    NSLog(@"%@", data);
    [self HTTPRequest:url data:[self encrypt:data key:DESKEY]];
}


#pragma mark - DES56 Encrypt/Decrypt
/**
 *  des加密
 *
 *  @param text 原始字符串
 *  @param key  密钥
 *
 *  @return 加密后的字符串
 */

- (NSData *) encrypt: (NSString *) text key:(NSString *) key {
    // c
//    char * src_c =strdup([text UTF8String]);
//    char * key_c = strdup([key UTF8String]);
//    char * cryptedText = des56_encrypt(src_c, strlen(src_c), key_c);
//    free(src_c);
//    free(key_c);
//    printf( "Encrypt:\t0x" );
//    for(int i=0; i < strlen(cryptedText) ; i++ ) {
//        printf( "%02x", (unsigned char)cryptedText[i] );
//    }
//    printf( "\n" );
//    NSData *data = [NSData dataWithBytes:cryptedText length:strlen(cryptedText)];
    
    
    // obj c
    NSData *data = [self encrypt:text encryptOrDecrypt:kCCEncrypt key:key];
    return data;
}

/**
 *  des解密
 *
 *  @param text 加密过的base64字符串
 *  @param key  密钥
 *
 *  @return 解密后的字符串
 */

- (NSString *) decrypt: (NSData *) data key:(NSString *) key {
    // c
//    size_t len = (size_t)[data length];
//    char * cryptedText =strndup([data bytes], len);
//    printf( "Decrypt:\t0x" );
//    for(int i=0; i < len ; i++ ) {
//        printf( "%02x", (unsigned char)cryptedText[i] );
//    }
//    printf( "\n" );
//    char * key_c = strdup([key UTF8String]);
//    char * plainText = des56_decrypt(cryptedText, len, key_c);
//    free(cryptedText);
//    free(key_c);
//    return [NSString stringWithCString:plainText encoding:NSUTF8StringEncoding];
    
    // obj c
    NSString *text = [data base64EncodedString];
    NSData * decode = [self encrypt:text encryptOrDecrypt:kCCDecrypt key:key];
    return [NSString stringWithCString:[decode bytes] encoding:NSUTF8StringEncoding];
}

/**
 *  des 加解密
 *
 *  @param sText            输入字符串
 *  @param encryptOperation 加／解密
 *  @param key              密钥
 *
 *  @return 加密后的数据
 */

- (NSData *)encrypt:(NSString *)sText encryptOrDecrypt:(CCOperation)encryptOperation key:(NSString *)key
{
//    static Byte iv[8]={1,2,3,4,5,6,7,8};
    
    NSData* data = nil;
    
    if (encryptOperation == kCCEncrypt) {
        data = [sText dataUsingEncoding: NSUTF8StringEncoding];
    }
    else
    {
        data = [NSData dataFromBase64String:sText];
    }
    
    
//    NSUInteger bufferSize=([data length] + kCCBlockSize3DES) & ~(kCCBlockSize3DES - 1);
    NSUInteger bufferSize=([data length] + kCCBlockSizeDES) & ~(kCCBlockSizeDES -1);
    
    char buffer[bufferSize];
    
    memset(buffer, 0,sizeof(buffer));
    
    size_t bufferNumBytes;
    
    CCCryptorStatus cryptStatus = CCCrypt(encryptOperation,
                                          
                                          kCCAlgorithmDES,
//                                          kCCAlgorithm3DES,
                                          
//                                          kCCOptionPKCS7Padding,
                                          kCCOptionPKCS7Padding|kCCOptionECBMode,
                                          
                                          [key UTF8String],
                                          
                                          kCCKeySizeDES,
//                                          kCCBlockSize3DES,
                                          
                                          NULL,
//                                          iv,
                                          
                                          [data bytes],
                                          
                                          [data length],
                                          
                                          buffer,
                                          
                                          bufferSize,
                                          
                                          &bufferNumBytes);
    if (cryptStatus == kCCSuccess) NSLog(@"SUCCESS");
    else if (cryptStatus == kCCParamError) NSLog (@"PARAM ERROR");
    else if (cryptStatus == kCCBufferTooSmall) NSLog (@"BUFFER TOO SMALL");
    else if (cryptStatus == kCCMemoryFailure) NSLog (@"MEMORY FAILURE");
    else if (cryptStatus == kCCAlignmentError) NSLog( @"ALIGNMENT");
    else if (cryptStatus == kCCDecodeError) NSLog (@"DECODE ERROR");
    else if (cryptStatus == kCCUnimplemented) NSLog (@"UNIMPLEMENTED");
    if (!cryptStatus == kCCSuccess) {
        return nil;
    }
    
    NSData *result = [NSData dataWithBytes:buffer length:(NSUInteger)bufferNumBytes];
    
    return result;
}

#pragma mark - HTTP Requests

-(void)HTTPRequest:(NSString *)url
            data:(NSData *)postData
// completionHandler:(void (^)(NSHTTPURLResponse* response, NSData* data, NSError* connectionError)) handler
{

    NSString *postLength = [NSString stringWithFormat:@"%lu",(unsigned long)[postData length]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url]];
    [request setHTTPMethod:@"POST"];
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPBody:postData];
//    NSURLConnection *conn = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    [NSURLConnection sendAsynchronousRequest:request
                                       queue:[[NSOperationQueue alloc] init]
                           completionHandler:^(NSURLResponse *urlResponse, NSData *data, NSError *error) {
//                                NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *) urlResponse;
                               if ([data length] > 0 && error == nil) {
//                                   NSLog(@"%@", [[NSString alloc]initWithData:data encoding:NSASCIIStringEncoding]);

                                   NSString *ret = [self decrypt:data key:DESKEY];
                                   NSLog(@"%@", ret);
                                   NSError *jsonError;
                                   NSData *objectData = [ret dataUsingEncoding:NSUTF8StringEncoding];
                                   NSDictionary *json = [NSJSONSerialization JSONObjectWithData:objectData
                                                                                        options:NSJSONReadingMutableContainers
                                                                                          error:&jsonError];
                                   if (jsonError) {
                                       NSLog(@"Json parse error ==> %@", jsonError);
                                   } else {
                                       int code = [[json objectForKey:@"rCode"] intValue];
                                       NSLog(@"return code = %d", code);
                                       if (code == 200) {
                                           NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
                                           
                                           [userDefaults setBool:true forKey:UsrDefaultKey];
                                           [userDefaults synchronize];
                                       } else {
                                           
                                       }
                                   }
                               } else if ([data length] == 0 && error == nil)
                                   NSLog(@"empty");
                               else if (error != nil && error.code == NSURLErrorTimedOut)
                                   NSLog(@"TimeOut");
                               else if (error != nil)
                                   NSLog(@"Error");
                                //handler(httpResponse, data, error);
                           }];
}

@end
