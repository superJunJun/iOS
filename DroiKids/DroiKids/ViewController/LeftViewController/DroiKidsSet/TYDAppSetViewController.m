//
//  TYDAppSetViewController.m
//  DroiKids
//
//  Created by superjunjun on 15/8/10.
//  Copyright (c) 2015年 superjunjun. All rights reserved.
//

#import "TYDAppSetViewController.h"
#import "TYDInfoNoticeController.h"
#import "TYDCommonProblemController.h"
#import "TYDFeedbackController.h"
#import "TYDAboutViewController.h"
#import "TYDModifyPasswordController.h"
#import "TYDDataCenter.h"

@interface TYDAppSetViewController ()

@property (weak, nonatomic) IBOutlet UIButton *logoutButton;

@end

@implementation TYDAppSetViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor colorWithHex:0xf0f0f0];
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
    [self.tableView setSeparatorColor:[UIColor colorWithHex:0xdfdfdf]];
    [self.logoutButton setTitleColor:[UIColor colorWithHex:0xff1c1c] forState:UIControlStateNormal];
}

- (void)navigationBarItemsLoad
{
    self.title = @"偏好设置";
}

- (void)subviewsLoad
{
    //[self tableFooterViewLoad];
}

//- (void)tableFooterViewLoad
//{
//    self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
//    CGRect frame = CGRectMake(0, 0, self.view.width, 200);
//    UIView *tableFooterView = [[UIView alloc] initWithFrame:frame];
//    tableFooterView.backgroundColor = [UIColor clearColor];
//    
//    if([self.tableView respondsToSelector:@selector(separatorInset)])
//    {
//        [self.tableView setSeparatorInset:UIEdgeInsetsMake(0.5, 19, 0, 19)];
//    }
//    UIEdgeInsets capInsets = UIEdgeInsetsMake(19, 20, 19, 20);//UIEdgeInsetsMake(19, 20, 19, 20)
//    UIButton *logoutButton = [[UIButton alloc] initWithImageName:@"login_btn" highlightedImageName:@"login_btnH" capInsets:capInsets givenButtonSize:CGSizeMake(320, 40) title:@"退出登录" titleFont:[UIFont fontWithName:@"Arial" size:18] titleColor:[UIColor blackColor]];
//    [logoutButton addTarget:self action:@selector(logoutButtonTap:) forControlEvents:UIControlEventTouchUpInside];
//    logoutButton.center = tableFooterView.center;
//    logoutButton.top = 100;
//    [tableFooterView addSubview:logoutButton];
//    UIButton *cancelWatchButton = [[UIButton alloc] initWithImageName:@"login_btn" highlightedImageName:@"login_btnH" capInsets:capInsets givenButtonSize:CGSizeMake(320, 40) title:@"注销手表" titleFont:[UIFont fontWithName:@"Arial" size:18] titleColor:[UIColor blackColor]];
//    [cancelWatchButton addTarget:self action:@selector(cancelWatchButtonTap:) forControlEvents:UIControlEventTouchUpInside];
//    cancelWatchButton.center = tableFooterView.center;
//    cancelWatchButton.top = logoutButton.bottom + 10 ;
//    [tableFooterView addSubview:cancelWatchButton];
//    self.tableView.tableFooterView = tableFooterView;
//}

#pragma mark - UITableView Delegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 59;
}

- (CGFloat )tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 18;
}

- (CGFloat )tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 0.05;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    CGRect frame = tableView.bounds;
    frame.size.height = 15;
    UIView *headerView = [[UIView alloc] initWithFrame:frame];
    headerView.backgroundColor = [UIColor clearColor];
    return headerView;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    [BOAssistor indexPathShow:indexPath withTitle:@"indexPath"];
    [self selectRowAtIndexPath:indexPath];
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    cell.backgroundColor = [UIColor colorWithHex:0xffffff];
}

#pragma mark - touchEvent

- (void)selectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.section == 0)
    {
        switch(indexPath.row)
        {
            case 0:
            {
                TYDInfoNoticeController *vc = [TYDInfoNoticeController new];
                [self.navigationController pushViewController:vc animated:YES];
                break;
            }
            case 1:
            {
                TYDModifyPasswordController *vc = [TYDModifyPasswordController new];
                [self.navigationController pushViewController:vc animated:YES];
                break;
            }
        }
    }
    else if (indexPath.section == 1)
    {
        switch(indexPath.row)
        {
            case 0:
            {
                TYDCommonProblemController *vc = [TYDCommonProblemController new];
                [self.navigationController pushViewController:vc animated:YES];
                break;
            }
            case 1:
            {
                TYDAboutViewController *vc = [TYDAboutViewController new];
                [self.navigationController pushViewController:vc animated:YES];
                break;
            }
        }
  
    }
    else if (indexPath.section == 2)
    {
        TYDFeedbackController *vc = [TYDFeedbackController new];
        [self.navigationController pushViewController:vc animated:YES];
    }
    else
    {
        [self logout];
    }
}

- (void)logout
{
    NSLog(@"退出登录");
    [[TYDDataCenter defaultCenter] clearKidInfoList];
    [self progressHUDShowWithCompleteText:@"退出登录成功" isSucceed:YES additionalTarget:self action:@selector(logoutSucceed) object:@YES];
}

- (void)logoutSucceed
{
    UINavigationController *loginNavigationController = [self.storyboard instantiateViewControllerWithIdentifier:@"loginNavigationController"];
    AppDelegate *delagete = [UIApplication sharedApplication].delegate;
    [delagete.window setRootViewController:loginNavigationController];
//    [UIView transitionFromView:delagete.window.rootViewController.view toView:loginNavigationController.view duration:.5 options:UIViewAnimationOptionLayoutSubviews completion:^(BOOL finished) {
//        [delagete.window setRootViewController:loginNavigationController];
//    }];
}

- (void)logoutButtonTap:(id)sender
{
    NSLog(@"退出登录");
}

- (void)cancelWatchButtonTap:(id)sender
{
     NSLog(@"注销手表");
}

@end
