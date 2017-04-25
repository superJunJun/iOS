//
//  VirgoPush.h
//  VirgoPush
//
//  Created by Kevin on 15/9/22.
//  Copyright (c) 2015年 Kevin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface VirgoPush : NSObject
@property (nonatomic, strong)NSString *deviceToken;
/**
 * Get the shared VirgoPush instance
 */
+ (VirgoPush *)shared;

/**
 * Parse a device token given the raw data returned by Apple from registering for notifications
 */
+ (NSString *)deviceTokenFromData:(NSData *)tokenData;

/**
 * A convenience wrapper for [[UIApplication sharedApplication] registerForRemoteNotificationTypes:types];
 * deprecated in iOS7
 */
- (void)registerForRemoteNotificationTypes:(UIRemoteNotificationType)types;

/**
 * Preferred method for registering for notifications. Backwards compatible with iOS7
 */
- (void)registerForRemoteNotifications;

/**
 * Register the device's token with VirgoPush
 */
- (void)registerDeviceToken:(NSData *)deviceToken;

/**
 * Register the device's token with ZeroPush and subscribe the device's token to a broadcast channel
 */
- (void)registerDeviceToken:(NSData *)deviceToken channel:(NSString *)channel;

/**
 * Handle the userInfo
 */
- (void)handleRemoteNotification:(NSDictionary *)userInfo;
@end
