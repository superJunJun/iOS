//
//  TYDHistoricalTrackCalendarView.m
//  DroiKids
//
//  Created by caiyajie on 15/8/19.
//  Copyright (c) 2015年 superjunjun. All rights reserved.
//

#import "TYDHistoricalTrackCalendarView.h"
#import "TYDHistoricalTrackCalendar.h"
#import "TYDCalendarAssistor.h"

#define nCalendarWidth              self.width
#define nWeekDayTitleBarHeight      40//22
#define nBelowArrowViewHeight       25 //19 //32
#define nDateBlockHeight            36//26//48
#define nDateBlockRowMax            6
#define nDateBlockWidth             (nCalendarWidth / 7.0)

@interface TYDHistoricalTrackCalendarView()<UIScrollViewDelegate>

@property (strong, nonatomic) UIScrollView *scrollView;
@property (strong, nonatomic) UIView *belowArrowView;

@property (strong, nonatomic) UIView *weekDayTitleBar;
@property (nonatomic, strong) NSDate *date;
@property (strong, nonatomic) NSArray *calendarViewsArr;
@property (strong, nonatomic) NSArray *weekDayLabelArray;
@property (strong, nonatomic) UIButton *belowButton;
@property (nonatomic) NSInteger selectedInterval;
@property (strong, nonatomic) UILabel *selectMonthLabel;

@end

@implementation TYDHistoricalTrackCalendarView

- (instancetype)initWithFrame:(CGRect)frame
{
    if(self = [super initWithFrame:frame])
    {
        [self belowArrowViewLoad];
        [self weekDayTitleBarLoad];
        [self scrollViewLoad];
        self.date = [NSDate date];
        self.selectedInterval = -1;
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

- (void)belowArrowViewLoad
{
    CGRect frame = CGRectMake(0, 0, self.width, nBelowArrowViewHeight);
    UIView *belowArrowView = [[UIView alloc] initWithFrame:frame];
    belowArrowView.backgroundColor = [UIColor colorWithHex:0xffffff];
    UITapGestureRecognizer *tapGr = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(belowArrowViewAction:)];
    [belowArrowView addGestureRecognizer:tapGr];
    belowArrowView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
    [self addSubview:belowArrowView];
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.size = CGSizeMake(50, 25);
    [button addTarget:self action:@selector(belowArrowViewAction:) forControlEvents:UIControlEventTouchUpInside];
    [button setImage:[UIImage imageNamed:@"main_calendarArrow"] forState:UIControlStateNormal];
    [button setImage:[UIImage imageNamed:@"main_calendarArrowH"] forState:UIControlStateSelected];
    button.center = belowArrowView.innerCenter;
    button.bottom = belowArrowView.bottom;
    [belowArrowView addSubview:button];
    
    UILabel *selectMonthLabel = [UILabel new];
    selectMonthLabel.backgroundColor = [UIColor clearColor];
    NSInteger nowMonth = [TYDCalendarAssistor month:[NSDate date]];
    selectMonthLabel.text = [NSString stringWithFormat:@"%d月",nowMonth];
//    selectMonthLabel.text = @"本月";
    [selectMonthLabel sizeToFit];
    selectMonthLabel.center = belowArrowView.innerCenter;
    selectMonthLabel.bottom = belowArrowView.height;
    selectMonthLabel.left = 18;
    selectMonthLabel.font = [UIFont systemFontOfSize:12];
    selectMonthLabel.textColor = [UIColor colorWithHex:0x000000];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(selectMonthLabelTapAction:)];
    [selectMonthLabel addGestureRecognizer:tap];
    selectMonthLabel.userInteractionEnabled = YES;
    [belowArrowView addSubview:selectMonthLabel];
    
    self.selectMonthLabel = selectMonthLabel;
    self.selectMonthLabel.hidden = YES;
    self.belowButton = button;
    self.belowArrowView = belowArrowView;
}

- (void)weekDayTitleBarLoad
{
    CGRect frame = CGRectMake(0, nBelowArrowViewHeight, nCalendarWidth, nWeekDayTitleBarHeight);
    UIView *weekDayTitleBar = [[UIView alloc] initWithFrame:frame];
    weekDayTitleBar.backgroundColor = [UIColor colorWithHex:0xffffff];
    weekDayTitleBar.userInteractionEnabled = YES;
    weekDayTitleBar.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
    [self addSubview:weekDayTitleBar];
    self.weekDayTitleBar = weekDayTitleBar;
   
    NSArray *weekDayTitles = @[@"日", @"一", @"二", @"三", @"四", @"五", @"六"];
    UIFont *weekDayTitleFont = [UIFont fontWithName:@"Arial" size:18];
    UIColor *textColor = [UIColor colorWithHex:0x0];
    NSUInteger dayCountPerWeek = 7;
    frame.size.width /= dayCountPerWeek;
    frame.origin.y = 0;
    NSMutableArray *weekDayLabelArray = [NSMutableArray new];
    for(int i = 0; i < dayCountPerWeek; i++)
    {
        UILabel *weekDayTitleLabel = [[UILabel alloc] initWithFrame:frame];
        weekDayTitleLabel.backgroundColor = [UIColor clearColor];
        weekDayTitleLabel.font = weekDayTitleFont;
        weekDayTitleLabel.text = weekDayTitles[i];
        weekDayTitleLabel.textColor = textColor;
        weekDayTitleLabel.textAlignment = NSTextAlignmentCenter;
        weekDayTitleLabel.userInteractionEnabled = YES;
        UITapGestureRecognizer *tapGr = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(weekDayLabelTapEvent:)];
        [weekDayTitleLabel addGestureRecognizer:tapGr];
        [weekDayTitleBar addSubview:weekDayTitleLabel];
        [weekDayLabelArray addObject:weekDayTitleLabel];
        frame.origin.x += frame.size.width;
    }
    self.weekDayLabelArray = weekDayLabelArray;
}

- (void)scrollViewLoad
{
    CGRect frame = self.bounds;
    frame.size.height = nDateBlockHeight * nDateBlockRowMax;
    frame.origin.y = self.height - frame.size.height;
    UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:frame];
    scrollView.backgroundColor = [UIColor colorWithHex:0xfcfcfc];
    scrollView.delegate = self;
    scrollView.contentSize = frame.size;
    scrollView.pagingEnabled = YES;
    scrollView.showsHorizontalScrollIndicator = NO;
    scrollView.showsVerticalScrollIndicator = NO;
    scrollView.scrollEnabled = YES;
    scrollView.bounces = NO;
    scrollView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
    [self addSubview:scrollView];
    self.scrollView = scrollView;
    self.date = [NSDate date];
    [self createMyCalendarWithDate:self.date];
    
    self.belowButton.selected = NO;
    self.scrollView.hidden = YES;
}

- (void)createMyCalendarWithDate:(NSDate * )date
{
    NSDate *lastMonthDate = [TYDCalendarAssistor lastMonth:date];
    NSArray *dateArry = @[lastMonthDate, date];
    NSMutableArray *calendarViewArr = [NSMutableArray new];
    NSInteger todayNumber =  [TYDCalendarAssistor day:[NSDate date]];
    for(int j = 0; j < 2; j++)
    {
        NSDate *newDate = dateArry[j];
        CGFloat orginx = j * nCalendarWidth;
        CGSize blockSize = CGSizeMake(nDateBlockWidth, nDateBlockHeight);
        CGRect frame = CGRectMake(orginx, 0, nCalendarWidth, nDateBlockHeight * nDateBlockRowMax);
        TYDHistoricalTrackCalendar *calendar = [[TYDHistoricalTrackCalendar alloc]initWithDate:newDate WithFrame:frame withBlockSize:blockSize];
        calendar.delegate = self;
        calendar.date = newDate;
        if(self.selectedInterval >= 0 )
        {
            if(todayNumber >  self.selectedInterval)
            {
                calendar.selectedDate = [NSDate date];
            }
            else
            {
                calendar.selectedDate = [TYDCalendarAssistor lastMonth:[NSDate date]];
            }
            calendar.selectedInterval = self.selectedInterval;
        }
        [calendarViewArr addObject:calendar];
        [self.scrollView addSubview:calendar];
    }
    self.calendarViewsArr = calendarViewArr;
    self.scrollView.contentSize = CGSizeMake(nCalendarWidth * 2, nDateBlockHeight * nDateBlockRowMax);
    self.scrollView.contentOffset = CGPointMake(nCalendarWidth, 0);
    if(self.selectedInterval >= todayNumber)
    {
        self.scrollView.contentOffset = CGPointZero;
    }
}

- (void)calendarDateBlockSelected:(TYDHistoricalTrackCalendar *)calendar
{
    for(TYDHistoricalTrackCalendar * normolCalendar in self.calendarViewsArr)
    {
        normolCalendar.selectedBlock.selected = NO;
    }
    calendar.selectedBlock.selected = YES;
}

#pragma mark - TouchEvent

- (void)belowArrowViewAction:(UIGestureRecognizer *)sender
{
    NSLog(@"belowArrowViewAction");
    if([self.delegate respondsToSelector:@selector(historicalTrackCalendarViewBelowViewAction:)])
    {
        [self.delegate historicalTrackCalendarViewBelowViewAction:self];
    }
}

- (void)openCalendar
{
    self.scrollView.hidden = NO;
    self.scrollView.top = self.weekDayTitleBar.bottom;
    
    [UIView animateWithDuration:0.25
                          delay:0
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         self.scrollView.bottom = self.height;
                         self.weekDayTitleBar.bottom = self.scrollView.top;
                         self.belowArrowView.bottom = self.weekDayTitleBar.top;
                         self.belowButton.selected = YES;
                         self.selectMonthLabel.hidden = NO;
                         [self.selectMonthLabel sizeToFit];
                         self.selectMonthLabel.bottom = self.belowArrowView.height;
                     }
                     completion:^(BOOL finished){
                     }];

}

- (void)closeCalendar
{
    self.selectMonthLabel.hidden = YES;
    [UIView animateWithDuration:0.25
                          delay:0
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         self.scrollView.top = self.height;
                         self.weekDayTitleBar.bottom = self.height;
                         self.belowArrowView.bottom = self.weekDayTitleBar.top;
                         self.belowButton.selected = NO;
                     }
                     completion:^(BOOL finished){
                         self.scrollView.hidden = YES;
                     }];
}

- (void)weekDayLabelTapEvent:(UITapGestureRecognizer *)sender
{
    NSInteger firstDay = [TYDCalendarAssistor firstWeekdayInThisMonth:self.date];
    NSInteger todayNumber =  [TYDCalendarAssistor day:[NSDate date]];
    NSInteger index = (todayNumber - 1 + firstDay) % 7;
    
    UILabel *label  = (UILabel *)sender.view;
    NSInteger touchIndex =  [self.weekDayLabelArray indexOfObject:label];
    if(touchIndex > index)
    {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:@"还未到来！" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil];
        [alertView show];
    }
    else
    {
        for(UILabel *weekDayLabel in self.weekDayLabelArray)
        {
            weekDayLabel.textColor = [UIColor colorWithHex:0x0];
        }
        label.textColor = [UIColor colorWithHex:0x6cbb52];

        NSInteger interval = index - touchIndex;
        self.selectedInterval = interval;
        
        if(todayNumber > interval)
        {
            for(TYDHistoricalTrackCalendar *calendar in self.calendarViewsArr)
            {
                calendar.selectedBlock.selected = NO;
                calendar.selectedDate = [NSDate date];
                calendar.selectedInterval = self.selectedInterval;
            }

            [self.scrollView setContentOffset:CGPointMake(nCalendarWidth, 0) animated:YES];
//            self.selectMonthLabel.text = @"本月";
            NSInteger nowMonth = [TYDCalendarAssistor month:[NSDate date]];
            self.selectMonthLabel.text = [NSString stringWithFormat:@"%d月",nowMonth];
            [self.selectMonthLabel sizeToFit];
            self.selectMonthLabel.bottom = self.belowArrowView.height;
        }
        else
        {
            for(TYDHistoricalTrackCalendar *calendar in self.calendarViewsArr)
            {
                calendar.selectedBlock.selected = NO;
                calendar.selectedDate = [TYDCalendarAssistor lastMonth:[NSDate date]];
                calendar.selectedInterval = self.selectedInterval;
            }
            [self.scrollView setContentOffset:CGPointZero animated:YES];
            NSInteger lastMonth = [TYDCalendarAssistor month:[TYDCalendarAssistor lastMonth:[NSDate date]]];
            self.selectMonthLabel.text = [NSString stringWithFormat:@"%d月",lastMonth];
//            self.selectMonthLabel.text = @"上月";
            [self.selectMonthLabel sizeToFit];
            self.selectMonthLabel.bottom = self.belowArrowView.height;
        }
        
        if([self.delegate respondsToSelector:@selector(weekdayTitleBarSelectedWithIntervalToToday:)])
        {
            [self.delegate weekdayTitleBarSelectedWithIntervalToToday:interval];
        }
    }
}

- (void)selectMonthLabelTapAction:(UITapGestureRecognizer *)sender
{
//    UILabel *label = (UILabel *)sender.view;
//    if([label.text isEqualToString:@"上月"])
//    {
//        [self.scrollView setContentOffset:CGPointZero animated:YES];
//        label.text = @"本月";
//    }
//    else
//    {
//        label.text = @"上月";
//        [self.scrollView setContentOffset:CGPointMake(nCalendarWidth, 0) animated:YES];
//    }
}

- (void)dateBlockSelectedWithDate:(NSDate *)date andIndex:(NSInteger)index withDay:(NSInteger)day withCalendar:(TYDHistoricalTrackCalendar *)calendar
{
    for(UILabel *weekDayLabel in self.weekDayLabelArray)
    {
        weekDayLabel.textColor = [UIColor colorWithHex:0x0];
    }
    if([TYDCalendarAssistor month:date] == [TYDCalendarAssistor month:[NSDate date]]
       && [TYDCalendarAssistor year:date] == [TYDCalendarAssistor year:[NSDate date]])
    {
        NSInteger firstDay = [TYDCalendarAssistor firstWeekdayInThisMonth:date];
        NSInteger todayNumber = [TYDCalendarAssistor day:[NSDate date]];
        NSInteger todayIndex = todayNumber + firstDay - 1;
        
        NSInteger beforeTodayNumber = todayIndex % 7;
        if(todayIndex - index <= beforeTodayNumber)
        {
           NSInteger selectIndex = beforeTodayNumber - todayIndex + index;
           UILabel *label = self.weekDayLabelArray[selectIndex];
           label.textColor = [UIColor colorWithHex:0x6cbb52];
        }
    }
    else
    {
        NSInteger firstDay = [TYDCalendarAssistor firstWeekdayInThisMonth:[NSDate date]];
        NSInteger todayNumber = [TYDCalendarAssistor day:[NSDate date]];
        NSInteger todayIndex = todayNumber + firstDay - 1;
        NSInteger lastMonthDays = [TYDCalendarAssistor totaldaysInMonth:date];
        if(day > (lastMonthDays - firstDay) && todayIndex < 7)
        {
            NSInteger selectIndex = day - lastMonthDays + firstDay - 1;
            UILabel *label = self.weekDayLabelArray[selectIndex];
            label.textColor = [UIColor colorWithHex:0x6cbb52];
        }
    }
    
    if([self.delegate respondsToSelector:@selector(dateBlockSelectedIndex:withDate:withDay:)])
    {
        [self.delegate dateBlockSelectedIndex:index withDate:date withDay:day];
    }
}


- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    NSInteger offsetRadio = scrollView.contentOffset.x / scrollView.width;
    if(offsetRadio == 1)
    {
//        self.selectMonthLabel.text = @"本月";
        NSInteger nowMonth = [TYDCalendarAssistor month:[NSDate date]];
        self.selectMonthLabel.text = [NSString stringWithFormat:@"%d月",nowMonth];
    }
    else
    {
        NSInteger lastMonth = [TYDCalendarAssistor month:[TYDCalendarAssistor lastMonth:[NSDate date]]];
        self.selectMonthLabel.text = [NSString stringWithFormat:@"%d月",lastMonth];
//         self.selectMonthLabel.text = @"上月";
    }
    [self.selectMonthLabel sizeToFit];
    self.selectMonthLabel.bottom = self.belowArrowView.height;
}

@end
