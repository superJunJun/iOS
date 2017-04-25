//
//  TYDAddressbookViewController.m
//  DroiKids
//
//  Created by superjunjun on 15/8/10.
//  Copyright (c) 2015年 superjunjun. All rights reserved.
//

#import "TYDAddressbookViewController.h"
#import "TYDChooseAvatarViewController.h"
#import "TYDContactTableViewCell.h"
#import "TYDContact.h"
#import "TYDActionSheet.h"
#import "TYDUserInfo.h"
#import "TYDPostUrlRequest.h"
#import "TYDDataCenter.h"
#import "TYDKidInfo.h"
#import "TYDKidContactInfo.h"
#import "MBProgressHUD.h"
#import "TYDQRCodeViewController.h"
#import "MJRefresh.h"
#import "NSString+MD5Addition.h"

#define sContactReuseCell                   @"TYDContactCell"
#define sTableViewNumberOfSection           2

#define sTableViewHeaderHeight              20
#define sTableViewSectionHeaderHeight       15

@interface TYDAddressbookViewController () <UITableViewDataSource, UITableViewDelegate, TYDActionSheetDelegate, UIAlertViewDelegate>

@property (strong, nonatomic) NSMutableArray *contactArray;
@property (strong, nonatomic) TYDKidContactInfo *userContactInfo;
@property (strong, nonatomic) NSMutableArray *otherContactArray;

@property (strong, nonatomic) NSMutableDictionary *userContactInfoDic;
@property (strong, nonatomic) UITableView *tableView;
@property (strong, nonatomic) NSIndexPath *selectIndexPath;

@end

@implementation TYDAddressbookViewController


- (void)viewDidLoad
{
    [super viewDidLoad];

    self.view.backgroundColor = cBasicBackgroundColor;
    [self localDataInitialize];
    [self navigationBarItemsLoad];
    [self subviewsLoad];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self reloadTableView];
}

- (void)localDataInitialize
{
    [self getContactListFromServer];
}

- (void)navigationBarItemsLoad
{
    self.titleText = @"通讯录";
    
    TYDKidInfo *currentKidInfo = [TYDDataCenter defaultCenter].currentKidInfo;
    if(currentKidInfo.kidGuardianType.integerValue == TYDKidContactTypeManager)
    {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        [button setTitle:@"添加" forState:UIControlStateNormal];
        [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [button setTitleColor:[UIColor grayColor] forState:UIControlStateHighlighted];
        [button sizeToFit];
        [button addTarget:self action:@selector(addContactButtonClick) forControlEvents:UIControlEventTouchUpInside];
        UIBarButtonItem *rightBarButtonItem = [[UIBarButtonItem alloc]initWithCustomView:button];
        self.navigationItem.rightBarButtonItem = rightBarButtonItem;
    }
}

- (void)subviewsLoad
{
    UIView *tableViewFootView = [UIView new];
    tableViewFootView.backgroundColor = [UIColor clearColor];
    tableViewFootView.size = CGSizeMake(self.view.width, 20);
    
    CGRect frame = self.view.bounds;
    UITableView *tableView = [[UITableView alloc] initWithFrame:frame style:UITableViewStylePlain];
    tableView.backgroundColor = [UIColor clearColor];
    tableView.tableFooterView = tableViewFootView;
    tableView.delegate = self;
    tableView.dataSource = self;
    tableView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    tableView.showsVerticalScrollIndicator = NO;
    
    [tableView addLegendHeaderWithRefreshingTarget:self refreshingAction:@selector(headerRereshing)];
    
    [self.view addSubview:tableView];
    self.tableView = tableView;
}

- (void)reloadTableView
{
    if([TYDDataCenter defaultCenter].isContactInfoListModified)
    {
        NSArray *kidContactInfoList = [TYDDataCenter defaultCenter].kidContactInfoList;
        kidContactInfoList = [self contactSortHandle:kidContactInfoList];
        
        self.contactArray = kidContactInfoList.mutableCopy;
        
        [self contactDivisiveHandle];
        [self.tableView reloadData];
        [TYDDataCenter defaultCenter].isContactInfoListModified = NO;
    }
}

#pragma mark - MJRefresh

- (void)headerRereshing
{
    [self endRereshing];
    
    [self getContactListFromServer];
}

- (void)endRereshing
{
    [self.tableView.header endRefreshing];
}

#pragma mark - touchEvent

- (void)addContactButtonClick
{
    if([TYDDataCenter defaultCenter].kidContactInfoList.count < nKidContactCountForKidMax - nKidCountForUserMax)
    {
        TYDChooseAvatarViewController *vc = [TYDChooseAvatarViewController new];
        vc.editContactType = TYDEditContactTypeAdd;
        [self.navigationController pushViewController:vc animated:YES];
    }
    else
    {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"添加联系人" message:@"联系人最多不能超过20位" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alertView show];
    }
}

#pragma mark - UITableViewDataSource & UITableViewDelegate

- (CGFloat )tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return sTableViewHeaderHeight;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [TYDContactTableViewCell cellHeight];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return sTableViewNumberOfSection;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(section == 0)
    {
        return self.userContactInfo ? 1 : 0;
    }
    else
    {
        return self.otherContactArray.count;
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    CGRect frame = tableView.bounds;
    frame.size.height = sTableViewSectionHeaderHeight;
    
    UIView *headerView = [[UIView alloc] initWithFrame:frame];
    headerView.backgroundColor = [UIColor clearColor];
    
    return headerView;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    TYDContactTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:sContactReuseCell];
    if(!cell)
    {
        cell = [[TYDContactTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:sContactReuseCell];
        cell.selectionStyle = UITableViewCellSelectionStyleDefault;
    }
    
    if(indexPath.section == 0)
    {
        cell.kidContactInfo = self.userContactInfo;
    }
    else
    {
        cell.kidContactInfo = self.otherContactArray[indexPath.row];
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    self.selectIndexPath = indexPath;
    TYDContactTableViewCell *cell = (TYDContactTableViewCell *)[tableView cellForRowAtIndexPath:indexPath];
    
    NSInteger cellContactType = cell.kidContactInfo.contactType.integerValue;
    NSString *contactNumber = cell.kidContactInfo.contactNumber;
    NSString *sheetTitle = [NSString new];
    if(contactNumber)
    {
        sheetTitle = [cell.textLabel.text stringByAppendingString:[NSString stringWithFormat:@"(%@)", contactNumber]];
    }
    else
    {
        sheetTitle = cell.textLabel.text;
    }
    
    NSString *modifyContact = @"修改联系人";
    NSString *Unbinding = @"解除绑定";
    NSString *setManager = @"设为管理员";
    NSString *deleteContact = @"删除联系人";
    NSString *familyNumber1st = @"快捷拨号1";
    NSString *familyNumber2nd = @"快捷拨号2";
    NSString *canCel = @"取消";
    
    TYDKidInfo *currentKidInfo = [TYDDataCenter defaultCenter].currentKidInfo;
    NSInteger userContactType = currentKidInfo.kidGuardianType.integerValue;
    NSString *contactOpenID = cell.kidContactInfo.contactOpenID;
    NSString *userOpenID = [TYDUserInfo sharedUserInfo].openID;
    
    NSMutableArray *buttonArray = [NSMutableArray new];
    
    if([contactOpenID isEqualToString:userOpenID])
    {//点击的cell为当前账号的用户
        
        if(userContactType == TYDKidContactTypeManager)
        {//当前用户是管理员
            
            if(cell.quicklyNumberType == TYDKidContactQuickNumberNone)
            {
                [buttonArray addObjectsFromArray:@[familyNumber1st, familyNumber2nd]];
            }
            else if(cell.quicklyNumberType == TYDKidContactQuickNumber1st)
            {
                [buttonArray addObjectsFromArray:@[familyNumber2nd]];
            }
            else if(cell.quicklyNumberType == TYDKidContactQuickNumber2nd)
            {
                [buttonArray addObjectsFromArray:@[familyNumber1st]];
            }
            
            [buttonArray addObjectsFromArray:@[modifyContact]];
        }
        else if(userContactType == TYDKidContactTypeGuardian)
        {//当前用户为监护人
            
            [buttonArray addObjectsFromArray:@[modifyContact, Unbinding]];
        }
        else
        {//当前用户为普通联系人
            
        }
    }
    else
    {//点击其他联系人（非当前账号用户cell）
        
        if(userContactType == TYDKidContactTypeManager)
        {//当前用户为管理员
            
            if(cellContactType == TYDKidContactTypeManager)
            {//点击的是管理员cell
                //不可能出现
            }
            else if(cellContactType == TYDKidContactTypeGuardian)
            {
                if(cell.quicklyNumberType == TYDKidContactQuickNumberNone)
                {
                    [buttonArray addObjectsFromArray:@[familyNumber1st, familyNumber2nd]];
                }
                else if(cell.quicklyNumberType == TYDKidContactQuickNumber1st)
                {
                    [buttonArray addObjectsFromArray:@[familyNumber2nd]];
                }
                else if(cell.quicklyNumberType == TYDKidContactQuickNumber2nd)
                {
                    [buttonArray addObjectsFromArray:@[familyNumber1st]];
                }
                
                [buttonArray addObjectsFromArray:@[Unbinding, setManager]];
            }
            else
            {
                if(cell.quicklyNumberType == TYDKidContactQuickNumberNone)
                {
                    [buttonArray addObjectsFromArray:@[familyNumber1st, familyNumber2nd]];
                }
                else if(cell.quicklyNumberType == TYDKidContactQuickNumber1st)
                {
                    [buttonArray addObjectsFromArray:@[familyNumber2nd]];
                }
                else if(cell.quicklyNumberType == TYDKidContactQuickNumber2nd)
                {
                    [buttonArray addObjectsFromArray:@[familyNumber1st]];
                }
                
                [buttonArray addObjectsFromArray:@[modifyContact, deleteContact]];
            }
        }
        else
        {
            //点击cell不做任何处理
        }
    }
    
    TYDActionSheet *sheet = [[TYDActionSheet alloc] initWithTitle:sheetTitle delegate:self cancelButtonTitle:canCel otherButtonTitles:buttonArray];
    [sheet setTitleColor:[UIColor colorWithHex:0x6cbb52] fontSize:14];
    [sheet setCancelButtonTitleColor:[UIColor colorWithHex:0xf82222] bgColor:nil fontSize:14];
    
    for(int i = 0; i < buttonArray.count; i++)
    {
        [sheet setButtonTitleColor:[UIColor colorWithHex:0x686868] bgColor:nil fontSize:0 atIndex:i];
    }
    
    if(buttonArray.count > 0)
    {
        [sheet show];
    }
}

#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex;
{
    NSString *password = [alertView textFieldAtIndex:0].text;
    
    if(alertView.cancelButtonIndex != buttonIndex)
    {
        if([alertView.title isEqualToString:@"设为管理员"])
        {
            [self setupManagerWithPassword:password];
            
        }
        else if([alertView.title isEqualToString:@"解除绑定"])
        {
            NSNumber *contactType = self.userContactInfo.contactType;
            
            if(contactType.integerValue == TYDKidContactTypeManager)
            {
                //管理员解绑
                [self managerUnbindingWithPassword:password];
            }
            else if(contactType.integerValue == TYDKidContactTypeGuardian)
            {
                //监护人解绑
                [self guardianUnbindingWithPassword:password];
            }
        }
        else if([alertView.title isEqualToString:@"删除联系人"])
        {
            NSString *buttonTitle = [alertView buttonTitleAtIndex:buttonIndex];
            if([buttonTitle isEqualToString:@"确定"])
            {
                [self deleteContact];
            }
        }
    }
}

#pragma mark - TYDActionSheetDelegate

- (void)actionSheetCancel:(TYDActionSheet *)actionSheet
{
    NSLog(@"actionSheetCancel");
}

- (void)actionSheet:(TYDActionSheet *)sheet clickedButtonIndex:(NSInteger)buttonIndex
{
    NSLog(@"actionSheet:clickedButtonIndex:");
    
    NSString *buttonTitle = [sheet buttonTitleAtIndex:buttonIndex];
    
    if([buttonTitle isEqualToString:@"修改联系人"])
    {
        [self modifyContact];
    }
    else if([buttonTitle isEqualToString:@"解除绑定"])
    {
        UIAlertView *passwordDialog = [[UIAlertView alloc] initWithTitle:@"解除绑定"
                                                                 message:@"请输入密码确认"
                                                                delegate:self
                                                       cancelButtonTitle:@"取消"
                                                       otherButtonTitles:@"确定", nil];
        
        passwordDialog.alertViewStyle = UIAlertViewStylePlainTextInput;
        passwordDialog.delegate = self;
        [[passwordDialog textFieldAtIndex:0] setKeyboardType:UIKeyboardTypeNumbersAndPunctuation];
        [passwordDialog textFieldAtIndex:0].secureTextEntry = YES;
        
        [passwordDialog show];
    }
    else if([buttonTitle isEqualToString:@"设为管理员"])
    {
        UIAlertView *passwordDialog = [[UIAlertView alloc] initWithTitle:@"设为管理员"
                                                                 message:@"请输入密码确认"
                                                                delegate:self
                                                       cancelButtonTitle:@"取消"
                                                       otherButtonTitles:@"确定", nil];
        
        passwordDialog.alertViewStyle = UIAlertViewStylePlainTextInput;
        passwordDialog.delegate = self;
        [[passwordDialog textFieldAtIndex:0] setKeyboardType:UIKeyboardTypeNumbersAndPunctuation];
        [passwordDialog textFieldAtIndex:0].secureTextEntry = YES;
        
        [passwordDialog show];
    }
    else if([buttonTitle isEqualToString:@"删除联系人"])
    {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"删除联系人" message:@"是否确定删除该联系人？" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
        [alertView show];
    }
    else if([buttonTitle isEqualToString:@"快捷拨号1"])
    {
        [self cancelQuickNumber:TYDKidContactQuickNumber1st];
    }
    else if([buttonTitle isEqualToString:@"快捷拨号2"])
    {
        [self cancelQuickNumber:TYDKidContactQuickNumber2nd];
    }
}

#pragma mark - DisplayUtil

- (NSMutableAttributedString *)labelTextAttributedString:(NSString *)text  textColor:(UIColor *)textColor symbol:(NSString *)symbol symbolColor:(UIColor *)symbolColor
{
    NSMutableAttributedString *attributeString = [[NSMutableAttributedString alloc] initWithString:text attributes:@{NSForegroundColorAttributeName:textColor}];
    [attributeString setAttributes:@{NSForegroundColorAttributeName:symbolColor} range:[text rangeOfString:symbol]];
    
    return attributeString;
}

#pragma mark - OperationUtil

- (void)modifyContact
{
    TYDContactTableViewCell *cell = (TYDContactTableViewCell *)[self.tableView cellForRowAtIndexPath:self.selectIndexPath];
    
    TYDEditContactViewController *vc = [TYDEditContactViewController new];
    vc.editContactType = TYDEditContactTypeModify;
    vc.kidContactInfo = cell.kidContactInfo;
    
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)managerUnbindingWithPassword:(NSString *)password
{
    TYDContactTableViewCell *cell = (TYDContactTableViewCell *)[self.tableView cellForRowAtIndexPath:self.selectIndexPath];
    
    NSMutableDictionary *params = [NSMutableDictionary new];
    [params setValue:[TYDUserInfo sharedUserInfo].openID forKey:@"openid"];
    [params setValue:[TYDDataCenter defaultCenter].currentKidInfo.watchID forKey:@"watchid"];
    [params setValue:cell.kidContactInfo.contactOpenID forKey:@"otheruserid"];
    [params setValue:password.MD5String forKey:@"password"];
    
    [self postURLRequestWithMessageCode:ServiceMsgCodeUnbindWatchAdmin
                           HUDLabelText:nil
                                 params:params
                          completeBlock:^(id result) {
                              [self managerUnbindingSuccess:result];
                          }];
}

- (void)managerUnbindingSuccess:(id)result
{
    NSLog(@"managerUnbindingSuccess:%@", result);
    [self progressHUDHideImmediately];
    
    NSNumber *value = result[@"result"];
    
    if(value.intValue == 0)
    {
        TYDContactTableViewCell *cell = (TYDContactTableViewCell *)[self.tableView cellForRowAtIndexPath:self.selectIndexPath];
        
        [self changeGuardianToNormalContact:cell.kidContactInfo.contactID];
    }
    else if(value.intValue == 3)
    {
        self.noticeText = @"非管理员";
    }
    else if(value.intValue == 11)
    {
        self.noticeText = @"密码错误";
    }
    else
    {
        self.noticeText = @"解除绑定失败";
    }
}

- (void)changeGuardianToNormalContact:(NSString *)contactID
{
    for(TYDKidContactInfo *kidContactInfo in self.contactArray)
    {
        if([kidContactInfo.contactID isEqualToString:contactID])
        {
            kidContactInfo.contactType = @(TYDKidContactTypeNormal);
            
            [self.contactArray removeObject:kidContactInfo];
            [self.contactArray addObject:kidContactInfo];
            
            break;
        }
    }
    
    [TYDDataCenter defaultCenter].kidContactInfoList = self.contactArray.copy;
    [TYDDataCenter defaultCenter].isContactInfoListModified = YES;
    
    [self reloadTableView];
}

- (void)guardianUnbindingWithPassword:(NSString *)password
{
    NSMutableDictionary *params = [NSMutableDictionary new];
    
    [params setValue:[TYDUserInfo sharedUserInfo].openID forKey:@"openid"];
    [params setValue:[TYDDataCenter defaultCenter].currentKidInfo.watchID forKey:@"watchid"];
    [params setValue:password.MD5String forKey:@"password"];
    
    [self postURLRequestWithMessageCode:ServiceMsgCodeUnbindWatchNormal
                           HUDLabelText:nil
                                 params:params
                          completeBlock:^(id result) {
                              [self guardianUnbindingComplete:result];
                          }];
}

- (void)guardianUnbindingComplete:(id)result
{
    NSLog(@"guardianUnbindingComplete:%@", result);
    
    NSNumber *value = result[@"result"];
    [self progressHUDHideImmediately];
    
    if(value && value.intValue == 0)
    {
        TYDDataCenter *dataCenter = [TYDDataCenter defaultCenter];
        [dataCenter removeOneKidInfo:dataCenter.currentKidInfo];
        
        if(dataCenter.currentKidInfo)
        {
            [self.navigationController popToRootViewControllerAnimated:YES];
        }
        else
        {
            TYDQRCodeViewController *vc = [TYDQRCodeViewController new];
            vc.backButtonVisible = NO;
            
            [self.navigationController pushViewController:vc animated:YES];
        }
    }
    else if(value.intValue == 11)
    {
        self.noticeText = @"密码错误";
    }
    else
    {
        self.noticeText = @"解除失败";
    }
}

- (void)setupManagerWithPassword:(NSString *)password
{
    TYDContactTableViewCell *cell = (TYDContactTableViewCell *)[self.tableView cellForRowAtIndexPath:self.selectIndexPath];
    
    NSMutableDictionary *params = [NSMutableDictionary new];
    
    [params setValue:[TYDUserInfo sharedUserInfo].openID forKey:@"openid"];
    [params setValue:cell.kidContactInfo.contactOpenID forKey:@"newadminid"];
    [params setValue:[TYDDataCenter defaultCenter].currentKidInfo.watchID forKey:@"watchid"];
    [params setValue:password.MD5String forKey:@"password"];
    
    [self postURLRequestWithMessageCode:ServiceMsgCodeAdminPriorityChange
                           HUDLabelText:nil
                                 params:params
                          completeBlock:^(id result) {
                              [self setupManagerSuccess:result];
                          }];
}

- (void)setupManagerSuccess:(id)result
{
    NSLog(@"setupManagerSuccess:%@", result);
    
    NSNumber *value = result[@"result"];
    
    if(value && value.intValue == 0)
    {
        TYDContactTableViewCell *cell = (TYDContactTableViewCell *)[self.tableView cellForRowAtIndexPath:self.selectIndexPath];
        
        [TYDDataCenter defaultCenter].currentKidInfo.kidGuardianType = @(TYDKidContactTypeGuardian);
        
        [self transfromManger:self.userContactInfo.contactID toContact:cell.kidContactInfo.contactID];
    }
    else if(value.intValue == 3)
    {
        self.noticeText = @"非管理员";
    }
    else if(value.integerValue == 11)
    {
        self.noticeText = @"密码错误";
    }
    
    [self progressHUDHideImmediately];
}

- (void)transfromManger:(NSString *)managerID toContact:(NSString *)contactID
{
    [self.userContactInfoDic setValue:@(TYDKidContactTypeGuardian) forKey:@"contactType"];
    
    for(TYDKidContactInfo *kidContactInfo in self.contactArray)
    {
        if([kidContactInfo.contactID isEqualToString:contactID])
        {
            [self.contactArray removeObject:kidContactInfo];
            kidContactInfo.contactType = @(TYDKidContactTypeManager);
            [self.contactArray addObject:kidContactInfo];
            
            break;
        }
    }
    
    for(TYDKidContactInfo *kidContactInfo in self.contactArray)
    {
        if([kidContactInfo.contactID isEqualToString:managerID])
        {
            [self.contactArray removeObject:kidContactInfo];
            kidContactInfo.contactType = @(TYDKidContactTypeGuardian);
            [self.contactArray addObject:kidContactInfo];
            
            break;
        }
    }
    
    [TYDDataCenter defaultCenter].kidContactInfoList = self.contactArray.copy;
    [TYDDataCenter defaultCenter].isContactInfoListModified = YES;
    
    [self reloadTableView];
}

- (TYDKidContactInfo *)searchContactInfoWithQuickNumber:(TYDKidContactQuickNumber)numberType
{
    TYDKidContactInfo *info = nil;
    for(TYDKidContactInfo *contactInfo in self.contactArray)
    {
        if(contactInfo.quicklyNumberType.integerValue == numberType)
        {
            info = contactInfo;
            break;
        }
    }
    return info;
}

- (void)cancelQuickNumber:(TYDKidContactQuickNumber)quickNumberType
{
    TYDKidContactInfo *kidContactInfo = [self searchContactInfoWithQuickNumber:quickNumberType];
    
    NSMutableDictionary *params = [NSMutableDictionary new];
    if(kidContactInfo)
    {
        [params setValue:[TYDUserInfo sharedUserInfo].openID forKey:@"openid"];
        [params setValue:kidContactInfo.contactID forKey:@"id"];
        [params setValue:kidContactInfo.kidID forKey:@"watchid"];
        [params setValue:kidContactInfo.contactNumber forKey:@"phone"];
        [params setValue:kidContactInfo.shortNumber forKey:@"shortphone"];
        [params setValue:kidContactInfo.contactName forKey:@"userinfo"];
        [params setValue:kidContactInfo.contactAvatarID forKey:@"imgid"];
        [params setValue:@(TYDKidContactQuickNumberNone) forKey:@"familyid"];
        [params setValue:kidContactInfo.contactType forKey:@"type"];
        
        __block TYDKidContactQuickNumber quickNumber = quickNumberType;
        [self postURLRequestWithMessageCode:ServiceMsgCodeKidContactAdd
                               HUDLabelText:nil
                                     params:params
                              completeBlock:^(id result) {
                                  [self cancelQuickNumberComplete:result quickNumberType:quickNumber];
                              }];
    }
    else
    {
        [self setupQuickNumber:quickNumberType];
    }
}

- (void)cancelQuickNumberComplete:(id)result quickNumberType:(TYDKidContactQuickNumber)quickNumberType
{
    NSLog(@"cancelQuickNumberComplete:%@", result);
    
    NSNumber *value = result[@"result"];
    
    if(value && value.intValue == 0)
    {
        for(TYDKidContactInfo *kidContactInfo in self.contactArray)
        {
            if(kidContactInfo.quicklyNumberType.integerValue == quickNumberType)
            {
                [self.contactArray removeObject:kidContactInfo];
                
                kidContactInfo.quicklyNumberType = @(TYDKidContactQuickNumberNone);
                [self.contactArray addObject:kidContactInfo];
                
                [TYDDataCenter defaultCenter].kidContactInfoList = self.contactArray.copy;
                [TYDDataCenter defaultCenter].isContactInfoListModified = YES;
                
                break;
            }
        }
        
        [self setupQuickNumber:quickNumberType];
    }
    else
    {
        self.noticeText = @"设置失败";
        
        [self progressHUDHideImmediately];
    }
}

- (TYDKidContactInfo *)searchContactInfoWithContactOpenID:(NSString *)contactID
{
    TYDKidContactInfo *kidContactInfo = nil;
    
    for(TYDKidContactInfo *contactInfo in self.contactArray)
    {
        if([contactID isEqualToString:contactInfo.contactID])
        {
            kidContactInfo = contactInfo;
        }
    }
    
    return kidContactInfo;
}

- (void)setupQuickNumber:(TYDKidContactQuickNumber)quickNumberType
{
    TYDContactTableViewCell *cell = (TYDContactTableViewCell *)[self.tableView cellForRowAtIndexPath:self.selectIndexPath];
    NSString *contactID = cell.kidContactInfo.contactID;
    NSString *contactOpenID = cell.kidContactInfo.contactOpenID;
    TYDKidContactInfo *kidContactInfo = [self searchContactInfoWithContactOpenID:contactID];
    
    if(kidContactInfo)
    {
        NSMutableDictionary *params = [NSMutableDictionary new];
        
        if(contactOpenID && contactOpenID.length != 0)
        {
            [params setValue:contactOpenID forKey:@"openid"];
        }
        
        [params setValue:[TYDUserInfo sharedUserInfo].openID forKey:@"openid"];
        [params setValue:kidContactInfo.contactID forKey:@"id"];
        [params setValue:kidContactInfo.kidID forKey:@"watchid"];
        [params setValue:kidContactInfo.contactNumber forKey:@"phone"];
        [params setValue:kidContactInfo.shortNumber forKey:@"shortphone"];
        [params setValue:kidContactInfo.contactName forKey:@"userinfo"];
        [params setValue:kidContactInfo.contactAvatarID forKey:@"imgid"];
        [params setValue:@(quickNumberType) forKey:@"familyid"];
        [params setValue:kidContactInfo.contactType forKey:@"type"];
        
        __block TYDKidContactQuickNumber quickNumber = quickNumberType;
        [self postURLRequestWithMessageCode:ServiceMsgCodeKidContactAdd
                               HUDLabelText:nil
                                     params:params
                              completeBlock:^(id result) {
                                  [self setupQuickNumberComplete:result quickNumberType:quickNumber];
                              }];
    }
}

- (void)setupQuickNumberComplete:(id)result quickNumberType:(TYDKidContactQuickNumber)quickNumberType
{
    NSLog(@"setupQuickNumberComplete:%@", result);
    
    NSNumber *value = result[@"result"];
    
    if(value && value.intValue == 0)
    {
        TYDContactTableViewCell *cell = (TYDContactTableViewCell *)[self.tableView cellForRowAtIndexPath:self.selectIndexPath];
        NSString *contactID = cell.kidContactInfo.contactID;
        
        for(TYDKidContactInfo *kidContactInfo in self.contactArray)
        {
            if([kidContactInfo.contactID isEqualToString:contactID])
            {
                [self.contactArray removeObject:kidContactInfo];
                
                kidContactInfo.quicklyNumberType = @(quickNumberType);
                [self.contactArray addObject:kidContactInfo];
                
                [TYDDataCenter defaultCenter].kidContactInfoList = self.contactArray.copy;
                [TYDDataCenter defaultCenter].isContactInfoListModified = YES;
                
                break;
            }
        }
        
        [self reloadTableView];
    }
    else
    {
        self.noticeText = @"设置失败";
    }
    
    [self progressHUDHideImmediately];
}

- (void)deleteContact
{
    TYDKidInfo *currentKidInfo = [TYDDataCenter defaultCenter].currentKidInfo;
    TYDContactTableViewCell *cell = (TYDContactTableViewCell *)[self.tableView cellForRowAtIndexPath:self.selectIndexPath];
    NSString *contactID = cell.kidContactInfo.contactID;
    
    NSMutableDictionary *params = [NSMutableDictionary new];
    [params setValue:[TYDUserInfo sharedUserInfo].openID forKey:@"openid"];
    [params setValue:currentKidInfo.watchID forKey:@"watchid"];
    [params setValue:contactID forKey:@"id"];
    
    [self postURLRequestWithMessageCode:ServiceMsgCodeKidContactDelete
                           HUDLabelText:nil
                                 params:params
                          completeBlock:^(id result) {
                              [self deleteContactSuccess:result];
                          }];
}

- (void)getContactListFromServer
{
    [self progressHUDShowWithText:nil];
    
    NSMutableDictionary *params = [NSMutableDictionary new];
    
    [params setValue:[TYDDataCenter defaultCenter].currentKidInfo.watchID forKey:@"watchid"];
    
    [self postURLRequestWithMessageCode:ServiceMsgCodeKidContactRequest
                           HUDLabelText:nil
                                 params:params
                          completeBlock:^(id result) {
                              [self getContactListComplete:result];
                          }];
}

- (void)deleteContactSuccess:(id)result
{
    NSLog(@"deleteContactSuccess:%@", result);
    [self progressHUDHideImmediately];
    
    NSString *resultString = result[@"result"];
    
    if(resultString && resultString.intValue == 0)
    {
        TYDContactTableViewCell *cell = (TYDContactTableViewCell *)[self.tableView cellForRowAtIndexPath:self.selectIndexPath];
        NSString *contactID = cell.kidContactInfo.contactID;
        
        for(TYDKidContactInfo *kidContactInfo in self.contactArray)
        {
            NSLog(@"kidContactInfo.contactID:%@", kidContactInfo.contactID);
        }
        
        TYDKidContactInfo *contactInfo = nil;
        for(TYDKidContactInfo *kidContactInfo in self.contactArray)
        {
            if([kidContactInfo.contactID isEqualToString:contactID])
            {
                contactInfo = kidContactInfo;
                break;
            }
        }
        if(contactInfo)
        {
            [self.contactArray removeObject:contactInfo];
            
            [TYDDataCenter defaultCenter].kidContactInfoList = self.contactArray.copy;
            [TYDDataCenter defaultCenter].isContactInfoListModified = YES;
            [self reloadTableView];
        }
    }
}

- (void)getContactListComplete:(id)result
{
    NSLog(@"getContactListComplete:%@", result);
    
    [self progressHUDHideImmediately];
    
    NSNumber *value = result[@"result"];
    if(value && value.intValue == 0)
    {
        NSArray *contactInfoDicArray = result[@"contact"];
        NSMutableArray *contactInfoList = [NSMutableArray new];
        for(NSDictionary *contactInfoDic in contactInfoDicArray)
        {
            TYDKidContactInfo *info = [TYDKidContactInfo new];
            [info setAttributes:contactInfoDic];
            [contactInfoList addObject:info];
        }
        
        contactInfoList = [self contactSortHandle:contactInfoList].mutableCopy;
        
        [TYDDataCenter defaultCenter].kidContactInfoList = contactInfoList;
        self.contactArray = contactInfoList.mutableCopy;
        [self contactDivisiveHandle];
        [self.tableView reloadData];
    }
    else
    {
        self.noticeText = @"获取联系人失败";
    }
}

- (NSArray *)contactSortHandle:(NSArray *)contactArray
{
    //Sort data
    UILocalizedIndexedCollation *theCollation = [UILocalizedIndexedCollation currentCollation];
    NSArray *sortedArray = [theCollation sortedArrayFromArray:contactArray collationStringSelector:@selector(contactName)];
    
    return sortedArray;
}

- (void)contactDivisiveHandle
{
    NSString *userOpenID = [TYDUserInfo sharedUserInfo].openID;
    self.otherContactArray = self.contactArray.mutableCopy;
    
    TYDKidContactInfo *meContactInfo = nil;
    for(TYDKidContactInfo *kidContactInfo in self.contactArray)
    {
        if([kidContactInfo.contactOpenID isEqualToString:userOpenID])
        {
            meContactInfo = kidContactInfo;
            break;
        }
    }
    if(meContactInfo)
    {
        self.userContactInfo = meContactInfo;
        [self.otherContactArray removeObject:meContactInfo];
    }
}

@end
