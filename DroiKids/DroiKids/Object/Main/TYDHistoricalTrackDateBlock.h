//
//  TYDHistoricalTrackDateBlock.h
//  DroiKids
//
//  Created by caiyajie on 15/8/19.
//  Copyright (c) 2015年 superjunjun. All rights reserved.
//

#import <UIKit/UIKit.h>

@class TYDHistoricalTrackDateBlock;
@protocol TYDHistoricalTrackDateBlockDelegate <NSObject>
@optional

- (void)calendarDateBlockSelected:(TYDHistoricalTrackDateBlock *)calendarDateBlock;
- (void)dateBlockSelectedWithDate:(NSDate *)date andIndex:(NSInteger)index withDay:(NSInteger)day;//xiaci jinru

@end

@interface TYDHistoricalTrackDateBlock : UIControl

@property (nonatomic, strong) NSDate *date;
@property (strong, nonatomic) UILabel *dayLabel;
@property (assign, nonatomic) id<TYDHistoricalTrackDateBlockDelegate> delegate;
- (instancetype)initWithBlockFrame:(CGRect)frame withDate:(NSDate *)date withIndex:(NSInteger)i;
- (void)setDateBlockWithDate:(NSDate *)date withIndex:(NSInteger)i;

@end
