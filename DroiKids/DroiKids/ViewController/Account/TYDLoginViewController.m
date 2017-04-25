//
//  TYDLoginViewController.m
//   Dorikids
//
//  Created by macMini_Dev on 15-8-20.
//
//  登录页
//

#import "TYDLoginViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "TYDEnrollViewController.h"
#import "TYDFindPwdViewController.h"
#import "TYDDrawerViewController.h"
#import "TYDMainViewController.h"
#import "TYDQRCodeViewController.h"
#import "TYDBindAuthorizeController.h"
//#import "TYDChoseBundingStyleController.h"

#import "TYDAppProfileController.h"

#import "TYDDataCenter.h"
#import "TYDKidMessageInfo.h"
#import "TYDAMPostUrlRequest.h"
#import "SBJson.h"
#import "NSString+MD5Addition.h"
#import "OpenPlatformAppRegInfo.h"
#import "AppDelegate.h"

#define sActionSheetCancel               @"取消"
#define sMobileNumberRegister            @"手机账户注册"
#define sEmailRegister                   @"邮箱注册"
#define sMobilePhoneUser                 @"手机用户"
#define sEmailUser                       @"邮箱用户"

const NSString *loginViewControllerIdentifier = @"loginViewController";

@interface TYDLoginViewController () <TYDEnrollViewControllerDelegate, TYDAppProfileControllerDelegate>
{
    BOOL _isAppProfileVisible;
}

@property (strong, nonatomic) NSDictionary *userInfoDic;
@property (strong, nonatomic) NSString *openID;
@property (assign, nonatomic) UIButton *pwdVisibleButton;
@property (assign, nonatomic) BOOL isEnrollSucceed;

@end

@implementation TYDLoginViewController

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
    if(_isAppProfileVisible)
    {
        _isAppProfileVisible = NO;
        [self appProfileViewLoad];
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    if(self.isEnrollSucceed)
    {
        self.isEnrollSucceed = NO;
        [self login];
    }
}

- (void)localDataInitialize
{
    self.isNeedToHideNavigationBar = NO;
    [self launchTimeInfoCheck];
}

- (void)launchTimeInfoCheck
{
    NSString *markKey = sFirstTimeLaunchedMarkKey;
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    BOOL isFirstTimeToLaunch = ![userDefaults boolForKey:markKey];
    //isFirstTimeToLaunch = YES;//Test
    if(isFirstTimeToLaunch)
    {
        [[UIApplication sharedApplication] cancelAllLocalNotifications];
        [userDefaults setBool:YES forKey:markKey];
        [userDefaults synchronize];
    }
    _isAppProfileVisible = isFirstTimeToLaunch;
}

- (void)navigationBarItemsLoad
{
    self.title = @"登录";    
//    UIButton *enrollButton = [UIButton new];
//    [enrollButton setTitle:@"注册" forState:UIControlStateNormal];
//    [enrollButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
//    [enrollButton setTitleColor:[UIColor grayColor] forState:UIControlStateHighlighted];
//    [enrollButton setTitleColor:[UIColor grayColor] forState:UIControlStateDisabled];
//    [enrollButton addTarget:self action:@selector(enrollButtonTap:) forControlEvents:UIControlEventTouchUpInside];
//    [enrollButton sizeToFit];
//    UIBarButtonItem *enrollBtnItem = [[UIBarButtonItem alloc] initWithCustomView:enrollButton];
//    self.navigationItem.rightBarButtonItem = enrollBtnItem;
}

- (void)subviewsLoad
{
    [self inputViewsLoad];
    [self buttonViewsLoad];
}

- (void)inputViewsLoad
{
    CGFloat top = self.baseViewBaseHeight + 30;
    CGFloat sideOffset = 17;
    CGFloat innerLeftOffset = 8;
    
    CGRect frame = CGRectMake(sideOffset, top, self.baseView.width - sideOffset * 2, 10);
    UIControl *baseView = [[UIControl alloc] initWithFrame:frame];
    baseView.backgroundColor = [UIColor clearColor];
    [baseView addTarget:self action:@selector(tapOnSpace:) forControlEvents:UIControlEventTouchUpInside];
    [self.baseView addSubview:baseView];
    
    UIView *grayLine1 = [UIView new];
    grayLine1.size = CGSizeMake(baseView.width, 0.5);
    grayLine1.backgroundColor = [UIColor colorWithHex:0xdfdfdf];
    [baseView addSubview:grayLine1];
    
    UIFont *textFont = [UIFont fontWithName:@"Arial" size:14];
    UIColor *textColor = [UIColor colorWithHex:0x323232];
    CGSize textFieldSize = CGSizeMake(baseView.width - 9, 30);//baseView.width - innerLeftOffset
    
    UITextField *accountTextField = [UITextField new];
    accountTextField.placeholder = @"输入手机号";
    accountTextField.font = textFont;
    accountTextField.textColor = textColor;
    accountTextField.borderStyle = UITextBorderStyleNone;
    accountTextField.returnKeyType = UIReturnKeyNext;//Return键
    accountTextField.keyboardType = UIKeyboardTypeNumbersAndPunctuation;
    accountTextField.autocorrectionType = UITextAutocorrectionTypeNo;
    accountTextField.secureTextEntry = NO;
    accountTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
    accountTextField.autocapitalizationType = UITextAutocapitalizationTypeNone;
    accountTextField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    accountTextField.leftViewMode = UITextFieldViewModeAlways;
    [accountTextField addTarget:self action:@selector(textFiledEditEndOnExit:) forControlEvents:UIControlEventEditingDidEndOnExit];
    accountTextField.size = textFieldSize;
    [baseView addSubview:accountTextField];
    
    UITextField *passwordTextField = [UITextField new];
    passwordTextField.placeholder = @"输入密码";
    passwordTextField.font = textFont;
    passwordTextField.textColor = textColor;
    passwordTextField.borderStyle = UITextBorderStyleNone;
    passwordTextField.returnKeyType = UIReturnKeyDone;
    passwordTextField.keyboardType = UIKeyboardTypeNumbersAndPunctuation;
    passwordTextField.autocorrectionType = UITextAutocorrectionTypeNo;
    passwordTextField.secureTextEntry = YES;
    passwordTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
    passwordTextField.autocapitalizationType = UITextAutocapitalizationTypeNone;
    passwordTextField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    passwordTextField.leftViewMode = UITextFieldViewModeAlways;
    [passwordTextField addTarget:self action:@selector(textFiledEditEndOnExit:) forControlEvents:UIControlEventEditingDidEndOnExit];
    passwordTextField.size = textFieldSize;
    [baseView addSubview:passwordTextField];
    
    [self.textInputViews appendOneTextInputView:accountTextField];
    [self.textInputViews appendOneTextInputView:passwordTextField];
    
    grayLine1.left = 0;
    accountTextField.left = innerLeftOffset;
    passwordTextField.left = innerLeftOffset;
    
    accountTextField.top = 10;//0
    grayLine1.top = accountTextField.bottom + 2;
    passwordTextField.top = grayLine1.bottom + 10;
    
    baseView.backgroundColor = [UIColor colorWithHex:0xffffff];
    baseView.height = passwordTextField.bottom + 2;
    [baseView.layer setCornerRadius:8];
    
    UIButton *pwdVisibleButton = [[UIButton alloc] initWithImage:[UIImage imageNamed:@"login_pwdInvisible"] highlightedImage:[UIImage imageNamed:@"login_pwdVisible"] givenButtonSize:CGSizeMake(30, 30)];
    [pwdVisibleButton addTarget:self action:@selector(pwdVisibleButtonTap:) forControlEvents:UIControlEventTouchUpInside];
    [pwdVisibleButton setImage:[UIImage imageNamed:@"login_pwdVisible"] forState:UIControlStateSelected];
    pwdVisibleButton.center = passwordTextField.center;
    pwdVisibleButton.right = baseView.width - 5;
    [baseView addSubview:pwdVisibleButton];
    passwordTextField.width = pwdVisibleButton.left - passwordTextField.left - 2;
    self.pwdVisibleButton = pwdVisibleButton;
    
    self.baseViewBaseHeight = baseView.bottom;
}

- (void)buttonViewsLoad
{
    CGFloat top = self.baseViewBaseHeight;
    UIView *baseView = self.baseView;
    CGPoint center = baseView.innerCenter;

    UIButton *findPasswordButton = [UIButton new];
    findPasswordButton.titleLabel.font = [UIFont systemFontOfSize:12];
    [findPasswordButton setTitle:@"忘记密码" forState:UIControlStateNormal];
    [findPasswordButton setTitleColor:[UIColor colorWithHex:0x6cbb52] forState:UIControlStateNormal];
    [findPasswordButton addTarget:self action:@selector(findPasswordButtonTap:) forControlEvents:UIControlEventTouchUpInside];
    [findPasswordButton sizeToFit];
    
    findPasswordButton.top = top + 1;
    findPasswordButton.right = baseView.width - 18;
    [baseView addSubview:findPasswordButton];
    
    
    UIEdgeInsets capInsets = UIEdgeInsetsMake(10, 10, 10, 10);
    UIButton *loginButton = [[UIButton alloc] initWithImageName:@"login_btn" highlightedImageName:@"login_btnH" capInsets:capInsets givenButtonSize:CGSizeMake(self.view.width-34, 40) title:@"登录" titleFont:[UIFont fontWithName:@"Arial" size:18] titleColor:UIColorWithHex(0xffffff)];
    [loginButton addTarget:self action:@selector(loginButtonTap:) forControlEvents:UIControlEventTouchUpInside];
    loginButton.center = center;
    loginButton.top = top + 85;
    [baseView addSubview:loginButton];
    
    UIButton *enrollButton = [UIButton new];
    [enrollButton setTitle:@"注册" forState:UIControlStateNormal];
    [enrollButton setTitleColor:[UIColor colorWithHex:0x6cbb52] forState:UIControlStateNormal];
    [enrollButton setTitleColor:[UIColor grayColor] forState:UIControlStateHighlighted];
    [enrollButton setTitleColor:[UIColor grayColor] forState:UIControlStateDisabled];
    [enrollButton addTarget:self action:@selector(enrollButtonTap:) forControlEvents:UIControlEventTouchUpInside];
    [enrollButton sizeToFit];
    enrollButton.center = center;
    enrollButton.bottom =  self.view.height - 30 - 44;
    [baseView addSubview:enrollButton];

    self.baseViewBaseHeight = enrollButton.bottom + 20;
}

- (void)appProfileViewLoad
{
    self.navigationController.navigationBarHidden = YES;
    
    UIViewController *baseViewController = self;
    UIView *baseView = baseViewController.view;
    
    TYDAppProfileController *appProfileVC = [TYDAppProfileController new];
    appProfileVC.delegate = self;
    [baseViewController addChildViewController:appProfileVC];
    
    UIView *welcomeView = appProfileVC.view;
    welcomeView.frame = baseView.bounds;
    [baseView addSubview:welcomeView];
}

#pragma mark - TouchEvent

- (void)textFiledEditEndOnExit:(UITextField *)sender
{
    [self.textInputViews nextTextInputViewBecomeFirstResponder:sender];
}

- (void)enrollButtonTap:(UIButton *)sender
{
    NSLog(@"enrollButtonTap");
    [self.textInputViews allTextInputViewsResignFirstResponder];
    
    TYDEnrollViewController *vc = [TYDEnrollViewController new];
    vc.delegate = self;
    [self.navigationController pushViewController:vc animated:YES];
    
}

- (void)pwdVisibleButtonTap:(id)sender
{
    self.pwdVisibleButton.selected = !self.pwdVisibleButton.selected;
    UITextField *pwdTextfield = [self.textInputViews objectInTextInputViewsAtIndex:1];
    [pwdTextfield becomeFirstResponder];
    if(self.pwdVisibleButton.selected)
    {
        pwdTextfield.secureTextEntry = NO;
    }
    else
    {
        pwdTextfield.secureTextEntry = YES;
    }
}

- (void)findPasswordButtonTap:(UIButton *)sender
{
    NSLog(@"findPasswordButtonTap");
    [self.textInputViews allTextInputViewsResignFirstResponder];
    TYDFindPwdViewController *vc = [TYDFindPwdViewController new];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)loginButtonTap:(UIButton *)sender
{
    NSLog(@"loginButtonTap");
    [self.textInputViews allTextInputViewsResignFirstResponder];

    [self login];
//    [self loginActionSucceed];
}

#pragma mark - LoginActionSucceed

- (void)loginActionSucceed
{
    UINavigationController *mainNavigationController = [self.storyboard instantiateViewControllerWithIdentifier:@"mainNavigationController"];
    AppDelegate *delagete = [UIApplication sharedApplication].delegate;
    
    [UIView transitionFromView:delagete.window.rootViewController.view toView:mainNavigationController.view duration:.5 options:UIViewAnimationOptionTransitionCrossDissolve completion:^(BOOL finished) {
        [delagete.window setRootViewController:mainNavigationController];
    }];
}

#pragma mark - ConnectToServer

//登录
//lapi/login
//
//base_param:
//
//uid:用户名
//passwd:密码的MD5值
//utype:[zhuoyou]
//devinfo:设备信息
//sign:签名
//
//签名计算：[uid passwd utype devinfo]

- (void)login
{
    UITextField *accountTextField = [self.textInputViews objectInTextInputViewsAtIndex:0];
    UITextField *passwordTextField = [self.textInputViews objectInTextInputViewsAtIndex:1];
    NSString *account = accountTextField.text;
    NSString *password = passwordTextField.text;
    
    NSString *message = nil;
    if(![self networkIsValid])
    {
        message = sNetworkFailed;
    }
    else if(account.length == 0
            || password.length == 0)
    {
        message = @"请输入账号及密码";
    }
    else if(![BOAssistor passwordLengthIsValid:password])
    {
        message = @"密码长度6~48位";
    }
    
    if(message)
    {
        self.noticeText = message;
    }
    else
    {
        password = password.MD5String;
        NSMutableDictionary *params = [NSMutableDictionary dictionary];
        NSString *userType = [NSString new];
        
        if([BOAssistor phoneNumberIsValid:account])
        {
            [params setValue:sAMPhoneNumberLogin forKey:sAMUserLoginStyle];
            userType = sAMLoginUserTypeZhuoyou;
        }
        else if([BOAssistor emailIsValid:account])
        {
            [params setValue:sAMEmailAccountLogin forKey:sAMUserLoginStyle];
            userType = sAMLoginUserTypeEmail;
        }
        
        NSString *deviceInfo = [TYDAMPostUrlRequest deviceInfoEncode:[BOAssistor deviceUDID]];
        NSString *sign = [TYDAMPostUrlRequest signInfoCreateWithInfos:@[account, password, userType, deviceInfo]];
        
        [params setValue:account forKey:@"uid"];
        [params setValue:password forKey:@"passwd"];
        [params setValue:userType forKey:@"utype"];
        [params setValue:deviceInfo forKey:@"devinfo"];
        [params setValue:sign forKey:@"sign"];
        
        [self progressHUDShowWithText:nil];
        [TYDAMPostUrlRequest amRequestWithURL:sAMServiceUrlLogin
                                       params:params
                                completeBlock:^(id result) {
                                    [self loginComplete:result];
                                }
                                  failedBlock:^(NSString *url, id result) {
                                      [self amPostHttpRequestFailed:url result:result];
                                  }];
    }
}

//与服务器交互
- (void)userInfoDownloadWithOpenID:(NSString *)openID
{
    NSMutableDictionary *params = [NSMutableDictionary new];
    [params setValue:openID forKey:sPostUrlRequestUserOpenIDKey];
    
    [self postURLRequestWithMessageCode:ServiceMsgCodeGuardianInfoRequest
                           HUDLabelText:nil
                                 params:params
                          completeBlock:^(id result) {
                              [self userInfoDownloadComplete:result];
                          }];
}

//用户信息上传
//用户首次登录时，服务器无默认信息，需自行上传
- (void)userInfoUpload
{
    UITextField *accountTextField = [self.textInputViews objectInTextInputViewsAtIndex:0];
    UITextField *passwordTextField = [self.textInputViews objectInTextInputViewsAtIndex:1];
    NSDictionary *infoTempleDic = self.userInfoDic;
//    NSString *userID = @"";
    NSString *openID = infoTempleDic[@"openid"];
    NSString *username = infoTempleDic[@"username"];
    NSString *password = passwordTextField.text.MD5String;
    NSString *nickname = infoTempleDic[@"nickname"];
    NSString *phone = accountTextField.text;
//    NSString *status = @"";
    NSString *description = @"";
    NSString *deviceToken = [[NSUserDefaults standardUserDefaults]objectForKey:sRemoteNotificationDeviceToken];
    if(!deviceToken)
    {
        deviceToken = @"NoToken";
    }
    
    self.userInfoDic =
    @{
//        @"userid"       :@"",
        @"openid"       :openID,
        @"username"     :username,
        @"password"     :password,
        @"nickname"     :nickname,
        @"phone"        :phone,
        @"shortphone"   :@"",
//        @"status"       :status,
        @"description"  :description,
        @"phonetype"    :@2,
        @"deviceid"     :deviceToken
    };
    
    NSMutableDictionary *params = [self.userInfoDic mutableCopy];
    [self postURLRequestWithMessageCode:ServiceMsgCodeGuardianInfoUpdate
                           HUDLabelText:nil
                                 params:params
                          completeBlock:^(id result) {
                              [self userInfoUploadComplete:result];
                          }];
}

- (void)loadBabyInfoWithOpenID:(NSString *)openid
{
    NSMutableDictionary *params = [NSMutableDictionary new];
    [params setValue:openid forKey:sPostUrlRequestUserOpenIDKey];
    [self postURLRequestWithMessageCode:ServiceMsgCodeKidListInfoDownload
                           HUDLabelText:nil
                                 params:params
                          completeBlock:^(id result) {
                              [self babyInfoDownloadComplete:result];
                          }];
    
}

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


#pragma mark - ServerConnectionReceipt

- (void)parseUseNotificationInfo:(id)result
{
    NSLog(@"parseUseLocationInfoComplete:%@", result);
    NSDictionary *dic = result;
    NSNumber *resultCode = result[@"result"];
    [self progressHUDHideImmediately];
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
                messageInfo.messageUnreadFlag = @(0);
                messageInfo.messageContent = contentString;
                messageInfo.infoType = @([contentDic[@"operatecode"] intValue]);
                messageInfo.infoCreateTime = detailDic[@"createtime"];
                [[TYDDataCenter defaultCenter]saveMessageInfo:messageInfo];
            }
        }
    }
    [self progressHUDShowWithCompleteText:@"登录成功" isSucceed:YES additionalTarget:self action:@selector(loginActionSucceed) object:nil];
}

- (void)amPostHttpRequestFailed:(NSString *)url result:(id)result
{
    [self progressHUDHideImmediately];
    self.noticeText = sNetworkError;
    
    NSError *error = result;
    NSLog(@"amPostHttpRequestFailed! url:%@, Error - %@ %@", url, [error localizedDescription], [[error userInfo] objectForKey:NSURLErrorFailingURLStringErrorKey]);
}

- (void)loginComplete:(id)result
{
    NSLog(@"loginComplete:%@", result);
    NSNumber *resultStatus = [result objectForKey:@"result"];
    if(resultStatus != nil
       && resultStatus.intValue == 0)
    {
        NSString *openID = [result objectForKey:@"openid"];
        self.userInfoDic = result;
        NSString *loginTokenKey = [result objectForKey:@"token"];
        [[NSUserDefaults standardUserDefaults]setObject:loginTokenKey forKey:sResetPwdThroughOldPwdTokenKey];
        [self userInfoDownloadWithOpenID:openID];
    }
    else
    {
        NSArray *errorArray = @[@"密码错误，再输错1次将会锁定帐号。", @"密码错误，再输错2次将会锁定帐号。", @"密码错误，再输错3次将会锁定帐号。", @"密码错误，再输错4次将会锁定帐号。", @"密码错误", @"用户不存在"];
        NSString *resultDescription = [result objectForKey:@"desc"];
        NSString *noticeText = @"登录失败";
        
        if([errorArray containsObject:resultDescription]
           || [resultDescription rangeOfString:@"您的帐号已被锁定"].length > 0)
        {
            noticeText = resultDescription;
        }
        self.noticeText = noticeText;
        [self progressHUDHideImmediately];
    }
}

- (void)userInfoDownloadComplete:(id)result//////
{
    NSLog(@"userInfoDownloadComplete:%@", result);
    NSNumber *resultCode = result[@"result"];
    if(resultCode != nil
       && resultCode.intValue == 0)
    {
        NSDictionary *infoDic = result[@"watchAppUser"];
        if(infoDic)
        {
            self.userInfoDic = infoDic;
            NSString *openid = infoDic[@"openid"];
            
            NSString *deviceId = infoDic[@"deviceid"];
            id deviceIdLocal = [[NSUserDefaults standardUserDefaults]objectForKey:sRemoteNotificationDeviceToken];
            if(!deviceIdLocal)
            {
                deviceIdLocal = @"NoToken";
            }
            else if(![deviceIdLocal isKindOfClass:[NSString class]])
            {
                deviceIdLocal = [self deviceTokenFromData:deviceIdLocal];
                [[NSUserDefaults standardUserDefaults]setObject:deviceIdLocal forKey:sRemoteNotificationDeviceToken];
            }
            if(![deviceIdLocal isEqualToString:deviceId])
            {
                NSMutableDictionary *dic = [self.userInfoDic mutableCopy];
                [dic setValue:deviceIdLocal forKey:@"deviceid"];
                self.userInfoDic = [dic copy];
                NSMutableDictionary *params = [self.userInfoDic mutableCopy];
                [self postURLRequestWithMessageCode:ServiceMsgCodeGuardianInfoUpdate
                                       HUDLabelText:nil
                                             params:params
                                      completeBlock:^(id result) {
                                          [self userInfoUpdateComplete:result];
                                      }];
                
            }
            else
            {
                TYDUserInfo *userInfo = [TYDUserInfo sharedUserInfo];
                [userInfo setAttributes:self.userInfoDic];
                //[userInfo saveUserInfo];
                
                [self loadBabyInfoWithOpenID:openid];
            }
        }
        else
        {
            [self userInfoUpload];
        }
    }
    else
    {
        self.noticeText = @"登录失败";
        [self progressHUDHideImmediately];
    }
}

- (NSString *)deviceTokenFromData:(NSData *)tokenData
{
    NSString *token = [tokenData description];
    token = [token stringByReplacingOccurrencesOfString:@"<" withString:@""];
    token = [token stringByReplacingOccurrencesOfString:@">" withString:@""];
    token = [token stringByReplacingOccurrencesOfString:@" " withString:@""];
    return token;
}

- (void)userInfoUpdateComplete:(id)result
{
    NSNumber *resultCode = result[@"result"];
    if(resultCode != nil
       && resultCode.intValue == 0)
    {
        NSString *openid = self.userInfoDic[@"openid"];
        
        TYDUserInfo *userInfo = [TYDUserInfo sharedUserInfo];
        [userInfo setAttributes:self.userInfoDic];
        //[userInfo saveUserInfo];
        
        [self loadBabyInfoWithOpenID:openid];
    }
    else
    {
        [self progressHUDHideImmediately];
        self.noticeText = @"登录失败";
    }

}

- (void)userInfoUploadComplete:(id)result
{
    NSLog(@"userInfoUploadComplete:%@", result);
    NSNumber *resultCode = result[@"result"];
    if(resultCode != nil
       && resultCode.intValue == 0)
    {
        NSString *userid = result[@"id"];
        NSMutableDictionary *dic = [self.userInfoDic mutableCopy];
        [dic setValue:userid forKey:@"userid"];
        self.userInfoDic = [dic copy];
        
        TYDUserInfo *userInfo = [TYDUserInfo sharedUserInfo];
        [userInfo setAttributes:self.userInfoDic];
        //[userInfo saveUserInfo];
        
        [self loadBabyInfoWithOpenID:[TYDUserInfo sharedUserInfo].openID];
    }
    else
    {
        [self progressHUDHideImmediately];
        self.noticeText = @"登录失败";
    }
}

- (void)babyInfoDownloadComplete:(id)result
{
    NSLog(@"babyInfoDownloadComplete:%@", result);
    NSNumber *resultCode = result[@"result"];
    if(resultCode != nil
       && resultCode.intValue == 0)
    {
        NSArray *infoArray = result[@"childlist"];
        if(infoArray.count == 0)
        {
            [self progressHUDHideImmediately];
            
            BOOL isSentAdmin = [[NSUserDefaults standardUserDefaults]boolForKey:[TYDUserInfo sharedUserInfo].openID];
            if(!isSentAdmin)
            {
                [self authorizeAVCaptureDevice];
            }
            else
            {
                TYDBindAuthorizeController *vc = [TYDBindAuthorizeController new];
                [self.navigationController pushViewController:vc animated:YES];
            }
        }
        else
        {
            [[NSUserDefaults standardUserDefaults]removeObjectForKey:[TYDUserInfo sharedUserInfo].openID];
            
            NSMutableArray *childArray = [NSMutableArray new];
            for(NSDictionary *dic in infoArray)
            {
                TYDKidInfo *kidInfo = [TYDKidInfo new];
                [kidInfo setAttributes:dic];
                [childArray addObject:kidInfo];
            }
            [[TYDDataCenter defaultCenter]saveKidInfoList:childArray];
            
           
//            [self progressHUDShowWithCompleteText:@"登录成功" isSucceed:YES additionalTarget:self action:@selector(loginActionSucceed) object:nil];
             [self getNotificationInfo];//登录时有儿童的获取一下推送消息
        }
    }
    else
    {
        [self progressHUDHideImmediately];
        self.noticeText = @"登录失败";
    }
}

- (void)authorizeAVCaptureDevice
{
    dispatch_semaphore_t sema = dispatch_semaphore_create(0);
    [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
        dispatch_semaphore_signal(sema);
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if(granted)
            {
                TYDQRCodeViewController *vc = [TYDQRCodeViewController new];
                vc.isFirstLoginSituation = YES;
                [self.navigationController pushViewController:vc animated:YES];
            }
            else
            {
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"相机设置" message:@"请在设置中允许应用使用相机选项" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
                
                [alertView show];
            }
        });
    }];
    
    dispatch_semaphore_wait(sema, DISPATCH_TIME_FOREVER);
}

#pragma mark - TYDEnrollViewControllerDelegate

- (void)enrollSucceed:(NSString *)account password:(NSString *)password
{
    UITextField *accountTextField = [self.textInputViews objectInTextInputViewsAtIndex:0];
    UITextField *passwordTextField = [self.textInputViews objectInTextInputViewsAtIndex:1];
    accountTextField.text = account;
    passwordTextField.text = password;
    self.isEnrollSucceed = YES;
}

#pragma mark - TYDAppProfileControllerDelegate

- (void)appProfileControllerExperienceButtonTap:(TYDAppProfileController *)viewController
{
    self.navigationController.navigationBarHidden = NO;
    [viewController destroyAnimated:YES];
}

#pragma mark - ActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSString *actionTitle = [actionSheet buttonTitleAtIndex:buttonIndex];
    if([actionTitle isEqualToString:sActionSheetCancel])
    {
        NSLog(@"cancel register");
    }
    else if([actionTitle isEqualToString:sMobileNumberRegister])
    {
//        TYDEnrollViewController *vc = [TYDEnrollViewController new];
//        vc.delegate = self;
//        [self.navigationController pushViewController:vc animated:YES];
    }
    else if([actionTitle isEqualToString:sEmailRegister])
    {
//        TYDEmailEnrollViewController *vc = [TYDEmailEnrollViewController new];
//        [self.navigationController pushViewController:vc animated:YES];
    }
    else if([actionTitle isEqualToString:sMobilePhoneUser])
    {
//        TYDFindPwdViewController *vc = [TYDFindPwdViewController new];
//        [self.navigationController pushViewController:vc animated:YES];
    }
    else if([actionTitle isEqualToString:sEmailUser])
    {
//        TYDFindEmailPwdViewController *vc = [TYDFindEmailPwdViewController new];
//        [self.navigationController pushViewController:vc animated:YES];
    }
}

@end
