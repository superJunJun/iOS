//
//  TYDInfoNoticeController.m
//  DroiKids
//
//  Created by caiyajie on 15/8/14.
//  Copyright (c) 2015年 superjunjun. All rights reserved.
//

#import "TYDInfoNoticeController.h"

@interface TYDInfoNoticeController ()<UITableViewDataSource, UITableViewDelegate>

@property (strong, nonatomic) UISwitch      *bellSwitcher;
@property (strong, nonatomic) UISwitch      *vibrationSwitcher;
@property (strong, nonatomic) NSArray       *switcherArray;
@property (strong, nonatomic) UITableView   *tableview;
@property (assign, nonatomic) BOOL          bellState;
@property (assign, nonatomic) BOOL          vibrationState;


@end

@implementation TYDInfoNoticeController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = cBasicBackgroundColor;
    [self localDataInitialize];
    [self navigationBarItemsLoad];
    [self subviewsLoad];
}

- (void)localDataInitialize
{
    NSString *appSetInfo = [[NSUserDefaults standardUserDefaults]objectForKey:@"appSetInfo"];
    NSArray *array = [appSetInfo componentsSeparatedByString:@","];
    if(array.count == 2)
    {
        self.bellState = [array.firstObject integerValue] == 1 ? YES : NO;
        self.vibrationState = [array.lastObject integerValue] == 1 ? YES : NO;
    }
}

- (void)navigationBarItemsLoad
{
    self.title = @"消息通知";
}

- (void)subviewsLoad
{
    [self tableviewLoad];
    [self tableviewFooterViewLoad];
}

- (void)tableviewLoad
{
    UITableView *tableView = [[UITableView alloc] initWithFrame:self.view.frame style:UITableViewStylePlain];
    tableView.delegate = self;
    tableView.dataSource = self;
    tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    tableView.backgroundColor = [UIColor clearColor];
    self.tableview = tableView;
    [self.view addSubview:tableView];
}

- (void)tableviewFooterViewLoad
{
    UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, 41)];
    footerView.backgroundColor = [UIColor clearColor];
    
    UILabel *label = [UILabel new];
    label.backgroundColor = [UIColor clearColor];
    label.text = @"关闭后，手机收到消息后将不会有铃声和振动提示！";
    label.font = [UIFont systemFontOfSize:12];
    label.textColor = [UIColor blackColor];
    label.size = CGSizeMake(self.view.width,20);
    label.left = 15;
    label.top = 0;
    [footerView addSubview:label];
    
    self.tableview.tableFooterView = footerView;
}

#pragma mark - UITableViewDelegate &&  UITableViewDataSource
//
//- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
//{
//    return 0.5;
//}
//
//- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    return 50;
//}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 15;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    CGRect frame = tableView.bounds;
    frame.size.height = 15;
    UIView *headerView = [[UIView alloc] initWithFrame:frame];
    headerView.backgroundColor = [UIColor clearColor];
    return headerView;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *cellIdentifier = @"droiKidsSetInfoNoticeCellIdentifier";
    NSArray *cellNamearray = @[@"铃声", @"震动"];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if(!cell)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        UISwitch *switchButton = [UISwitch new];
        switchButton.onTintColor = cBasicGreenColor;
        switchButton.tintColor = [UIColor colorWithHex:0xdcd7cd];
        switchButton.on = indexPath.row == 0 ? self.bellState : self.vibrationState;
        switchButton.center = cell.center;
        switchButton.right = self.view.width - 15;
        [cell.contentView addSubview:switchButton];
        cell.textLabel.font = [BOAssistor defaultTextStringFontWithSize:15];
        cell.textLabel.textColor = [UIColor blackColor];
        [switchButton addTarget:self action:@selector(switchStateChange:) forControlEvents:UIControlEventValueChanged];
    }
    cell.textLabel.text = cellNamearray[indexPath.row];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - touchEvent

- (void)switchStateChange:(UISwitch *)sender
{
    UITableViewCell *cellView = (UITableViewCell *)sender.superview.superview;
    if([cellView.textLabel.text isEqualToString:@"铃声"])
    {
        [self bellSwitcherSwitchStateChange:sender];
    }
    else
    {
        [self vibrationSwitcherSwitchStateChange:sender];
    }
}

- (void)bellSwitcherSwitchStateChange:(UISwitch *)sender
{
    NSLog(@"bellSwitcherSwitchStateChange");
    self.bellState = sender.on;
}

- (void)vibrationSwitcherSwitchStateChange:(UISwitch *)sender
{
    NSLog(@"vibrationSwitcherSwitchStateChange");
    self.vibrationState = sender.on;
}

- (void)popBackEventWillHappen
{
    NSString *appSetInfo = [NSString stringWithFormat:@"%@,%@", @(self.bellState), @(self.vibrationState)];
    [[NSUserDefaults standardUserDefaults]setValue:appSetInfo forKey:@"appSetInfo"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [super popBackEventWillHappen];
}
@end
