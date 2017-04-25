//
//  TYDHistoricalTrackCalendar.m
//  DroiKids
//
//  Created by caiyajie on 15/8/19.
//  Copyright (c) 2015年 superjunjun. All rights reserved.
//

#import "TYDHistoricalTrackCalendar.h"
#import "TYDHistoricalTrackDateBlock.h"
#import "TYDCalendarAssistor.h"

@implementation TYDHistoricalTrackCalendar

- (instancetype)initWithDate:(NSDate *)date WithFrame:(CGRect)frame withBlockSize:(CGSize)blockSize
{
    self = [super initWithFrame:frame];
    if(self)
    {
        NSMutableArray *dateBlocks = [NSMutableArray new];
        for(int i = 0; i < 42; i++)
        {
            float x = (i % 7) * blockSize.width;
            float y = (i / 7) * blockSize.height;
            
            CGRect blockFrame = CGRectMake(x, y, blockSize.width, blockSize.height);
            TYDHistoricalTrackDateBlock *dateBlock = [[TYDHistoricalTrackDateBlock alloc]initWithBlockFrame:blockFrame withDate:date withIndex:i];
            dateBlock.delegate = self;
            [dateBlocks addObject:dateBlock];
            [self addSubview:dateBlock];
        }
        self.date = date;
        self.dateBlocks = dateBlocks;
        _selectedBlock = nil;
    }
    return self;
}

//-(void)setDate:(NSDate *)date
//{
//    _date = date;
//    TYDDataCenter *dataCenter = [TYDDataCenter defaultCenter];
//    NSArray * monthlyMarks = [dataCenter monthlyRecordInfoMarkValuesForCalendarWithTimeStamp:[date timeIntervalSince1970]];
//    NSInteger daysInThisMonth = [self totaldaysInMonth:date];
//    NSInteger firstDay = [self firstWeekdayInThisMonth:date];
//    
//    for(int index = 0; index < 42; index++)
//    {
//        TYDMainPageCalendarDateBlock * dateBlcok = self.dateBlocks[index];
//        [dateBlcok.todayImgV removeFromSuperview];
//        dateBlcok.dayMarkIcon.hidden = YES;
//        dateBlcok.selected = NO;
//        dateBlcok.enabled = YES;
//        if(self.selectedDate)
//        {
//            if([self month:date] == [self month:self.selectedDate]
//               &&[self year:date] == [self year:self.selectedDate])
//            {
//                if(self.selectedIndex == index)
//                {
//                    dateBlcok.selected = YES;
//                    self.selectedBlock = dateBlcok;
//                }
//            }
//        }
//        
//        if(index >= firstDay
//           && index < firstDay + daysInThisMonth)
//        {
//            NSInteger day = index - firstDay + 1;
//            NSNumber *markNumber = monthlyMarks[day - 1];
//            dateBlcok.dayMarkIcon.hidden = !markNumber.boolValue;
//        }
//        [dateBlcok setDateBlockWithDate:date withIndex:index];
//    }
//}


- (void)setSelectedInterval:(NSInteger)selectedInterval
{
    _selectedInterval = selectedInterval;
    if([TYDCalendarAssistor month:self.date] == [TYDCalendarAssistor month:self.selectedDate]
       && [TYDCalendarAssistor year:self.date] == [TYDCalendarAssistor year:self.selectedDate])
    {
        NSInteger firstDay = [TYDCalendarAssistor firstWeekdayInThisMonth:[NSDate date]];
        NSInteger todayNumber =  [TYDCalendarAssistor day:[NSDate date]];
        NSInteger todayIndex = todayNumber + firstDay - 1;
        NSInteger index;
        if(todayNumber > selectedInterval)
        {
           index = todayIndex - selectedInterval;
        }
        else
        {
            NSInteger lastMonthFirstDay = [TYDCalendarAssistor firstWeekdayInThisMonth:[TYDCalendarAssistor lastMonth:[NSDate date]]];
            NSInteger lasetMonthTotalDays = [TYDCalendarAssistor totaldaysInMonth:[TYDCalendarAssistor lastMonth:[NSDate date]]];
            index = lastMonthFirstDay + lasetMonthTotalDays - 1 - (selectedInterval - todayNumber);
        }
        TYDHistoricalTrackDateBlock *dateBlock = self.dateBlocks[index];
        dateBlock.selected  = YES;
        self.selectedBlock = dateBlock;
    }
}

- (void)calendarDateBlockSelected:(TYDHistoricalTrackDateBlock *)calendarDateBlock
{
    if(!calendarDateBlock.selected)
    {
        if(_selectedBlock != calendarDateBlock)
        {
            _selectedBlock.selected = NO;
            _selectedBlock = calendarDateBlock;
        }
        _selectedBlock.selected = YES;//保证一个calendar内不出现2个选中
    }
    if([self.delegate respondsToSelector:@selector(calendarDateBlockSelected:)])
    {
        [self.delegate calendarDateBlockSelected:self];
    }
}

- (void)dateBlockSelectedWithDate:(NSDate *)date andIndex:(NSInteger)index withDay:(NSInteger)day
{
    if([self.delegate respondsToSelector:@selector(dateBlockSelectedWithDate:andIndex:withDay:withCalendar:)])
    {
        [self.delegate dateBlockSelectedWithDate:date andIndex:index withDay:day withCalendar:self];
    }
}

@end
