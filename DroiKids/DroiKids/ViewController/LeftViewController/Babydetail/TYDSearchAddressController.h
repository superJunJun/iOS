//
//  TYDSearchAddressController.h
//  DroiKids
//
//  Created by wangchao on 15/8/17.
//  Copyright (c) 2015年 superjunjun. All rights reserved.
//

#import "BaseViewController.h"

typedef NS_ENUM(NSInteger, TYDAddressType){
    TYDAddressSchoolType,
    TYDAddressFamilyType,
};

@protocol TYDSearchAddressDelegate <NSObject>
@optional
- (void)searchAddressComplete:(NSString *)addressString;

@end

@interface TYDSearchAddressController : BaseViewController

@property (strong, nonatomic) NSArray *addressArray;
@property (assign, nonatomic) TYDAddressType addressType;

@property (assign, nonatomic) id<TYDSearchAddressDelegate> delegate;

@end
