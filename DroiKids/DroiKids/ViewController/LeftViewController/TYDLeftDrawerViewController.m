//
//  TYDLeftDrawerViewController.m
//  DroiKids
//
//  Created by superjunjun on 15/8/5.
//  Copyright (c) 2015年 superjunjun. All rights reserved.
//

#import "TYDLeftDrawerViewController.h"
#import "TYDMainViewController.h"
#import "AppDelegate.h"
#import "TYDBabyDetailViewController.h"
#import "TYDWatchSetViewController.h"
#import "TYDAddressbookViewController.h"
#import "TYDAppSetViewController.h"
#import "TYDQRCodeViewController.h"
#import "TYDLeftDrawerTableViewCell.h"
#import "TYDDataCenter.h"
#import "TYDKidInfo.h"
#import "UIImageView+WebCache.h"

#define sBabyDetailSegueIdentifier           @"babyDetailSegue"
#define sWatchSetSegueIdentifier             @"watchSetSegue"
#define sAddressbookSegueSegueIdentifier     @"addressbookSegue"
#define sAppSetSegueIdentifier               @"appSetSegue"

@interface TYDLeftDrawerViewController ()<UITableViewDataSource,UITableViewDelegate>

@property (nonatomic, weak) TYDMainViewController *mainViewController;
@property (nonatomic, strong) UIView *tapGestureRecognizerView;

@end

@implementation TYDLeftDrawerViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor clearColor];
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
    self.isNeedToHideNavigationBar = YES;
}

- (void)navigationBarItemsLoad
{
    
}

- (void)subviewsLoad
{
    self.tableView.backgroundColor = [UIColor colorWithHex:0xf0f0f0];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.mainViewController = (TYDMainViewController *)self.parentViewController;
    [self addGestureRecognizerView];
}

#pragma mark - TouchEvent

- (void)addGestureRecognizerView
{
    //添加单击手势视图
    CGRect frame = self.view.frame;
    NSInteger width = 42;
    if (_tapGestureRecognizerView == nil)
    {
        _tapGestureRecognizerView = [UIView new];
        _tapGestureRecognizerView.left = frame.size.width - width;
        _tapGestureRecognizerView.top = self.view.top;
        _tapGestureRecognizerView.width = width;
        _tapGestureRecognizerView.height = self.view.height;
        _tapGestureRecognizerView.userInteractionEnabled = YES;
        _tapGestureRecognizerView.backgroundColor = [UIColor clearColor];
        [self.view addSubview:_tapGestureRecognizerView];
    }
    UITapGestureRecognizer  *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showMainviewController)];
    UIPanGestureRecognizer *panGestureRecognizer = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(pan:)];
    [_tapGestureRecognizerView addGestureRecognizer:tapGestureRecognizer];
    [self.view addGestureRecognizer:panGestureRecognizer];
}

- (void)showMainviewController
{
    [UIView animateWithDuration:.3 animations:^{
        CATransform3D transform = CATransform3DMakeTranslation(0, 0, 0);
        self.view.layer.transform = transform;
        self.mainViewController.grayView.alpha = 0;
    } completion:^(BOOL finished) {
        self.mainViewController.grayView.hidden = YES;
    }];
}

- (void)pan:(UIPanGestureRecognizer *)panGestureRecognizer
{
    NSInteger width = self.view.width;
    //当前的拖动位移
    CGPoint translationPoint = [panGestureRecognizer translationInView:self.view];
    CATransform3D transform = self.view.layer.transform;
    //拖动结束时  可能需要执行动画
    if(panGestureRecognizer.state == UIGestureRecognizerStateEnded)
    {
        //查看当前总得偏移量
        if(transform.m41 >= width / 1.5)
        {
            [UIView animateWithDuration:0.1 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
                CATransform3D transform = CATransform3DMakeTranslation(width, 0, 0);
                self.view.layer.transform = transform;
                self.mainViewController.grayView.alpha = 0.5;
            } completion:^(BOOL finished) {
                self.mainViewController.grayView.hidden = NO;
            }];
        }
        else
        {
            //还原到最初位置
            [UIView animateWithDuration:0.1 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
                self.view.layer.transform = CATransform3DIdentity;
                self.mainViewController.grayView.alpha = 0;
            } completion:^(BOOL finished) {
                self.mainViewController.grayView.hidden = YES;
            }];
        }
    }
    //正在拖动
    else if(panGestureRecognizer.state == UIGestureRecognizerStateChanged)
    {
        //总得偏移量 区间 [width, 0] transform.m41 在view的位置 translationPoint.x 移动的距离
        self.mainViewController.grayView.alpha = transform.m41 / (width * 2);
        if(transform.m41 + translationPoint.x > width)
        {
            translationPoint.x = width - transform.m41;
        }
        else if(transform.m41 + translationPoint.x < 0)
        {
            translationPoint.x = -transform.m41;
        }
        transform = CATransform3DTranslate(transform, translationPoint.x, 0, 0);
        self.view.layer.transform = transform;
        [panGestureRecognizer setTranslation:CGPointMake(0, 0) inView:self.view];
    }
}

#pragma mark - UITableViewDataSource & UITableViewDelegate

- (CGFloat )tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if(section == 0)
    {
      return 140;
    }
    return 0;
}

- (CGFloat )tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 10;
}

- (CGFloat )tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 59;
}

- (NSInteger )numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger )tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(section == 0)
    {
        return 3;
    }
    else
    {
        return 1;
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if(section == 0)
    {
        CGRect frame = tableView.bounds;
        frame.size.height = 140;
        TYDKidInfo *kidInfo = [[TYDDataCenter defaultCenter]currentKidInfo];

        UIView *headerView = [[UIView alloc] initWithFrame:frame];
        headerView.backgroundColor = [UIColor clearColor];
        
        UIImageView *avatarImageView = [UIImageView new];
        if(kidInfo.kidAvatarPath.length > 0)
        {
            if(kidInfo.kidGender.integerValue == TYDKidGenderTypeBoy)
            {
                NSURL *avatarUrl = [[NSURL alloc]initWithString:kidInfo.kidAvatarPath];
                [avatarImageView setImageWithURL:avatarUrl placeholderImage:[UIImage imageNamed:@"main_left_babyMale"]];
            }
            else
            {
                NSURL *avatarUrl = [[NSURL alloc]initWithString:kidInfo.kidAvatarPath];
                [avatarImageView setImageWithURL:avatarUrl placeholderImage:[UIImage imageNamed:@"main_left_babyFemale"]];
            }
        }
        else if(kidInfo.kidGender.integerValue == TYDKidGenderTypeBoy)
        {
            avatarImageView.image = [UIImage imageNamed:@"main_left_babyMale"];
        }
        else if(kidInfo.kidGender.integerValue == TYDKidGenderTypeGirl)
        {
            avatarImageView.image = [UIImage imageNamed:@"main_left_babyFemale"];
        }
        avatarImageView.frame = CGRectMake(17, 46, 67, 67);
        avatarImageView.layer.cornerRadius = avatarImageView.size.width / 2;
        avatarImageView.layer.masksToBounds = YES;
        avatarImageView.backgroundColor = [UIColor clearColor];
        [headerView addSubview:avatarImageView];
        
        UILabel *babyNameLabel = [UILabel new];
        babyNameLabel.text = kidInfo.kidName;//@"小明";
        babyNameLabel.font =[UIFont systemFontOfSize:11.0];
        babyNameLabel.textColor = [UIColor colorWithHex:0x000000];
        [babyNameLabel sizeToFit];
        babyNameLabel.top = avatarImageView.bottom + 5;
        babyNameLabel.xCenter = avatarImageView.xCenter;
//        babyNameLabel.backgroundColor = [UIColor clearColor];
        [headerView addSubview:babyNameLabel];
        return headerView;
    }
    else
    {
        CGRect frame = CGRectMake(0, 0, self.view.width, 18);
        UIView *headerView = [[UIView alloc] initWithFrame:frame];
        headerView.backgroundColor = [UIColor clearColor];
        return headerView;
    }
    return nil;
    
}

- (void)addButtonTap:(UITapGestureRecognizer *)sender
{
    TYDQRCodeViewController *vc = [TYDQRCodeViewController new];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if(indexPath.section == 0)
    {
        if(indexPath.row == 0)
        {
            //宝贝资料
            [self.parentViewController performSegueWithIdentifier:sBabyDetailSegueIdentifier sender:nil];
        }
        else if(indexPath.row == 1)
        {
            //通讯录
            [self.parentViewController performSegueWithIdentifier:sAddressbookSegueSegueIdentifier sender:nil];
        }
        else
        {
            // 手表设置
            [self.parentViewController performSegueWithIdentifier:sWatchSetSegueIdentifier sender:nil];
        }
    }
    else
    {
    //app设置
        [self.parentViewController performSegueWithIdentifier:sAppSetSegueIdentifier sender:nil];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSArray *labelArray = @[@"宝贝资料", @"通讯录", @"手表设置", @"偏好设置"];
    NSArray *imageArray = @[@"main_left_babyDetail", @"main_left_addressBook", @"main_left_watchSet", @"main_left_appSet"];
    TYDLeftDrawerTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"leftDrawerCell"];
    if(!cell)
    {
        cell = [[NSBundle mainBundle]loadNibNamed:@"TYDLeftDrawerTableViewCell" owner:nil options:nil].firstObject;
        cell.separetorView.hidden = YES;
    }
    if(indexPath.section == 0)
    {
        cell.detailImageView.image = [UIImage imageNamed:imageArray[indexPath.row]];
        cell.detailLabel.text = labelArray[indexPath.row];
        if(indexPath.row < 2)
        {
            cell.separetorView.hidden = NO;
        }
    }
    else
    {
        cell.detailImageView.image = [UIImage imageNamed:imageArray.lastObject];
        cell.detailLabel.text = labelArray.lastObject;
    }
    return cell;
}

@end
