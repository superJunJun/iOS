//
//  TYDSocketSingleton.h
//  DroiKids
//
//  Created by superjunjun on 15/9/19.
//  Copyright © 2015年 TYDTech. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AsyncSocket.h"

@interface TYDSocketSingleton : NSObject <AsyncSocketDelegate>

@property (nonatomic, strong) AsyncSocket    *socket;       // socket
@property (nonatomic, copy  ) NSString       *socketHost;   // socket的Host
@property (nonatomic, assign) UInt16         socketPort;    // socket的prot
@property (nonatomic, retain) NSTimer        *connectTimer; // 计时器(心跳计时器)

+ (TYDSocketSingleton *)sharedInstance;

-(void)socketConnectHost;// socket连接

@end
