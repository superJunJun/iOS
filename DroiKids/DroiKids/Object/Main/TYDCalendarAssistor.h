//
//  TYDCalendarAssistor.h
//  DroiKids
//
//  Created by caiyajie on 15/8/25.
//  Copyright (c) 2015年 TYDTech. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TYDCalendarAssistor : NSObject

+ (NSInteger)day:(NSDate *)date;
+ (NSInteger)firstWeekdayInThisMonth:(NSDate *)date;
+ (NSInteger)month:(NSDate *)date;
+ (NSInteger)year:(NSDate *)date;
+ (NSDate *)lastMonth:(NSDate *)date;
+ (NSDate*)nextMonth:(NSDate *)date;
+ (NSInteger)totaldaysInMonth:(NSDate *)date;

@end
