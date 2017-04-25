//
//  TYDSearchAddressResultController.h
//  DroiKids
//
//  Created by wangchao on 15/8/17.
//  Copyright (c) 2015年 superjunjun. All rights reserved.
//

@protocol TYDSearchAddressResultSelectDelegate <NSObject>
@optional
- (void)addressResultSelect:(NSString *)address searchTipAdCode:(NSString *)searchTipAdCode cityName:(NSString *)cityName;

@end

@interface TYDSearchAddressResultController : UITableViewController

//@property (strong, nonatomic, readonly) UITableView *tableView;
@property (strong, nonatomic) NSArray *addressDataArray;
@property (strong, nonatomic) NSArray *searchTipsArray;
@property (assign, nonatomic) id<TYDSearchAddressResultSelectDelegate> delegate;

@end
