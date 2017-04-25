//
//  TYDBabyDetailView.h
//  DroiKids
//
//  Created by superjunjun on 15/9/11.
//  Copyright (c) 2015年 TYDTech. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol TYDBabyDetailDelegate <NSObject>

- (void)switchBaby:(NSString *)baby;
- (void)addBaby;

@end
@interface TYDBabyDetailView : UIView <UITableViewDataSource, UITableViewDelegate>

@property (strong, nonatomic) NSArray   *kidInfoArray;
//@property (strong, nonatomic) NSString  *currentBabyName;
@property (assign, nonatomic) id <TYDBabyDetailDelegate> delegate;

- (id)initWithkidInfoArray:(NSArray *)array;

@end
