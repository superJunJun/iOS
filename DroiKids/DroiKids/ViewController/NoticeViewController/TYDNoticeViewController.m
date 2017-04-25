//
//  TYDNoticeViewController.m
//  DroiKids
//
//  Created by superjunjun on 15/8/24.
//  Copyright (c) 2015年 TYDTech. All rights reserved.
//

#import "TYDNoticeViewController.h"
#import "TYDNoticeCellTableViewCell.h"
#import "TYDNoticeDetailViewController.h"
#import "TYDDataCenter.h"
#import "TYDKidMessageInfo.h"

#define sNoticeCellIndetity      @"noticeCell"


@interface TYDNoticeViewController ()<UITableViewDataSource,UITableViewDelegate>

@property (nonatomic, strong) UITableView       *tableView;
@end

@implementation TYDNoticeViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor blueColor];
    [self localDataInitialize];
    [self navigationBarItemsLoad];
    [self subviewsLoad];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self getNotificationInfo];
}

- (void)localDataInitialize
{
//        NSArray *array= @[@"爸爸的未接电话", @"妈妈的未接电话", @"手表没电啦", @"该吃饭了", @"1", @"2", @"1", @"2", @"1", @"2"];
//        self.noticeArray = [array mutableCopy];
}

- (void)navigationBarItemsLoad
{
    self.titleText = @"消息记录";//NSLocalizedString(@"my_ranking", nil);//@"排名";
    self.editButtonItem.tintColor = [UIColor whiteColor];
    self.editButtonItem.title = @"编辑";
    self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)subviewsLoad
{
    CGRect frame = self.view.bounds;
    UITableView *tableView = [[UITableView alloc] initWithFrame:frame style:UITableViewStylePlain];
    tableView.delegate = self;
    tableView.dataSource = self;
    tableView.showsVerticalScrollIndicator = NO;
    tableView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    [self.view addSubview:tableView];
    self.tableView = tableView;
}

- (void)setEditing:(BOOL)editing animated:(BOOL)animated
{
    [super setEditing:editing animated:animated];
    [self.tableView setEditing:editing animated:animated];
    if(self.editing)
    {
        self.editButtonItem.title = @"完成";
    }
    else
    {
        self.editButtonItem.title = @"编辑";
    }
}

#pragma mark - UITableViewRelative

- (TYDKidMessageInfo *)messsageInfoAtIndexPath:(NSIndexPath *)indexPath
{
    TYDKidMessageInfo *info = nil;
    if(indexPath.row < self.noticeArray.count)
    {
        info = self.noticeArray[indexPath.row];
    }
    return info;
}

#pragma mark - UITableViewDelegate

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewCellEditingStyleDelete;
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.noticeArray count];
}

// 插入删除
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete)
    {
        TYDKidMessageInfo *info = [self messsageInfoAtIndexPath:indexPath];
        [self.noticeArray removeObject:info];
        [[TYDDataCenter defaultCenter] removeOneMessageInfo:info];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    TYDNoticeCellTableViewCell *cell  = [tableView  dequeueReusableCellWithIdentifier:sNoticeCellIndetity];
    if(cell == nil)
    {
        cell = [[NSBundle mainBundle]loadNibNamed:@"TYDNoticeCellTableViewCell" owner:nil options:nil].firstObject;
    }

    TYDKidMessageInfo *messageInfo = [self messsageInfoAtIndexPath:indexPath];
//    cell.noticeTimeLabel.text = [BOTimeStampAssistor getHourStringWithTimeStamp:messageInfo.infoCreateTime.integerValue];
//    cell.noticeLocationLabel.text = aNoticeStringArray[messageInfo.infoType.integerValue - iNoticeStringNumber];
    NSLog(@"%@, %@",messageInfo, messageInfo.infoType);
//    cell.noticeTypeLabel.text = aNoticeStringArray[messageInfo.infoType.integerValue - iNoticeStringNumber];
//    cell.avatarImageView.image = [UIImage imageNamed:@"main_left_babyMale"];

    cell.messageInfo = messageInfo;

    return cell;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 0.05;
}
- (CGFloat )tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 66;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{  
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    TYDKidMessageInfo *messageInfo = self.noticeArray[indexPath.row];
    NSInteger infoType = messageInfo.infoType.integerValue;
    if(infoType == 103014 || infoType == 103015 || infoType ==103016)
    {
        if(messageInfo.messageUnreadFlag.integerValue == 0)
        {
            messageInfo.messageUnreadFlag = @(1);
            [[TYDDataCenter defaultCenter]saveMessageInfo:messageInfo];
        }
        NSData *data = [messageInfo.messageContent dataUsingEncoding:NSUTF8StringEncoding];
        NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
        NSDictionary *contentDic = dic[@"content"];
        
        NSArray *noticeTypeArray = @[@"未接来电" ,@"出栅栏" ,@"入栅栏"];
        TYDNoticeDetailViewController *vc = [TYDNoticeDetailViewController new];
        vc.avatar = [UIImage imageNamed:@"main_left_babyMale"];
        vc.noticeTime = [BOTimeStampAssistor getHourStringWithTimeStamp:messageInfo.infoCreateTime.integerValue];//@"17:39";
        vc.noticeType = noticeTypeArray[infoType - 103014];
        vc.noticeLocation = [NSString stringWithFormat:@"%@,%@",contentDic[@"latitude"] ,contentDic[@"longitude"]];
        [self.navigationController pushViewController:vc animated:YES];
    }
}

#pragma mark - Connect To Server

- (void)getNotificationInfo
{
    NSDictionary *params = @{@"openid"  :[[TYDUserInfo sharedUserInfo]openID]
                             };
    
    [self postURLRequestWithMessageCode:102039
                           HUDLabelText:nil
                                 params:[params mutableCopy]
                          completeBlock:^(id result) {
                              [self parseUseNotificationInfo:result];
                          }];
}

- (void)parseUseNotificationInfo:(id)result
{
    NSLog(@"parseUseLocationInfoComplete:%@", result);
    NSDictionary *dic = result;
    NSNumber *resultCode = result[@"result"];
    
    if(resultCode != nil
       && resultCode.intValue == 0)
    {
        NSArray *pushsArray = [dic objectForKey:@"pushs"];
        if(pushsArray.count > 0)
        {
            for(NSDictionary *detailDic in pushsArray)
            {
                TYDKidMessageInfo *messageInfo = [TYDKidMessageInfo new];
                NSString *contentString = detailDic[@"content"];
                NSData *data = [contentString dataUsingEncoding:NSUTF8StringEncoding];
                NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
                NSDictionary *contentDic = dic[@"content"];
                messageInfo.kidID = [[[TYDDataCenter defaultCenter]currentKidInfo] kidID];
                messageInfo.messageContent = contentString;
                messageInfo.infoType = @([contentDic[@"operatecode"] intValue]);
                messageInfo.infoCreateTime = detailDic[@"createtime"];
                messageInfo.messageUnreadFlag = @(0);
                /*
                 pushs =     (
                 {
                 content = "{\"content\":{\"watchid\":\"141414141414142\",\"fromid\":\"558e0b24c23099a9aa0036f1\",\"operatecode\":\"103019\",\"imgid\":null}}";
                 createtime = "Oct 19, 2015 5:49:27 PM";
                 toid = 545adbf5c23099ccbc000450;
                 }
                 );
                 */
//                kidID;
//                messageID;
//                messageContent;
//                messageUnreadFlag;
//                infoType;
//                infoCreateTime;
//                [messageInfo setAttributes:detailDic];
                [[TYDDataCenter defaultCenter]saveMessageInfo:messageInfo];
            }
        }
//        else
//        {
////            self.noticeArray = [[[TYDDataCenter defaultCenter]messageInfoList] mutableCopy];
////            self.noticeText = @"没有儿童消息";
//        }
    }
    else
    {
        self.noticeText = @"获取儿童消息失败";
    }
    self.noticeArray = [[[TYDDataCenter defaultCenter]messageInfoList] mutableCopy];
    NSMutableArray *removeArray = [NSMutableArray new];
    if(self.noticeArray.count > 0)
    {
        for(TYDKidMessageInfo *messageInfo in self.noticeArray)
        {
            NSInteger infoType = messageInfo.infoType.integerValue;
            if(infoType == 103004 || infoType == 103007 || infoType == 103011 || infoType == 103014 || infoType == 103015 || infoType == 103016 || infoType == 103020 || infoType == 103021 || infoType == 103022)
                {
                    if(messageInfo.messageUnreadFlag.integerValue == 0)
                    {
                        
                        if(infoType == 103014 || infoType == 103015 || infoType == 103016)
                        {
        //                    messageInfo.messageUnreadFlag = @(0);
                        }
                        else
                        {
                            messageInfo.messageUnreadFlag = @(1);
                            [[TYDDataCenter defaultCenter]saveMessageInfo:messageInfo];
                        }
                    }
                }
                else
                {
                    [removeArray addObject:messageInfo];
                }
            
        }
        [self.noticeArray removeObjectsInArray:removeArray];
        [self.tableView reloadData];
    }
    else
    {
        self.noticeText = @"没有儿童消息";
    }
    [self progressHUDHideImmediately];
//    self.noticeArray = [[[TYDDataCenter defaultCenter]messageInfoList] mutableCopy];
//    NSLog(@" %@",self.noticeArray);
//    if(self.noticeArray.count > 0)
//    {
//        [self.tableView reloadData];
//    }
}

@end
