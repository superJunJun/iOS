//
//  TYDCommonProblemController.m
//  DroiKids
//
//  Created by caiyajie on 15/9/23.
//  Copyright (c) 2015年 TYDTech. All rights reserved.
//

#import "TYDCommonProblemController.h"

@interface TYDCommonProblemCell : UITableViewCell

@property (strong, nonatomic) NSString *problemTitle;
@property (strong, nonatomic) UILabel *problemTitleLabel;
@property (strong, nonatomic) NSString *problemDetail;
@property (strong, nonatomic) UILabel *problemDetailLabel;

@end

@implementation TYDCommonProblemCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if(self = [super initWithStyle:style reuseIdentifier:reuseIdentifier])
    {
        self.backgroundColor = [UIColor colorWithHex:0xffffff];
        UILabel *problemTitleLabel = [UILabel new];
        problemTitleLabel.backgroundColor = [UIColor clearColor];
        problemTitleLabel.font = [BOAssistor defaultTextStringFontWithSize:15];
        problemTitleLabel.textColor = [UIColor colorWithHex:0x0];
        
        UILabel *problemDetailLabel = [UILabel new];
        problemDetailLabel.backgroundColor = [UIColor clearColor];
        problemDetailLabel.font = [BOAssistor defaultTextStringFontWithSize:12];;
        problemDetailLabel.textColor = [UIColor colorWithHex:0xaaaaaa];
        
        [self.contentView addSubview:problemTitleLabel];
        [self.contentView addSubview:problemDetailLabel];
        self.problemTitleLabel = problemTitleLabel;
        self.problemDetailLabel = problemDetailLabel;
    }
    return self;
}

#pragma mark - OverridePropertyMethod

- (void)setProblemTitle:(NSString *)problemTitle
{
    _problemTitle = problemTitle;
    self.problemTitleLabel.text = problemTitle;
    [self.problemTitleLabel sizeToFit];
    self.problemTitleLabel.left = 17;
    self.problemTitleLabel.top = 15;
}

- (void)setProblemDetail:(NSString *)problemDetail
{
    _problemDetail = problemDetail;
    self.problemDetailLabel.text = problemDetail;
    [self.problemDetailLabel sizeToFit];
    self.problemDetailLabel.left = 17;
    self.problemDetailLabel.top = self.problemTitleLabel.bottom + 5;
}

@end

#import "TYDCommonProblemController.h"
#import "TYDProblemDetailController.h"

@interface TYDCommonProblemController ()<UITableViewDelegate, UITableViewDataSource>

@property (strong, nonatomic) UITableView *tableView;
@property (strong, nonatomic) NSArray *problemTileArray;
@property (strong, nonatomic) NSArray *problemDetailArray;

@end

@implementation TYDCommonProblemController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor colorWithHex:0xf0f0f0];
    [self localDataInitialize];
    [self navigationBarItemsLoad];
    [self subviewsLoad];
}

- (void)localDataInitialize
{
    self.problemTileArray = @[@"问题一", @"问题二", @"问题三"];
    self.problemDetailArray = @[@"详情详情详情详情详情", @"详情详情详情详情详情", @"详情详情详情"];
}

- (void)navigationBarItemsLoad
{
    self.title = @"常见问题";
}

- (void)subviewsLoad
{
    CGRect frame = self.view.bounds;
    UITableView *tableView = [[UITableView alloc] initWithFrame:frame style:UITableViewStylePlain];
    tableView.backgroundColor = [UIColor clearColor];
    tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    [tableView setSeparatorColor:[UIColor colorWithHex:0xdfdfdf]];
    tableView.dataSource = self;
    tableView.delegate = self;
    tableView.showsVerticalScrollIndicator = NO;
    tableView.indicatorStyle = UIScrollViewIndicatorStyleBlack;
    tableView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    [self.view addSubview:tableView];
    self.tableView = tableView;
    
    UIView *footerView = [UIView new];
    footerView.size = CGSizeMake(self.view.width, 20);
    footerView.backgroundColor = [UIColor clearColor];
    self.tableView.tableFooterView = footerView;
}

#pragma mark - UITableView Delegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.problemTileArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *commonProblemCellIdentifier = @"commonProblemCellIdentifier";
    TYDCommonProblemCell *commonProblemCell = [tableView dequeueReusableCellWithIdentifier:commonProblemCellIdentifier];
    if(!commonProblemCell)
    {
        commonProblemCell = [[TYDCommonProblemCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:commonProblemCellIdentifier];
    }
    commonProblemCell.problemTitle = self.problemTileArray[indexPath.row];
    commonProblemCell.problemDetail = self.problemDetailArray[indexPath.row];
    commonProblemCell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    return commonProblemCell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 59;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    TYDProblemDetailController *vc = [TYDProblemDetailController new];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    cell.backgroundColor = [UIColor colorWithHex:0xffffff];
}

@end
