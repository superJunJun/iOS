//
//  TYDContact.m
//  DroiKids
//
//  Created by wangchao on 15/8/27.
//  Copyright (c) 2015年 TYDTech. All rights reserved.
//

#import "TYDContact.h"

@implementation TYDContact

- (instancetype)init
{
    if(self = [super init])
    {
        self.phoneNumbers = [NSMutableArray array];
    }
    
    return self;
}

@end
