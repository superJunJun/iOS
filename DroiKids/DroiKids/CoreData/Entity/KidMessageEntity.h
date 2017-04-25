//
//  KidMessageEntity.h
//  DroiKids
//
//  Created by macMini_Dev on 15/9/2.
//  Copyright (c) 2015年 TYDTech. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface KidMessageEntity : NSManagedObject

@property (nonatomic, retain) NSString * kidID;
@property (nonatomic, retain) NSString * messageID;
@property (nonatomic, retain) NSString * messageContent;
@property (nonatomic, retain) NSNumber * infoCreateTime;
@property (nonatomic, retain) NSNumber * messageUnreadFlag;
@property (nonatomic, retain) NSNumber * infoType;

@end
