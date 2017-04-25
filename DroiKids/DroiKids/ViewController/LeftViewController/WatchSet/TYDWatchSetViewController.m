//
//  TYDWatchSetViewController.m
//  DroiKids
//
//  Created by superjunjun on 15/8/10.
//  Copyright (c) 2015年 superjunjun. All rights reserved.
//

#import "TYDWatchSetViewController.h"
#import "TYDSetClassTimeController.h"
#import "TYDActionSheet.h"
#import "TYDWatchInfo.h"
#import "TYDDataCenter.h"

@interface TYDWatchSetViewController () <TYDActionSheetDelegate , UIAlertViewDelegate>

@property (strong, nonatomic) IBOutlet UITableView  *appSetTableView;
@property (strong, nonatomic) IBOutlet UISwitch     *autoConnectSwitch;
@property (strong, nonatomic) IBOutlet UISwitch     *classMuteSwitch;
@property (strong, nonatomic) IBOutlet UILabel      *screenLightTimeLabel;
@property (strong, nonatomic) IBOutlet UILabel      *GPSAcquisitionTimeLabel;
@property (strong, nonatomic) IBOutlet UISwitch     *messageRing;
@property (strong, nonatomic) IBOutlet UISwitch     *messageVibrate;
@property (strong, nonatomic) TYDKidInfo            *currentkidInfo;
@property (strong, nonatomic) NSNumber              *lightTime;
@property (strong, nonatomic) NSNumber              *capInterval;

@property (strong, nonatomic) NSNumber *autoConnectState;    //手表自动接通 0  关  1 开
@property (strong, nonatomic) NSNumber *silentState;         //静音状态   0  关  1  开
@property (strong, nonatomic) NSString *silentTime;          //静音时间段，中间空格隔开
@property (strong, nonatomic) NSNumber *backlightTime;       //背光时间  min
@property (strong, nonatomic) NSNumber *watchSoundState;     //铃声  0 关  1  开
@property (strong, nonatomic) NSNumber *watchShockState;     //震动 0 关  1  开
//@property (strong, nonatomic) NSNumber *capInterval;              //手表上传位置信息的间隔时间  min

@end

@implementation TYDWatchSetViewController

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
}

- (void)localDataInitialize
{
   self.currentkidInfo = [[TYDDataCenter defaultCenter]currentKidInfo];
}

- (void)navigationBarItemsLoad
{
    self.titleText = @"手表设置";
}

- (void)subviewsLoad
{
    self.appSetTableView.showsVerticalScrollIndicator = NO;
    self.autoConnectSwitch.onTintColor = cBasicGreenColor;
    self.classMuteSwitch.onTintColor = cBasicGreenColor;
    self.messageRing.onTintColor = cBasicGreenColor;
    self.messageVibrate.onTintColor = cBasicGreenColor;
    
    self.autoConnectSwitch.on = [self.currentkidInfo.autoConnectState boolValue];
    self.classMuteSwitch.on = [self.currentkidInfo.silentState boolValue];
    self.messageRing.on = [self.currentkidInfo.watchSoundState boolValue];
    self.messageVibrate.on = [self.currentkidInfo.watchShockState boolValue];
    self.GPSAcquisitionTimeLabel.text = [self.currentkidInfo.capInterval integerValue] < 60 ?[NSString stringWithFormat:@"每%@分钟",self.currentkidInfo.capInterval]:[NSString stringWithFormat:@"每%ld小时",([self.currentkidInfo.capInterval integerValue] / 60)];
    self.screenLightTimeLabel.text = [NSString stringWithFormat:@"%@s",self.currentkidInfo.backlightTime];
    self.silenceTimeString = self.currentkidInfo.silentTime;
    self.lightTime = self.currentkidInfo.backlightTime;
    self.capInterval = self.currentkidInfo.capInterval;
}

#pragma mark - UITableViewDataSource & UITableViewDelegate

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.section == 0
       ||(indexPath.section == 2 && indexPath.row != 0))
    {
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
}

- (CGFloat )tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 26;
}

- (CGFloat )tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    if(section == 3)
    {
        return 30;
    }
    else
    {
        return 0.01;
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    return [UIView new];
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    CGRect frame = tableView.bounds;
    frame.size.height = 26;
    NSArray *headerNameArray = @[@"个性通话", @"远程控制", @"声音与显示", @"其他"];
    UIView *headerView = [[UIView alloc] initWithFrame:frame];
    headerView.backgroundColor = cBasicBackgroundColor;
    
    UILabel *titleLabel = [UILabel new];
    titleLabel.backgroundColor = [UIColor clearColor];
    titleLabel.font = [BOAssistor defaultTextStringFontWithSize:12];
    titleLabel.textColor = [UIColor grayColor];
    titleLabel.text = headerNameArray[section];
    [titleLabel sizeToFit];
    titleLabel.center = headerView.innerCenter;
    titleLabel.left = 15;
    titleLabel.top += 2;
    [headerView addSubview:titleLabel];
    
    return headerView;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if(indexPath.section == 1 && indexPath.row == 0)
    {
        TYDSetClassTimeController *vc = [TYDSetClassTimeController new];
        NSArray *array = [self.silenceTimeString componentsSeparatedByString:@" "];
        if(array.count == 3)
        {
            NSString *weekString = array.firstObject;
            NSArray *mArray = [array[1] componentsSeparatedByString:@"-"];
            NSArray *aArray = [array.lastObject componentsSeparatedByString:@"-"];
//            NSString *aStartString = aArray.firstObject;
//            NSString *aEndString = aArray.lastObject;
//            NSDate *aStartDate = [self dateFromTimeString:aStartString];
//            NSDate *aEndDate = [self dateFromTimeString:aEndString];
//            
//            NSDate *aStartDateNew = [aStartDate dateByAddingTimeInterval:12*60*60];
//            NSDate *aEndDateNew = [aEndDate dateByAddingTimeInterval:12*60*60];
//            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
//            dateFormatter.dateFormat = @"HH:mm";
//            NSString *aStartStringNew = [dateFormatter stringFromDate:aStartDateNew];
//            NSString *aEndStringNew = [dateFormatter stringFromDate:aEndDateNew];
            
            vc.mStartString = mArray.firstObject;
            vc.mEndString = mArray.lastObject;
            vc.aStartString = aArray.firstObject;
            vc.aEndString = aArray.lastObject;
            vc.weekString = weekString;
            [self.navigationController pushViewController:vc animated:YES];
        }
    }
    else if(indexPath.section == 2 && indexPath.row == 0)
    {
        NSArray *actionArray = @[@"2S", @"5S", @"10S"];
        
        TYDActionSheet *actionSheet = [[TYDActionSheet alloc] initWithTitle:@"亮屏时间" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:actionArray];
        
        [actionSheet setTitleColor:[UIColor colorWithHex:0x6cbb52] fontSize:14];
        [actionSheet setCancelButtonTitleColor:[UIColor colorWithHex:0xf82222] bgColor:nil fontSize:14];
        
        for(int i = 0; i < actionArray.count; i++)
        {
            [actionSheet setButtonTitleColor:[UIColor colorWithHex:0x686868] bgColor:nil fontSize:0 atIndex:i];
        }
        
        [actionSheet show];
    }
    if(indexPath.section == 3 && indexPath.row == 0)
    {
        NSArray *actionArray = @[@"每15分钟", @"每30分钟", @"每1小时", @"每2小时", @"每3小时"];
        
        TYDActionSheet *actionSheet = [[TYDActionSheet alloc] initWithTitle:@"GPS收集时间" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:actionArray];
        
        [actionSheet setTitleColor:[UIColor colorWithHex:0x6cbb52] fontSize:14];
        [actionSheet setCancelButtonTitleColor:[UIColor colorWithHex:0xf82222] bgColor:nil fontSize:14];
        
        for(int i = 0; i < actionArray.count; i++)
        {
            [actionSheet setButtonTitleColor:[UIColor colorWithHex:0x686868] bgColor:nil fontSize:0 atIndex:i];
        }
        
        [actionSheet show];
    }
}

- (NSDate *)dateFromTimeString:(NSString *)string
{
    NSDateFormatter *dateFormatter = [NSDateFormatter new];
    dateFormatter.dateFormat = @"HH:mm";
    NSDate *date = [dateFormatter dateFromString:string];
    return date;
}


#pragma mark - TouchEvent

- (IBAction)autoConnectSwitchTap:(UISwitch *)sender
{
    self.autoConnectSwitch.on = sender.on;
}

- (IBAction)classMuteSwitchTap:(UISwitch *)sender
{
    self.classMuteSwitch.on = sender.on;
}

- (IBAction)messageRingSwitchTap:(UISwitch *)sender
{
    self.messageRing.on = sender.on;
}

- (IBAction)messageVibrateSwitchTap:(UISwitch *)sender
{
    self.messageVibrate.on = sender.on;
}

#pragma mark - TYDActionSheetDelegate

- (void)actionSheetCancel:(TYDActionSheet *)actionSheet
{

}

- (void)actionSheet:(TYDActionSheet *)sheet clickedButtonIndex:(NSInteger)buttonIndex
{
    NSString *titleString = [sheet buttonTitleAtIndex:buttonIndex];
    
    if([sheet.title isEqualToString:@"亮屏时间"])
    {
        self.screenLightTimeLabel.text = titleString;
        self.lightTime = @[@(2), @(5), @(10)][buttonIndex];
    }
    else if([sheet.title isEqualToString:@"GPS收集时间"])
    {
        self.GPSAcquisitionTimeLabel.text = titleString;
        self.capInterval = @[@(15), @(30), @(60), @(120), @(180)][buttonIndex];
    }
}

#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(buttonIndex != alertView.cancelButtonIndex)
    {
        NSString *buttonTitle = [alertView buttonTitleAtIndex:buttonIndex];
        
        if([buttonTitle isEqualToString:@"保存"])
        {
            [self watchSetDetailUploadServer];
        }
    }
    else
    {
        [super popBackEventWillHappen];
    }
}

- (void)popBackEventWillHappen
{
    if(self.autoConnectSwitch.on == [self.currentkidInfo.autoConnectState boolValue]
       && self.classMuteSwitch.on == [self.currentkidInfo.silentState boolValue]
       && self.messageRing.on == [self.currentkidInfo.watchSoundState boolValue]
       && self.messageVibrate.on == [self.currentkidInfo.watchShockState boolValue]
       && self.lightTime == self.currentkidInfo.backlightTime
       && self.capInterval == self.currentkidInfo.capInterval
       && [self.silenceTimeString isEqualToString:self.currentkidInfo.silentTime]
       )
    {
        [super popBackEventWillHappen];
    }
    else
    {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"手表设置" message:@"手表设置已修改，是否保存" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"保存", nil];
        
        [alertView show];
    }
}

#pragma mark - WatchSetDetailUploadServer

- (void)watchSetDetailUploadServer
{
    TYDKidInfo *kidInfo = self.currentkidInfo;
    NSNumber *autoConnectState = self.autoConnectSwitch.on ? @(1) : @(0);;
    NSNumber *silentState = self.classMuteSwitch.on ? @(1) : @(0);
    NSNumber *watchSoundState = self.messageRing.on ? @(1) : @(0);
    NSNumber *watchShockState = self.messageVibrate.on ? @(1) : @(0);
    NSNumber *capInterval = self.capInterval;
    NSNumber *backlightTime = self.lightTime;
    NSString *silentTime = self.silenceTimeString;
    NSDictionary *params = @{ @"childid"              :kidInfo.kidID,
                              @"childname"            :kidInfo.kidName,
                              @"phone"                :kidInfo.phoneNumber,
                              @"sex"                  :kidInfo.kidGender,
                              @"birthday"             :kidInfo.kidBirthday,
                              @"weight"               :kidInfo.kidWeight,
                              @"height"               :kidInfo.kidHeight,
                              @"color"                :kidInfo.kidColorType,
                              @"address"              :kidInfo.homeAddress,
                              @"school"               :kidInfo.schoolAddress,
                              @"img"                  :kidInfo.kidAvatarPath,
                              @"relationship"         :kidInfo.kidGuardianRelationShip,
                              @"type"                 :kidInfo.kidGuardianType,
                              @"watchid"              :kidInfo.watchID,
                              @"autoconnect"          :autoConnectState,
                              @"silentstatus"         :silentState,
                              @"silenttime"           :silentTime,
                              @"backlighttime"        :backlightTime,
                              @"watchsound"           :watchSoundState,
                              @"watchshock"           :watchShockState,
                              @"cpinterval"           :capInterval,
                              @"electronicfence"      :kidInfo.electronicFenceState,
                              @"electronicFencePoints":kidInfo.fenceCenterPoint,
                              @"radius"               :kidInfo.fenceRadius,
                              @"castoff"              :kidInfo.castOff
                              };

    [self postURLRequestWithMessageCode:ServiceMsgCodeKidInfoUpdate
                           HUDLabelText:nil
                                 params:[params mutableCopy]
                          completeBlock:^(id result) {
                              [self saveFenceToSeviceComplete:result];
                          }];

}

- (void)saveFenceToSeviceComplete:(id)result
{
    NSLog(@"saveCollectionPointToServerComplete:%@", result);
    NSNumber *resultCode = result[@"result"];
    
    if(resultCode != nil
       && resultCode.intValue == 0)
    {
        self.currentkidInfo.autoConnectState = self.autoConnectSwitch.on ? @(1) : @(0);;
        self.currentkidInfo.silentState = self.classMuteSwitch.on ? @(1) : @(0);
        self.currentkidInfo.watchSoundState = self.messageRing.on ? @(1) : @(0);
        self.currentkidInfo.watchShockState = self.messageVibrate.on ? @(1) : @(0);
        self.currentkidInfo.capInterval = self.capInterval;
        self.currentkidInfo.backlightTime = self.lightTime;
        self.currentkidInfo.silentTime = self.silenceTimeString;
        
        [self progressHUDShowWithCompleteText:@"保存设置成功" isSucceed:YES additionalTarget:self action:@selector(popBackEventWillHappen) object:@YES];
    }
    else
    {
        [self progressHUDShowWithCompleteText:@"保存设置失败" isSucceed:NO];
    }
}

@end
