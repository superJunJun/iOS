//
//  TYDHistoricalTrackCalendarView.h
//  DroiKids
//
//  Created by caiyajie on 15/8/19.
//  Copyright (c) 2015年 superjunjun. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TYDHistoricalTrackCalendar.h"

@class TYDHistoricalTrackCalendarView;
@protocol TYDHistoricalTrackCalendarViewDelegate <NSObject>
@optional

- (void)calendarDateBlockSelected:(TYDHistoricalTrackCalendarView *)calendarView;
- (void)dateBlockSelectedIndex:(NSInteger)index withDate:(NSDate*)date withDay:(NSInteger)day;
- (void)historicalTrackCalendarViewBelowViewAction:(TYDHistoricalTrackCalendarView *)calendarView;
- (void)weekdayTitleBarSelectedWithIntervalToToday:(NSInteger) interval;
@end

@interface TYDHistoricalTrackCalendarView : UIView <TYDHistoricalTrackCalendarDelegate>

@property (assign, nonatomic) id<TYDHistoricalTrackCalendarViewDelegate> delegate;
@property (strong, nonatomic) NSDate *selectedDate;
@property (nonatomic) NSInteger selectedIndex;

- (void)openCalendar;
- (void)closeCalendar;

@end
