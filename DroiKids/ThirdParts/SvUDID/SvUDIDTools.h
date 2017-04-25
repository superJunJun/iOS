//
//  SvUDIDTools.h
//  SvUDID
//
//  Created by  maple on 8/18/13.
//  Copyright (c) 2013 maple. All rights reserved.
//
//  UDID for different iOS Version
//
//  Note: before you run the project on device, you should replace "YOURAPPID" with your profile's APPID. the "YOURAPPID" appear in two place, one in KeyChainAccessGroup.plist, another in SvUDIDTools.m
//

#import <Foundation/Foundation.h>

@interface SvUDIDTools : NSObject

//obtain Unique Device Identity
+ (NSString *)UDID;

@end
