//
//  TYDModifyBabyInfoController.h
//  DroiKids
//
//  Created by wangchao on 15/8/29.
//  Copyright (c) 2015年 TYDTech. All rights reserved.
//

#import "BaseScrollController.h"

@protocol TYDModifyBabyInfoDelegate <NSObject>
@optional
- (void)modifyBabyInfoCompleteWithHeaderViewColor:(NSNumber *)colorType
                                         nickname:(NSString *)nickname
                                           gender:(NSString *)gender;

@end

@interface TYDModifyBabyInfoController : BaseScrollController

@property (strong, nonatomic) NSString *nickname;
@property (strong, nonatomic) NSString *gender;
@property (assign, nonatomic) NSNumber *colorType;
@property (assign, nonatomic) id<TYDModifyBabyInfoDelegate> delegate;

@end
