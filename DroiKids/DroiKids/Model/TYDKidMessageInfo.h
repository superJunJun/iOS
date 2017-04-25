//
//  TYDKidMessageInfo.h
//  DroiKids
//
//  Created by macMini_Dev on 15/9/2.
//  Copyright (c) 2015年 TYDTech. All rights reserved.
//

#import "TYDBaseModel.h"

@interface TYDKidMessageInfo : TYDBaseModel

@property (strong, nonatomic) NSString *kidID;
@property (strong, nonatomic) NSString *messageID;
@property (strong, nonatomic) NSString *messageContent;
@property (strong, nonatomic) NSNumber *messageUnreadFlag;
@property (strong, nonatomic) NSNumber *infoType;
@property (strong, nonatomic) NSNumber *infoCreateTime;

@end
