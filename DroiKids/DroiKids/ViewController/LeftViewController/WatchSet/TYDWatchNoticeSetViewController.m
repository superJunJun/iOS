//
//  TYDWatchNoticeSetViewController.m
//  DroiKids
//
//  Created by superjunjun on 15/8/19.
//  Copyright (c) 2015年 superjunjun. All rights reserved.
//

#import "TYDWatchNoticeSetViewController.h"

@interface TYDWatchNoticeSetViewController ()

@property (strong, nonatomic) IBOutlet UISwitch *watchIncomingCallSwitch;
@property (strong, nonatomic) IBOutlet UISwitch *watchIncomingCallVibrate;
@property (strong, nonatomic) IBOutlet UISwitch *watchMessageRingSwitch;
@property (strong, nonatomic) IBOutlet UISwitch *watchMessageVibrateSwitch;


@end

@implementation TYDWatchNoticeSetViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor colorWithHex:0xefeef0];
    [self localDataInitialize];
    [self navigationBarItemsLoad];
    [self subviewsLoad];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)localDataInitialize
{
    
}

- (void)navigationBarItemsLoad
{
    self.titleText = @"手表设置";
}

- (void)subviewsLoad
{
    
}

#pragma mark - TouchEvent

- (IBAction)watchIncomingCallRingSwitchTap:(UISwitch *)sender
{
}

- (IBAction)watchIncomingCallVibrateSwitchTap:(UISwitch *)sender
{
}

- (IBAction)watchMessageRingSwitchTap:(UISwitch *)sender
{
}

- (IBAction)watchMessageVibrateSwitch:(UISwitch *)sender
{
}

#pragma mark - UITableViewDataSource & UITableViewDelegate

- (CGFloat )tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 21;
}

- (CGFloat )tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 0.05;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    CGRect frame = tableView.bounds;
    frame.size.height = 21;
    NSArray *headerNameArray = @[@"手表来电",@"手机来电"];
    UIView *headerView = [[UIView alloc] initWithFrame:frame];
    headerView.backgroundColor = [UIColor clearColor];
    
    UILabel *titleLabel = [UILabel new];
    titleLabel.backgroundColor = [UIColor clearColor];
    titleLabel.font = [BOAssistor defaultTextStringFontWithSize:12];
    titleLabel.textColor = [UIColor grayColor];
    titleLabel.text = headerNameArray[section];
    [titleLabel sizeToFit];
    titleLabel.center = headerView.innerCenter;
    titleLabel.left = 19;
    titleLabel.top += 2;
    [headerView addSubview:titleLabel];
    
    return headerView;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

@end

