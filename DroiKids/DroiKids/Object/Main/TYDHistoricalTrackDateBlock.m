//
//  TYDHistoricalTrackDateBlock.m
//  DroiKids
//
//  Created by caiyajie on 15/8/19.
//  Copyright (c) 2015年 superjunjun. All rights reserved.
//

#import "TYDHistoricalTrackDateBlock.h"
#import "TYDCalendarAssistor.h"

@implementation TYDHistoricalTrackDateBlock

- (instancetype)initWithBlockFrame:(CGRect)frame withDate:(NSDate *)date withIndex:(NSInteger)i
{
    self = [super initWithFrame:frame];
    if(self)
    {
        self.backgroundColor = [UIColor colorWithHex:0xfcfcfc];
        UILabel *dayLabel = [[UILabel alloc] initWithFrame:self.bounds];
        dayLabel.backgroundColor = [UIColor clearColor];
        dayLabel.font = [UIFont systemFontOfSize:12];
        dayLabel.textAlignment = NSTextAlignmentCenter;
        dayLabel.textColor = [UIColor colorWithHex:0x0];
        [self addSubview:dayLabel];
        self.dayLabel = dayLabel;
        
//        self.layer.borderWidth = 0.25;
//        self.layer.borderColor = [UIColor colorWithHex:0xe8e8e8].CGColor;
        
        [self setDateBlockWithDate:date withIndex:i];
    }
    return self;
}

#pragma mark - OverridePropertyMethod

- (void)setSelected:(BOOL)selected
{
    super.selected = selected;
    if(selected)
    {
        self.dayLabel.textColor = [UIColor redColor];
    }
    else
    {
        self.dayLabel.textColor = [UIColor colorWithHex:0x0];
        if([TYDCalendarAssistor month:self.date] == [TYDCalendarAssistor month:[NSDate date]]
           && [TYDCalendarAssistor year:self.date] == [TYDCalendarAssistor year:[NSDate date]])
        {
            NSInteger todayNumber =  [TYDCalendarAssistor day:self.date];
            NSString *todaySring  = [NSString stringWithFormat:@"%ld",(long)todayNumber];
            if([self.dayLabel.text isEqualToString:todaySring])
            {
                self.dayLabel.textColor = [UIColor colorWithHex:0xffffff];
            }
        }
    }
}

- (void)setDateBlockWithDate:(NSDate *)date withIndex:(NSInteger)i
{
    self.date = date;
    NSInteger daysInLastMonth = [TYDCalendarAssistor totaldaysInMonth:[TYDCalendarAssistor lastMonth:date]];
    NSInteger daysInThisMonth = [TYDCalendarAssistor totaldaysInMonth:date];
    NSInteger firstDay = [TYDCalendarAssistor firstWeekdayInThisMonth:date];
    
    NSInteger day = 0;
    if(i < firstDay)
    {
        day = daysInLastMonth - firstDay + i + 1;
        [self setDateStyleBeyondThisMonth:self.dayLabel];//前一月份的日子在本月显示的dateBlock
    }
    else if(i > firstDay + daysInThisMonth - 1)
    {
        day = i + 1 - firstDay - daysInThisMonth;
        [self setDateStyleBeyondThisMonth:self.dayLabel];//后一月份的日子在本月显示的dateBlock
    }
    else
    {
        day = i - firstDay + 1;
        [self setDateStyleThisMonthDays:self.dayLabel];
        [self addTarget:self action:@selector(calendarDateBlockTap:) forControlEvents:UIControlEventTouchUpInside];
    }
    self.dayLabel.text = [NSString stringWithFormat:@"%ld", (long)day];
    //今天
    if([TYDCalendarAssistor month:date] == [TYDCalendarAssistor month:[NSDate date]]
       && [TYDCalendarAssistor year:date] == [TYDCalendarAssistor year:[NSDate date]])
    {
        NSInteger todayIndex = [TYDCalendarAssistor day:[NSDate date]] + firstDay - 1;
        if(i == todayIndex)
        {
            [self setDateStyleToday:self.dayLabel];
        }
        if(i > todayIndex)
        {
            [self setDateStyleBeyondTodayInThisMonth:self.dayLabel];
        }
    }
    if(([TYDCalendarAssistor month:date] > [TYDCalendarAssistor month:[NSDate date]]
        && [TYDCalendarAssistor year:date] == [TYDCalendarAssistor year:[NSDate date]])
       || [TYDCalendarAssistor year:date] > [TYDCalendarAssistor year:[NSDate date]])
    {
        [self setDateStyleBeyondTodayInThisMonth:self.dayLabel];
    }
    
    if([TYDCalendarAssistor month:date] == [TYDCalendarAssistor month:[TYDCalendarAssistor lastMonth:[NSDate date]]])
    {
        NSInteger todayNumber =  [TYDCalendarAssistor day:[NSDate date]];
        NSInteger lastMonthNumber = 30 - todayNumber;
        if(lastMonthNumber <= 0)
        {
            self.dayLabel.textColor = [UIColor colorWithHex:0xb9bcbe];
            self.enabled = NO;
        }
        else
        {
            NSInteger totalDaysLastMonth = [TYDCalendarAssistor totaldaysInMonth:date];
            NSInteger lastMonthEnableNumber = totalDaysLastMonth - lastMonthNumber;
            NSInteger firstDay = [TYDCalendarAssistor firstWeekdayInThisMonth:date];
            NSInteger lastMonthEnableIndex = firstDay + lastMonthEnableNumber - 1;
            if(i <= lastMonthEnableIndex)
            {
                self.dayLabel.textColor = [UIColor colorWithHex:0xb9bcbe];
                self.enabled = NO;
            }
        }
    }
}

#pragma mark - DateButtonStyle

- (void)setDateStyleBeyondThisMonth:(UILabel *)sender
{
    sender.textColor = [UIColor colorWithHex:0xb9bcbe];//[UIColor colorWithHex:0xe5e5e5];
    self.enabled = NO;
}

- (void)setDateStyleToday:(UILabel *)sender
{
    UIImageView *imgV = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"main_calendarToday"]];
    imgV.size = CGSizeMake(self.height, self.height);
    imgV.center = self.innerCenter;
    [self addSubview:imgV];
    [self bringSubviewToFront:sender];
    sender.textColor = [UIColor colorWithHex:0xffffff];
    sender.backgroundColor = [UIColor clearColor];
}

- (void)setDateStyleThisMonthDays:(UILabel *)sender
{
    sender.textColor = [UIColor colorWithHex:0x000000];
}

- (void)setDateStyleBeyondTodayInThisMonth:(UILabel *)sender
{
    sender.textColor = [UIColor colorWithHex:0xb9bcbe];
    self.enabled = NO;
}

- (void)calendarDateBlockTap:(UITapGestureRecognizer *)sender
{
    NSInteger day = [self.dayLabel.text integerValue];
    NSInteger firstDay  = [TYDCalendarAssistor firstWeekdayInThisMonth:self.date];
    NSInteger dateBlockSelectedIndex = firstDay + day - 1;
    
    if([self.delegate respondsToSelector:@selector(calendarDateBlockSelected:)])
    {
        [self.delegate calendarDateBlockSelected:self];
    }
    
    if([self.delegate respondsToSelector:@selector(dateBlockSelectedWithDate:andIndex:withDay:)])
    {
        [self.delegate dateBlockSelectedWithDate:self.date andIndex:dateBlockSelectedIndex withDay:day];
    }
}

@end
