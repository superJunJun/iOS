//
//  TYDHistoricalTrackCalendar.h
//  DroiKids
//
//  Created by caiyajie on 15/8/19.
//  Copyright (c) 2015年 superjunjun. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TYDHistoricalTrackDateBlock.h"

@class TYDHistoricalTrackCalendar;
@protocol TYDHistoricalTrackCalendarDelegate <NSObject>
@optional

- (void)calendarDateBlockSelected:(TYDHistoricalTrackCalendar *)calendar;
- (void)dateBlockSelectedWithDate:(NSDate *)date andIndex:(NSInteger )index withDay:(NSInteger)day withCalendar:(TYDHistoricalTrackCalendar*)calendar; //xiaci jinru

@end

@interface TYDHistoricalTrackCalendar : UIView<TYDHistoricalTrackDateBlockDelegate>

@property (nonatomic, strong) NSDate *date;
@property (strong, nonatomic) NSArray *dateBlocks;
@property (assign, nonatomic) id<TYDHistoricalTrackCalendarDelegate> delegate;
@property (strong, nonatomic) TYDHistoricalTrackDateBlock *selectedBlock;
@property (nonatomic, strong) NSDate *selectedDate;
@property (nonatomic) NSInteger selectedIndex;
@property (nonatomic) NSInteger selectedInterval;

- (instancetype)initWithDate:(NSDate *)date WithFrame:(CGRect)frame withBlockSize:(CGSize)blockSize;

@end
