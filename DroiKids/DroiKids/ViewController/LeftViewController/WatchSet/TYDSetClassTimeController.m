//
//  TYDSetClassTimeController.m
//  DroiKids
//
//  Created by wangchao on 15/9/7.
//  Copyright (c) 2015年 TYDTech. All rights reserved.
//

#import "TYDSetClassTimeController.h"
#import "TYDTimeBubbleView.h"
#import "TYDWeekTimeBlock.h"
#import "BOBottomPopupView.h"
#import "TYDWatchSetViewController.h"

#define sWeekBubbleTag                  1000

//#define sMorningClassTimeStartBubbleTag            500
//#define sMorningClassTimeStopBubbleTag             501
//#define sAfternoonClassTimeStartBubbleTag          502
//#define sAfternoonClassTimeStopBubbleTag           503

@interface TYDSetClassTimeController () <BOBottomPopupViewDelegate>

@property (strong, nonatomic) TYDTimeBubbleView *selectClassTimeBlock;
@property (strong, nonatomic) BOBottomPopupView *bottomPopView;
@property (strong, nonatomic) UIDatePicker      *datePicker;
@property (strong, nonatomic) NSMutableArray    *weekArray;

//@property (nonatomic) NSUInteger todayBeginningTimeStamp;
//@property (strong, nonatomic) UIView *promptBaseView;
//@property (strong, nonatomic) UIView *promptBgView;
//@property (strong, nonatomic) UIView *promptView;
@property (strong, nonatomic) NSMutableArray *timeButtonArray;


@end

@implementation TYDSetClassTimeController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self localDataInitialize];
    [self navigationBarItemsLoad];
    [self subviewsLoad];
}

- (void)localDataInitialize
{
//    self.todayBeginningTimeStamp = [BOTimeStampAssistor timeStampOfDayBeginningForToday];
    self.timeButtonArray = [NSMutableArray new];
    self.weekArray = [NSMutableArray new];
    if(!self.mStartString)
    {
        self.mStartString = @"08:30";
    }
    if(!self.mEndString)
    {
        self.mEndString = @"11:00";
    }
    if(!self.aStartString)
    {
        self.aStartString = @"14:00";
    }
    if(!self.aEndString)
    {
        self.aEndString = @"16:30";
    }
}

- (void)navigationBarItemsLoad
{
    self.title = @"设置上课时间";
}

- (void)subviewsLoad
{
    [self classTimeViewLoad];
    [self repeatTimeViewLoad];
    [self bottomPopViewLoad];
}

- (void)classTimeViewLoad
{
    UILabel *classTimeTitleLabel = [UILabel new];
    classTimeTitleLabel.backgroundColor = [UIColor clearColor];
    classTimeTitleLabel.font = [UIFont systemFontOfSize:11];
    classTimeTitleLabel.textColor = [UIColor colorWithHex:0xaaaaaa];
    classTimeTitleLabel.text = @"上课时间";
    [classTimeTitleLabel sizeToFit];
    classTimeTitleLabel.left = 17;
    classTimeTitleLabel.yCenter = 14;
    
    [self.baseView addSubview:classTimeTitleLabel];

    UIView *morningCell = [[UIView alloc] initWithFrame:CGRectMake(0, 28, self.view.width, 60)];
    morningCell.backgroundColor = [UIColor whiteColor];
    [self.baseView addSubview:morningCell];

    UILabel *morningCellTitleLabel = [UILabel new];
    morningCellTitleLabel.backgroundColor = [UIColor clearColor];
    morningCellTitleLabel.font = [UIFont systemFontOfSize:14];
    morningCellTitleLabel.textColor = [UIColor colorWithHex:0x000000];
    morningCellTitleLabel.text = @"上午";
    [morningCellTitleLabel sizeToFit];
    morningCellTitleLabel.left = 17;
    morningCellTitleLabel.yCenter = morningCell.innerCenter.y;
    
    [morningCell addSubview:morningCellTitleLabel];
    
    TYDTimeBubbleView *morningStartBubbleView = [[TYDTimeBubbleView alloc] initWithTimeString:self.mStartString timeFont:[UIFont systemFontOfSize:14]];
//    morningStartBubbleView.tag = sMorningClassTimeStartBubbleTag;
    morningStartBubbleView.left = morningCellTitleLabel.right + 35;
    morningStartBubbleView.yCenter = morningCellTitleLabel.yCenter;
    [morningStartBubbleView addTarget:self action:@selector(classTimeTap:) forControlEvents:UIControlEventTouchUpInside];
    [morningCell addSubview:morningStartBubbleView];
    [self.timeButtonArray addObject:morningStartBubbleView];
    
    TYDTimeBubbleView *morningStopBubbleView = [[TYDTimeBubbleView alloc] initWithTimeString:self.mEndString timeFont:[UIFont systemFontOfSize:14]];
//    morningStopBubbleView.tag = sMorningClassTimeStopBubbleTag;
    morningStopBubbleView.left = morningStartBubbleView.left + 120;
    morningStopBubbleView.yCenter = morningStartBubbleView.yCenter;
    [morningStopBubbleView addTarget:self action:@selector(classTimeTap:) forControlEvents:UIControlEventTouchUpInside];
    [morningCell addSubview:morningStopBubbleView];
    [self.timeButtonArray addObject:morningStopBubbleView];
    
    UIView *morningSeparateLine = [UIView new];
    morningSeparateLine.backgroundColor = [UIColor colorWithHex:0xdfdfdf];
    morningSeparateLine.size = CGSizeMake(45, 1);
    morningSeparateLine.center = CGPointMake((morningStopBubbleView.left + morningStartBubbleView.right) / 2, morningCell.innerCenter.y);
    [morningCell addSubview:morningSeparateLine];
    
    UIView *grayLine = [UIView new];
    grayLine.backgroundColor = [UIColor colorWithHex:0xdfdfdf];
    grayLine.size = CGSizeMake(morningCell.width - 17, 0.5);
    grayLine.left = 17;
    grayLine.bottom = morningCell.height;
    [morningCell addSubview:grayLine];
    
    UIView *afternoonCell = [UIView new];
    afternoonCell.backgroundColor = [UIColor whiteColor];
    afternoonCell.size = CGSizeMake(self.view.width, 60);
    afternoonCell.top = morningCell.bottom;
    [self.baseView addSubview:afternoonCell];
    
    UILabel *afternoonTitleLabel = [UILabel new];
    afternoonTitleLabel.backgroundColor = [UIColor clearColor];
    afternoonTitleLabel.font = [UIFont systemFontOfSize:14];
    afternoonTitleLabel.textColor = [UIColor colorWithHex:0x000000];
    afternoonTitleLabel.text = @"下午";
    [afternoonTitleLabel sizeToFit];
    afternoonTitleLabel.left = 17;
    afternoonTitleLabel.yCenter = afternoonCell.innerCenter.y;
    
    [afternoonCell addSubview:afternoonTitleLabel];
    
    TYDTimeBubbleView *afternoonStartBubbleView = [[TYDTimeBubbleView alloc] initWithTimeString:self.aStartString timeFont:[UIFont systemFontOfSize:14]];
//    afternoonStartBubbleView.tag = sAfternoonClassTimeStartBubbleTag;
    afternoonStartBubbleView.left = afternoonTitleLabel.right + 35;
    afternoonStartBubbleView.yCenter = afternoonTitleLabel.yCenter;
    [afternoonStartBubbleView addTarget:self action:@selector(classTimeTap:) forControlEvents:UIControlEventTouchUpInside];
    [afternoonCell addSubview:afternoonStartBubbleView];
    [self.timeButtonArray addObject:afternoonStartBubbleView];
    
    TYDTimeBubbleView *afternoonStopBubbleView = [[TYDTimeBubbleView alloc] initWithTimeString:self.aEndString timeFont:[UIFont systemFontOfSize:14]];
//    afternoonStopBubbleView.tag = sAfternoonClassTimeStopBubbleTag;
    afternoonStopBubbleView.left = afternoonStartBubbleView.left + 120;
    afternoonStopBubbleView.yCenter = afternoonStartBubbleView.yCenter;
    [afternoonStopBubbleView addTarget:self action:@selector(classTimeTap:) forControlEvents:UIControlEventTouchUpInside];
    [afternoonCell addSubview:afternoonStopBubbleView];
    [self.timeButtonArray addObject:afternoonStopBubbleView];
    
    UIView *afternoonSeparateLine = [UIView new];
    afternoonSeparateLine.backgroundColor = [UIColor colorWithHex:0xdfdfdf];
    afternoonSeparateLine.size = CGSizeMake(45, 1);
    afternoonSeparateLine.center = CGPointMake((afternoonStopBubbleView.left + afternoonStartBubbleView.right) / 2, afternoonCell.innerCenter.y);
    [afternoonCell addSubview:afternoonSeparateLine];
    
    self.baseViewBaseHeight = afternoonCell.bottom;
}

- (void)repeatTimeViewLoad
{
    UILabel *weekTimeTitleLabel = [UILabel new];
    weekTimeTitleLabel.backgroundColor = [UIColor clearColor];
    weekTimeTitleLabel.font = [UIFont systemFontOfSize:11];
    weekTimeTitleLabel.textColor = [UIColor colorWithHex:0xaaaaaa];
    weekTimeTitleLabel.text = @"重复";
    [weekTimeTitleLabel sizeToFit];
    weekTimeTitleLabel.left = 17;
    weekTimeTitleLabel.yCenter = self.baseViewBaseHeight + 13.5;
    
    [self.baseView addSubview:weekTimeTitleLabel];
    
    UIView *weekTimeCell = [[UIView alloc] initWithFrame:CGRectMake(0, self.baseViewBaseHeight + 27, self.view.width, 60)];
    weekTimeCell.backgroundColor = [UIColor whiteColor];
    [self.baseView addSubview:weekTimeCell];
    
    UILabel *weekTitleLabel = [UILabel new];
    weekTitleLabel.backgroundColor = [UIColor clearColor];
    weekTitleLabel.font = [UIFont systemFontOfSize:14];
    weekTitleLabel.textColor = [UIColor colorWithHex:0x000000];
    weekTitleLabel.text = @"星期";
    [weekTitleLabel sizeToFit];
    weekTitleLabel.left = 17;
    weekTitleLabel.yCenter = weekTimeCell.innerCenter.y;
    
    [weekTimeCell addSubview:weekTitleLabel];

    NSArray *array = @[@"一", @"二", @"三", @"四", @"五", @"六", @"日"];
    
    for(int i = 0; i < array.count; i++)
    {
        TYDWeekTimeBlock *timeBlock = [[TYDWeekTimeBlock alloc] initWithWeekTimeString:array[i] stringFont:[UIFont systemFontOfSize:14]];
        
        timeBlock.yCenter = weekTimeCell.innerCenter.y;
        timeBlock.left = weekTitleLabel.right + 20 + 9 * (i + 1) + timeBlock.width * i;
        NSInteger selected = [[self.weekString substringWithRange:NSMakeRange(i, 1)] integerValue];
        [self.weekArray addObject:@(selected)];
        timeBlock.selected = selected == 1 ? YES : NO;
        [timeBlock addTarget:self action:@selector(weekTimeBlockTap:) forControlEvents:UIControlEventTouchUpInside];
        timeBlock.tag = sWeekBubbleTag + i;
        [weekTimeCell addSubview:timeBlock];
    }
    
    self.baseViewBaseHeight = weekTimeCell.bottom + 20;
}

- (void)bottomPopViewLoad
{
    UIDatePicker *datePicker = [UIDatePicker new];
    datePicker.backgroundColor = [UIColor colorWithHex:0xefeef0];
    datePicker.datePickerMode = UIDatePickerModeTime;
    
    [datePicker addTarget:self action:@selector(datePickerValueChanged:) forControlEvents:UIControlEventValueChanged];
    
    BOBottomPopupView *bottomPopupView = [[BOBottomPopupView alloc] initWithCustomViews:@[datePicker]];
    bottomPopupView.delegate = self;
    
    [self.view addSubview:bottomPopupView];
    
    self.bottomPopView = bottomPopupView;
    self.datePicker = datePicker;

}

#pragma mark - TouchEvent

- (void)classTimeTap:(UIButton *)sender
{
    [self.bottomPopView bottomPopupViewShowAnimated];
    
    TYDTimeBubbleView *timeBubbleView = (TYDTimeBubbleView *)sender;
    self.selectClassTimeBlock = timeBubbleView;
    timeBubbleView.selected = YES;
    
    NSInteger index = [self.timeButtonArray indexOfObject:timeBubbleView];
    if(index == 0)
    {
        self.datePicker.minimumDate = [self dateFromTimeString:@"07:00"];
        self.datePicker.maximumDate = [self dateFromTimeString:@"10:00"];
    }
    else if (index == 1)
    {
        NSDate *minDate = [self dateFromTimeString:@"10:00"];
        self.datePicker.minimumDate = minDate;
        NSDate *mStartDate = [self dateFromTimeString:self.mStartString];
        NSDate *compareDate = [mStartDate dateByAddingTimeInterval:60*60];
        NSComparisonResult result = [minDate compare:compareDate];
        if(result == NSOrderedAscending)
        {
            self.datePicker.minimumDate = compareDate;
        }
        
        self.datePicker.maximumDate = [self dateFromTimeString:@"12:00"];
    }
    else if (index == 2)
    {
        self.datePicker.minimumDate = [self dateFromTimeString:@"13:00"];
        self.datePicker.maximumDate = [self dateFromTimeString:@"15:00"];
    }
    else if (index == 3)
    {
        NSDate *minDate = [self dateFromTimeString:@"15:30"];
        self.datePicker.minimumDate = minDate;
        NSDate *mStartDate = [self dateFromTimeString:self.aStartString];
        NSDate *compareDate = [mStartDate dateByAddingTimeInterval:60*60];
        NSComparisonResult result = [minDate compare:compareDate];
        if(result == NSOrderedAscending)
        {
            self.datePicker.minimumDate = compareDate;
        }

        self.datePicker.maximumDate = [self dateFromTimeString:@"18:00"];
    }
    
    NSString *dateString = timeBubbleView.classTime;
    NSDateFormatter *dateFormatter = [NSDateFormatter new];
    dateFormatter.dateFormat = @"HH:mm";
    NSDate *date = [dateFormatter dateFromString:dateString];
    self.datePicker.date = date;
}

- (void)weekTimeBlockTap:(UIButton *)sender
{
    TYDWeekTimeBlock *weekTimeBlock = (TYDWeekTimeBlock *)sender;
    weekTimeBlock.selected = !weekTimeBlock.selected;
    NSNumber *selected = weekTimeBlock.selected ? @(1) : @(0);
    [self.weekArray replaceObjectAtIndex:(sender.tag - sWeekBubbleTag) withObject:selected];
}

- (void)datePickerValueChanged:(UIDatePicker *)datePicker
{
    NSDate *birthdayDate = datePicker.date;
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"HH:mm";
    NSString *dateString = [dateFormatter stringFromDate:birthdayDate];
    
    self.selectClassTimeBlock.classTime = dateString;
    NSInteger index = [self.timeButtonArray indexOfObject:self.selectClassTimeBlock];
    
    if(index == 0)
    {
        self.mStartString = dateString;
    }
    else if (index == 1)
    {
        self.mEndString = dateString;
    }
    else if (index == 2)
    {
        self.aStartString = dateString;
    }
    else if (index == 3)
    {
        self.aEndString = dateString;
    }
}

#pragma mark - BOBottomPopupViewDelegate

- (void)bottomPopupViewWillShow:(BOBottomPopupView *)view
{
    
}

- (void)bottomPopupViewDidHidden:(BOBottomPopupView *)view
{
    self.selectClassTimeBlock.selected = NO;
    self.selectClassTimeBlock = nil;
}


- (NSDate *)dateFromTimeString:(NSString *)string
{
    NSDateFormatter *dateFormatter = [NSDateFormatter new];
    dateFormatter.dateFormat = @"HH:mm";
    NSDate *date = [dateFormatter dateFromString:string];
    return date;
}

- (void)popBackEventWillHappen
{
    TYDWatchSetViewController *vc = self.navigationController.viewControllers[self.navigationController.viewControllers.count - 2];
//    
//    NSDate *aStartDate = [self dateFromTimeString:self.aStartString];
//    NSDate *aEndDate = [self dateFromTimeString:self.aEndString];
//    NSDate *aStartDateNew = [aStartDate dateByAddingTimeInterval:12*60*60];
//    NSDate *aEndDateNew = [aEndDate dateByAddingTimeInterval:12*60*60];
//    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
//    dateFormatter.dateFormat = @"HH:mm";
//    NSString *aStartStringNew = [dateFormatter stringFromDate:aStartDateNew];
//    NSString *aEndStringNew = [dateFormatter stringFromDate:aEndDateNew];
    NSString *weekString = [NSString stringWithFormat:@"%@%@%@%@%@%@%@",self.weekArray[0],self.weekArray[1],self.weekArray[2],self.weekArray[3],self.weekArray[4],self.weekArray[5],self.weekArray[6]];
    vc.silenceTimeString = [NSString stringWithFormat:@"%@ %@-%@ %@-%@",weekString ,self.mStartString ,self.mEndString, self.aStartString,self.aEndString];
    [self.navigationController popToViewController:vc animated:YES];
}
//- (void)bottomPopupViewLoad
//{
    //    UIView *baseView = self.view;
    //    CGRect frame = baseView.bounds;
    //    UIView *promptBaseView = [[UIView alloc] initWithFrame:frame];
    //    promptBaseView.backgroundColor = [UIColor clearColor];
    //    promptBaseView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    //    [baseView addSubview:promptBaseView];
    //
    //    frame = promptBaseView.bounds;
    //    UIControl *promptBgView = [[UIControl alloc] initWithFrame:frame];
    //    promptBgView.backgroundColor = [UIColor colorWithHex:0x0 andAlpha:0.3];
    //    promptBgView.alpha = 0;
    //    promptBgView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    //    [promptBgView addTarget:self action:@selector(promptBgViewTap:) forControlEvents:UIControlEventTouchUpInside];
    //    [promptBaseView addSubview:promptBgView];
    //
    //    UIView *promptView = [UIView new];
    //    promptView.backgroundColor = [UIColor whiteColor];
    //    [promptBaseView addSubview:promptView];
    //
    //    UIPickerView *pickerView = [UIPickerView new];
    //    pickerView.backgroundColor = [UIColor whiteColor];
    //
    //
    //    UIDatePicker *datePicker = [UIDatePicker new];
    //    datePicker.backgroundColor = [UIColor whiteColor];
    //    datePicker.datePickerMode = UIDatePickerModeTime;
    //    [datePicker addTarget:self action:@selector(datePickerValueChanged:) forControlEvents:UIControlEventValueChanged];
    //    datePicker.minimumDate = [NSDate dateWithTimeIntervalSince1970:self.todayBeginningTimeStamp];
    //    datePicker.maximumDate = [NSDate dateWithTimeIntervalSince1970:self.todayBeginningTimeStamp+ nTimeIntervalSecondsPerDay - 1];
    //    datePicker.minuteInterval = 10;
    //    [promptView addSubview:datePicker];
    //
    //    promptView.frame = CGRectMake(0, 0, promptBaseView.width, datePicker.height);
    //
    //    datePicker.hidden = YES;
    //    promptBaseView.hidden = YES;
    //    promptBgView.alpha = 0;
    //
    //    self.promptBaseView = promptBaseView;
    //    self.promptBgView = promptBgView;
    //    self.promptView = promptView;
    //    self.datePicker = datePicker;
//}
//- (void)promptBgViewTap:(id)sender
//{
//    NSLog(@"promptBgViewTap");
//    [self promptViewHide];
//}

//#pragma mark - SuspendEvent
//
//- (void)promptViewHide
//{
//    [UIView animateWithDuration:0.25
//                          delay:0
//                        options:UIViewAnimationOptionCurveEaseInOut
//                     animations:^{
//                         self.promptBgView.alpha = 0;
//                         self.promptView.top = self.promptBgView.bottom;
//                     }
//                     completion:^(BOOL finished){
//                         self.promptBaseView.hidden = YES;
//                     }];
//        self.selectClassTimeBlock.selected = NO;
//        self.selectClassTimeBlock = nil;
//}
//
//- (void)promptViewShow
//{
//    
//    self.datePicker.hidden = NO;
//    self.promptBaseView.hidden = NO;
//    self.promptBgView.alpha = 0;
//    self.promptView.top = self.promptBgView.bottom;
//    [UIView animateWithDuration:0.25
//                          delay:0
//                        options:UIViewAnimationOptionCurveEaseInOut
//                     animations:^{
//                         self.promptBgView.alpha = 1;
//                         [self.view insertSubview:self.promptBgView aboveSubview:self.baseView];
//                         [self.view insertSubview:self.promptView aboveSubview:self.promptBgView];
//                         self.promptView.bottom = self.promptBgView.bottom;
//                     }
//                     completion:nil];
//}
//

@end
