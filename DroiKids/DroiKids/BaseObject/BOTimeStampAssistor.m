//
//  BOTimeStampAssistor.m
//

#define sDateFormatSeparatorSign    @"-"
//#define sLocalTimeZoneName          @"Asia/Shanghai"

#import "BOTimeStampAssistor.h"

@implementation BOTimeStampAssistor

+ (NSTimeInterval)getCurrentTime
{
    //CoordinatedUniversalTime:UTC 世界标准时间
    NSDate *nowUTC = [NSDate date];
    return [nowUTC timeIntervalSince1970];
}

+ (NSString *)getCurrentTimeString
{
    NSDateFormatter *dateFormatter = [NSDateFormatter new];
    [dateFormatter setDateFormat:@"yyyy-M-d HH:mm:ss"];//输出格式为：2010-10-27 20:22:13
    NSString *currentTimeStr = [dateFormatter stringFromDate:[NSDate date]];
    return currentTimeStr;
}

+ (NSString *)getCurrentYearString
{
    NSDateFormatter *dateFormatter = [NSDateFormatter new];
    [dateFormatter setDateFormat:@"yyyy"];//输出格式为：2010
    NSString *currentYearStr = [dateFormatter stringFromDate:[NSDate date]];
    return currentYearStr;
}

+ (NSString *)getTimeStringWithTimeStamp:(NSTimeInterval)time
{
    NSDateFormatter *dateFormatter = [NSDateFormatter new];
    dateFormatter.dateFormat = @"yyyy-M-d HH:mm";
    return [dateFormatter stringFromDate:[NSDate dateWithTimeIntervalSince1970:time]];
}

+ (NSString *)getYearStringWithTimeStamp:(NSTimeInterval)time
{
    NSDateFormatter *dateFormatter = [NSDateFormatter new];
    dateFormatter.dateFormat = @"yyyy";
    return [dateFormatter stringFromDate:[NSDate dateWithTimeIntervalSince1970:time]];
}

+ (NSString *)getMonthStringWithTimeStamp:(NSTimeInterval)time
{
    NSDateFormatter *dateFormatter = [NSDateFormatter new];
    dateFormatter.dateFormat = @"M";
    return [dateFormatter stringFromDate:[NSDate dateWithTimeIntervalSince1970:time]];
}

+ (NSString *)getDayStringWithTimeStamp:(NSTimeInterval)time
{
    NSDateFormatter *dateFormatter = [NSDateFormatter new];
    dateFormatter.dateFormat = @"d";
    return [dateFormatter stringFromDate:[NSDate dateWithTimeIntervalSince1970:time]];
}

+ (NSString *)getDateStringWithTimeStamp:(NSTimeInterval)time
{
    NSDateFormatter *dateFormatter = [NSDateFormatter new];
    dateFormatter.dateFormat = @"yyyy-MM-dd";
    
    return [dateFormatter stringFromDate:[NSDate dateWithTimeIntervalSince1970:time]];
}

+ (NSTimeInterval)getTimeStampWithDateString:(NSString *)time;
{
    NSDateFormatter *dateFormatter = [NSDateFormatter new];
    dateFormatter.dateFormat = @"yyyy-MM-dd";
    return [[dateFormatter dateFromString:time] timeIntervalSince1970];
}

+ (NSString *)getHourStringWithTimeStamp:(NSTimeInterval)time sinceDate:(NSDate *)date;
{
    NSDateFormatter *dateFormatter = [NSDateFormatter new];
    dateFormatter.dateFormat = @"HH:mm";
    return [dateFormatter stringFromDate:[NSDate dateWithTimeInterval:time sinceDate:date]];
}

+ (NSString *)getHourStringWithTimeStamp:(NSTimeInterval)time
{
    NSDateFormatter *dateFormatter = [NSDateFormatter new];
    dateFormatter.dateFormat = @"HH:mm";
    return [dateFormatter stringFromDate:[NSDate dateWithTimeIntervalSince1970:time]];
}

+ (NSTimeInterval)getTimeStampWithHourString:(NSString *)time;
{
    NSInteger hour = [[[time componentsSeparatedByString:@":"] firstObject] integerValue];
    NSInteger minute = [[[time componentsSeparatedByString:@":"] lastObject] integerValue];
    NSTimeInterval timeInterval = [self timeStampOfDayBeginningWithTimerStamp:[self getCurrentTime]];
    return timeInterval + hour * 3600 + minute * 60;
}

+ (NSString *)getImageTimeStringWithTimeStamp
{
    NSDateFormatter *dateFormatter = [NSDateFormatter new];
    dateFormatter.dateFormat = @"yyyy-M-d HH:mm:ss";
    NSInteger value = arc4random() % 10000;
    NSString *time = [dateFormatter stringFromDate:[NSDate date]];
    return [NSString stringWithFormat:@"%@%ld", time, (long)value ];
}

+ (NSString *)getTimeStringWithTimeStamp:(NSTimeInterval)time
                               dateStyle:(BOTimeStampStringFormatDateStyle)dateStyle
                               timeStyle:(BOTimeStampStringFormatTimeStyle)timeStyle
{
    NSString *dateFormatStr = nil;
    NSString *timeFormatStr = nil;
    NSString *formatStr = nil;
    switch(dateStyle)
    {
        case BOTimeStampStringFormatStyleDate:
            dateFormatStr = @"yyyy-M-d";
            break;
        case BOTimeStampStringFormatStyleDateShort:
            dateFormatStr = @"M-d";
            break;
        case BOTimeStampStringFormatStyleDateShort1:
            dateFormatStr = @"M.d";
            break;
        case BOTimeStampStringFormatStyleDateC:
            dateFormatStr = @"yyyy年M月d日";
            break;
        case BOTimeStampStringFormatStyleDateCM:
            dateFormatStr = @"yyyy年M月";
            break;
        case BOTimeStampStringFormatStyleDateShortC1:
            dateFormatStr = @"M月d日";
            break;
        case BOTimeStampStringFormatStyleDateShortC2:
            dateFormatStr = @"M月d";
            break;
        case BOTimeStampStringFormatStyleDateNone:
        default:
            break;
    }
    switch(timeStyle)
    {
        case BOTimeStampStringFormatStyleTime:
            timeFormatStr = @"HH:mm:ss";
            break;
        case BOTimeStampStringFormatStyleTimeShort:
            timeFormatStr = @"HH:mm";
            break;
        case BOTimeStampStringFormatStyleTimeNone:
        default:
            break;
    }
    if(dateFormatStr)
    {
        if(timeFormatStr)
        {
            formatStr = [NSString stringWithFormat:@"%@ %@", dateFormatStr, timeFormatStr];
        }
        else
        {
            formatStr = dateFormatStr;
        }
    }
    else
    {
        if(timeFormatStr)
        {
            formatStr = timeFormatStr;
        }
        else
        {
            formatStr = @"yyyy-M-d HH:mm:ss";
        }
    }
    
    NSDateFormatter *dateFormatter = [NSDateFormatter new];
    dateFormatter.dateFormat = formatStr;
    return [dateFormatter stringFromDate:[NSDate dateWithTimeIntervalSince1970:time]];
}

+ (NSTimeInterval)getTimeStampWithYear:(int)year month:(int)month day:(int)day
{
    NSString *timeStr = [NSString stringWithFormat:@"%d-%d-%d", year, month, day];
    NSDateFormatter *formatter = [NSDateFormatter new];
    //[formatter setDateStyle:NSDateFormatterMediumStyle];
    //[formatter setTimeStyle:NSDateFormatterShortStyle];
    [formatter setDateFormat:@"yyyy-M-d"];
    //[formatter setDateFormat:@"YYYY-MM-dd HH:mm:ss"];
    [formatter setTimeZone:[NSTimeZone localTimeZone]];
    
    NSDate *date = [formatter dateFromString:timeStr];
    return [date timeIntervalSince1970];
}

+ (NSInteger)getAgeWithTimeStamp:(NSTimeInterval)timeStamp
{
    NSTimeInterval currentTime = [self getCurrentTime];
    NSInteger age = 0;
    
    if(timeStamp < currentTime)
    {
        NSString *dateString1 = [self getDateStringWithTimeStamp:currentTime];
        NSString *dateString2 = [self getDateStringWithTimeStamp:timeStamp];
        
        NSArray *dateStringComponents1 = [dateString1 componentsSeparatedByString:sDateFormatSeparatorSign];
        NSArray *dateStringComponents2 = [dateString2 componentsSeparatedByString:sDateFormatSeparatorSign];
        int year1 = [dateStringComponents1[0] intValue];
        int month1 = [dateStringComponents1[1] intValue];
        int day1 = [dateStringComponents1[2] intValue];
        int year2 = [dateStringComponents2[0] intValue];
        int month2 = [dateStringComponents2[1] intValue];
        int day2 = [dateStringComponents2[2] intValue];
        
        age = year1 - year2;
        if(month1 < month2 || (month1 >= month2 && day1 < day2))
        {
            age--;
        }
    }
    return age;
}

+ (int)daysInYear:(int)year month:(int)month
{
    int days = 0;
    switch(month)
    {
        case 2:
            days = ((year % 4 == 0 && year % 100 != 0) || (year % 400 == 0)) ? 29 : 28;
            break;
        case 4: case 6: case 9: case 11:
            days = 30;
            break;
        case 1: case 3: case 5: case 7: case 8: case 10: case 12:
            days = 31;
            break;
    }
    
    return days;
}

+ (int)daysPerMonthWithTimeStamp:(NSTimeInterval)time
{
    NSDateFormatter *dateFormatter = [NSDateFormatter new];
    dateFormatter.dateFormat = @"yyyy-M";
    NSString *yearMonthString = [dateFormatter stringFromDate:[NSDate dateWithTimeIntervalSince1970:time]];
    NSArray *dateStringComponents = [yearMonthString componentsSeparatedByString:sDateFormatSeparatorSign];
    int year = [dateStringComponents[0] intValue];
    int month = [dateStringComponents[1] intValue];
    
    return [self daysInYear:year month:month];
}


#pragma mark - Weekday
//星期几
+ (int)getWeekdayWithYear:(uint)year month:(uint)month day:(uint)day
{
    //结果:0-星期日，1-星期一，2-星期二，3-星期三，4-星期四，5-星期五，6-星期六
    if(month == 1 || month == 2)//判断month是否为1或2
    {
        year--;
        month += 12;
    }
    int c = year / 100;//世纪
    int y = year - c * 100;
    int week = (c / 4) - 2 * c + (y + y / 4) + (13 * (month + 1) / 5) + day - 1;
    if(week < 0)
    {
        week += (week / 7 * 7 + 7);
    }
    week %= 7;
    return week;
}

//星期天为第一天
+ (NSInteger)weekdayWithTimeStamp:(NSTimeInterval)time
{
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *weekdayComponents = [calendar components:NSCalendarUnitWeekday fromDate:[NSDate dateWithTimeIntervalSince1970:time]];
    return [weekdayComponents weekday];
}

+ (NSInteger)weekdayOfToday
{
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *weekdayComponents = [calendar components:NSCalendarUnitWeekday fromDate:[NSDate date]];
    return [weekdayComponents weekday];
}

#pragma mark - DayBeginning TimeStamp

+ (NSTimeInterval)timeStampOfDayBeginningForToday
{
    return [self timeStampOfDayBeginningWithTimerStamp:[self getCurrentTime]];
}

+ (NSTimeInterval)timeStampOfDayBeginningWithTimerStamp:(NSTimeInterval)time
{
    NSDateFormatter *dateFormatter = [NSDateFormatter new];
    dateFormatter.dateFormat = @"yyyy-MM-dd";
    NSString *dateTimeStr = [dateFormatter stringFromDate:[NSDate dateWithTimeIntervalSince1970:time]];
    [dateFormatter setTimeZone:[NSTimeZone localTimeZone]];
    return [[dateFormatter dateFromString:dateTimeStr] timeIntervalSince1970];
}

//当月第一天时间起始
#pragma mark - Monthly TimeStamp

+ (NSTimeInterval)timeStampOfMonthBeginningWithTimerStamp:(NSTimeInterval)time
{
    NSDateFormatter *dateFormatter = [NSDateFormatter new];
    dateFormatter.timeZone = [NSTimeZone localTimeZone];
    dateFormatter.dateFormat = @"yyyy-M";
    NSString *dateString = [dateFormatter stringFromDate:[NSDate dateWithTimeIntervalSince1970:time]];
    dateString = [dateString stringByAppendingFormat:@"%@%d", sDateFormatSeparatorSign, 1];
    dateFormatter.dateFormat = @"yyyy-MM-dd";
    return [[dateFormatter dateFromString:dateString] timeIntervalSince1970];
}

//当月最后一天时间末尾
+ (NSTimeInterval)timeStampOfMonthEndWithTimerStamp:(NSTimeInterval)time
{
    return [self timeStampOfMonthBeginningWithTimerStamp:time] + nTimeIntervalSecondsPerDay * [self daysPerMonthWithTimeStamp:time] - 1;
}

#pragma mark - Weekly TimeStamp

+ (NSTimeInterval)timeStampOfWeekBeginningWithTimerStamp:(NSTimeInterval)time
{
    NSUInteger weekday = [self weekdayWithTimeStamp:time];
    if(weekday == 1)//星期天
    {
        weekday = 8;
    }
    
    return [self timeStampOfDayBeginningWithTimerStamp:time - nTimeIntervalSecondsPerDay * (weekday - 2)];
}

+ (NSTimeInterval)timeStampOfWeekEndWithTimerStamp:(NSTimeInterval)time
{
    NSUInteger weekday = [self weekdayWithTimeStamp:time];
    if(weekday == 1)//星期天
    {
        weekday = 8;
    }
    
    return [self timeStampOfDayBeginningWithTimerStamp:time + nTimeIntervalSecondsPerDay * (8 - weekday)] + nTimeIntervalSecondsPerDay - 1;
}

#pragma mark - Exchange

+ (NSString *)timeStampToTimeString:(NSTimeInterval)time
{
    NSDateFormatter *dateFormatter = [NSDateFormatter new];
    dateFormatter.dateFormat = @"yyyyMMddHHmm";
    
    NSString *timeString = [dateFormatter stringFromDate:[NSDate dateWithTimeIntervalSince1970:time]];
    timeString = [timeString stringByReplacingOccurrencesOfString:@":" withString:@""];//针对越狱版iPhone5输出的“2014123012:20”
    return timeString;
}

+ (NSTimeInterval)timeStringToTimeStamp:(NSString *)timeString
{
    NSDateFormatter *dateFormatter = [NSDateFormatter new];
    dateFormatter.dateFormat = @"yyyyMMddHHmm";
    return [[dateFormatter dateFromString:timeString] timeIntervalSince1970];
}

#pragma mark - TimeAssistorFunc

+ (NSTimeInterval)localTimeStampWithString:(NSString *)timeString
{
    NSDateFormatter *dateFormatter = [NSDateFormatter new];
    dateFormatter.dateFormat = @"yyyy-MM-dd HH:mm";
    return [[dateFormatter dateFromString:timeString] timeIntervalSince1970];
}

+ (NSString *)localStringWithTimeStamp:(NSTimeInterval)time
{
    NSDateFormatter *dateFormatter = [NSDateFormatter new];
    dateFormatter.dateFormat = @"yyyyMMdd";
    return [dateFormatter stringFromDate:[NSDate dateWithTimeIntervalSince1970:time]];
}

+ (NSString *)timeStringWithDate:(NSDate *)date
{
    NSDateFormatter *dateFormatter = [NSDateFormatter new];
    dateFormatter.dateFormat = @"yyyyMMddHHmmss";
    NSString *timeString = [dateFormatter stringFromDate:date];
    return timeString;
}

@end
