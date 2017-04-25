//
//  TYDContact.h
//  DroiKids
//
//  Created by wangchao on 15/8/27.
//  Copyright (c) 2015年 TYDTech. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TYDKidContactInfo.h"

#define sAvatarNamePrefix             @"addressBookAvatar_"

@interface TYDContact : NSObject

@property (assign, nonatomic) NSInteger sectionNumber;
@property (assign, nonatomic) NSInteger recondID;

@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSMutableArray *phoneNumbers;
@property (nonatomic, strong) NSNumber *avatarNum;
@property (nonatomic, assign) TYDKidContactType contactType;

@end
