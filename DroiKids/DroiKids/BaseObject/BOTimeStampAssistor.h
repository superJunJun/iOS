//
//  BOTimeStampAssistor.h
//

#import <Foundation/Foundation.h>

#define nBasicTimerInterval             1       //1 sec
#define nTimeIntervalSecondsPerDay      86400   //(24 * 60 * 60)
#define nTimeIntervalSecondsPerHalfHour 1800    //30*60

typedef NS_ENUM(NSInteger, BOTimeStampStringFormatDateStyle)
{
    BOTimeStampStringFormatStyleDateNone = 0,
    BOTimeStampStringFormatStyleDate,           //@"yyyy-M-d"
    BOTimeStampStringFormatStyleDateShort,      //@"M-d"
    BOTimeStampStringFormatStyleDateShort1,      //@"M.d"
    BOTimeStampStringFormatStyleDateC,          //@"yyyy年M月d日"
    BOTimeStampStringFormatStyleDateCM,         //@"yyyy年M月"
    BOTimeStampStringFormatStyleDateShortC1,    //@"M月d日"
    BOTimeStampStringFormatStyleDateShortC2,    //@"M月d"
};

typedef NS_ENUM(NSInteger, BOTimeStampStringFormatTimeStyle)
{
    BOTimeStampStringFormatStyleTimeNone = 0,
    BOTimeStampStringFormatStyleTime,           //@"HH:mm:ss"
    BOTimeStampStringFormatStyleTimeShort,      //@"HH:mm"
};

@interface BOTimeStampAssistor : NSObject

+ (NSTimeInterval)getCurrentTime;
+ (NSString *)getCurrentTimeString;
+ (NSString *)getCurrentYearString;
+ (NSString *)getYearStringWithTimeStamp:(NSTimeInterval)time;
+ (NSString *)getMonthStringWithTimeStamp:(NSTimeInterval)time;
+ (NSString *)getDayStringWithTimeStamp:(NSTimeInterval)time;
+ (NSString *)getTimeStringWithTimeStamp:(NSTimeInterval)time;
+ (NSString *)getDateStringWithTimeStamp:(NSTimeInterval)time;
+ (NSTimeInterval)getTimeStampWithDateString:(NSString *)time;

+ (NSString *)getHourStringWithTimeStamp:(NSTimeInterval)time;
+ (NSTimeInterval)getTimeStampWithHourString:(NSString *)time;

+ (NSString *)getHourStringWithTimeStamp:(NSTimeInterval)time sinceDate:(NSDate *)date;
+ (NSString *)timeStringWithDate:(NSDate *)date;
+ (NSString *)getImageTimeStringWithTimeStamp;
+ (NSTimeInterval)getTimeStampWithYear:(int)year month:(int)month day:(int)day;
+ (NSInteger)getAgeWithTimeStamp:(NSTimeInterval)timeStamp;


//星期
+ (NSInteger)weekdayWithTimeStamp:(NSTimeInterval)time;
+ (NSInteger)weekdayOfToday;

+ (int)daysInYear:(int)year month:(int)month;
+ (int)daysPerMonthWithTimeStamp:(NSTimeInterval)time;

+ (NSTimeInterval)timeStampOfDayBeginningForToday;
+ (NSTimeInterval)timeStampOfDayBeginningWithTimerStamp:(NSTimeInterval)time;
+ (NSString *)getTimeStringWithTimeStamp:(NSTimeInterval)time
                               dateStyle:(BOTimeStampStringFormatDateStyle)dateStyle
                               timeStyle:(BOTimeStampStringFormatTimeStyle)timeStyle;

+ (NSTimeInterval)timeStampOfWeekBeginningWithTimerStamp:(NSTimeInterval)time;
+ (NSTimeInterval)timeStampOfWeekEndWithTimerStamp:(NSTimeInterval)time;

+ (NSTimeInterval)timeStampOfMonthBeginningWithTimerStamp:(NSTimeInterval)time;
+ (NSTimeInterval)timeStampOfMonthEndWithTimerStamp:(NSTimeInterval)time;

+ (NSString *)timeStampToTimeString:(NSTimeInterval)time;
+ (NSTimeInterval)timeStringToTimeStamp:(NSString *)timeString;

+ (NSTimeInterval)localTimeStampWithString:(NSString *)timeString;
+ (NSString *)localStringWithTimeStamp:(NSTimeInterval)time;
@end
