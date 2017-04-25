//
//  TYDKidMessageInfo.m
//  DroiKids
//
//  Created by macMini_Dev on 15/9/2.
//  Copyright (c) 2015年 TYDTech. All rights reserved.
//

#import "TYDKidMessageInfo.h"

@implementation TYDKidMessageInfo

- (BOOL)isEqual:(TYDKidMessageInfo *)object
{
    return ([self.kidID isEqualToString:object.kidID]
            && [self.messageID isEqualToString:object.messageID]
            && [self.infoCreateTime isEqualToNumber:object.infoCreateTime]);
}

- (BOOL)setAttributesWithObject:(TYDKidMessageInfo *)object
{
    BOOL result = [super setAttributesWithObject:object];
    if(result)
    {
        //self.kidID = object.kidID;
        //self.messageID = object.messageID;
        self.messageContent = object.messageContent;
        self.messageUnreadFlag = object.messageUnreadFlag;
        self.infoType = object.infoType;
        self.infoCreateTime = object.infoCreateTime;
    }
    return result;
}

@end
