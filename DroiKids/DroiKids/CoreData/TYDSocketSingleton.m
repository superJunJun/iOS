//
//  TYDSocketSingleton.m
//  DroiKids
//
//  Created by superjunjun on 15/9/19.
//  Copyright © 2015年 TYDTech. All rights reserved.
//

#import "TYDSocketSingleton.h"

#define sDDPushServerUrlBasic         @"121.40.28.8"
#define sDDPushServerPort             @(9966)

@implementation TYDSocketSingleton

+(TYDSocketSingleton *) sharedInstance
{
    
    static TYDSocketSingleton *sharedInstace = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        sharedInstace = [[self alloc] init];
    });
    
    return sharedInstace;
}

-(void)socketConnectHost;// socket连接
{
    self.socket = [[AsyncSocket alloc] initWithDelegate:self];
    NSError *error = nil;
    [self.socket connectToHost:sDDPushServerUrlBasic onPort:sDDPushServerPort.integerValue withTimeout:3 error:&error];
}

#pragma mark  - ConnectSucceed

//- (BOOL)onSocketWillConnect:(AsyncSocket *)sock;
//{
//
//}

-(void)onSocket:(AsyncSocket *)sock didConnectToHost:(NSString  *)host port:(UInt16)port
{
    NSLog(@"did connect to host");
    NSLog(@"onSocket:%p didConnectToHost:%@ port:%hu", sock, host, port);
    NSString *phoneString  = @"15934874308";
    NSData* aData= [phoneString dataUsingEncoding: NSUTF8StringEncoding];
    //这里timeout设置为-1，这样就可以保持长连接状态。
    [sock writeData:aData withTimeout:-1 tag:1];
}

- (void)onSocket:(AsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag
{
    NSLog(@"did read data");
    NSString* message = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSLog(@"message is: \n%@",message);
}

- (void)onSocket:(AsyncSocket *)sock didSecure:(BOOL)flag
{
    NSLog(@"onSocket:%p didSecure:YES", sock);
}

- (void)onSocket:(AsyncSocket *)sock willDisconnectWithError:(NSError *)err
{
    NSLog(@"onSocket:%p willDisconnectWithError:%@", sock, err);
}

- (void)onSocketDidDisconnect:(AsyncSocket *)sock
{
    //断开连接了
    NSLog(@"onSocketDidDisconnect:%p", sock);
}

@end
