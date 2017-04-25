//
//  TYDEnrollViewController.m
//   Dorikids
//
//  Created by macMini_Dev on 15-8-20.
//
//  用户注册
//
//
#import "TYDEnrollViewController.h"
#import "TYDAMPostUrlRequest.h"

@interface TYDEnrollViewController ()

@property (strong, nonatomic) NSString  *enrollToken;
@property (assign, nonatomic) NSInteger vCodeButtonSecondNumber;
@property (assign, nonatomic) UIButton  *vCodeButton;
@property (strong, nonatomic) NSTimer   *vCodeTimer;

@end

@implementation TYDEnrollViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self localDataInitialize];
    [self navigationBarItemsLoad];
    [self subviewsLoad];
}

- (void)localDataInitialize
{
    _enrollToken = [[NSUserDefaults standardUserDefaults] stringForKey:sEnrollTokenKey];
    if(!_enrollToken)
    {
        _enrollToken = @"";
    }
    self.vCodeButtonSecondNumber = -1;
}

- (void)setEnrollToken:(NSString *)enrollToken
{
    _enrollToken = enrollToken;
    [[NSUserDefaults standardUserDefaults] setObject:enrollToken forKey:sEnrollTokenKey];
}

- (void)navigationBarItemsLoad
{
    self.title = @"注册";
}

- (void)subviewsLoad
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
    
    UIView *grayLine2 = [UIView new];
    grayLine2.size = CGSizeMake(baseView.width, 0.5);
    grayLine2.backgroundColor = [UIColor colorWithHex:0xdfdfdf];
    [baseView addSubview:grayLine2];
    
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
    
    UITextField *setPwdTextField = [UITextField new];
    setPwdTextField.placeholder = @"设置密码";
    setPwdTextField.font = textFont;
    setPwdTextField.textColor = textColor;
    setPwdTextField.borderStyle = UITextBorderStyleNone;
    setPwdTextField.returnKeyType = UIReturnKeyNext;//Return键
    setPwdTextField.keyboardType = UIKeyboardTypeNumbersAndPunctuation;
    setPwdTextField.autocorrectionType = UITextAutocorrectionTypeNo;
    setPwdTextField.secureTextEntry = NO;
    setPwdTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
    setPwdTextField.autocapitalizationType = UITextAutocapitalizationTypeNone;
    setPwdTextField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    setPwdTextField.leftViewMode = UITextFieldViewModeAlways;
    [setPwdTextField addTarget:self action:@selector(textFiledEditEndOnExit:) forControlEvents:UIControlEventEditingDidEndOnExit];
    setPwdTextField.size = textFieldSize;
    [baseView addSubview:setPwdTextField];

    UITextField *vCodeTextField = [UITextField new];
    vCodeTextField.placeholder = @"输入验证码";
    vCodeTextField.font = textFont;
    vCodeTextField.textColor = textColor;
    vCodeTextField.borderStyle = UITextBorderStyleNone;
    vCodeTextField.returnKeyType = UIReturnKeyDone;
    vCodeTextField.keyboardType = UIKeyboardTypeNumbersAndPunctuation;
    vCodeTextField.autocorrectionType = UITextAutocorrectionTypeNo;
    vCodeTextField.secureTextEntry = YES;
    vCodeTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
    vCodeTextField.autocapitalizationType = UITextAutocapitalizationTypeNone;
    vCodeTextField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    vCodeTextField.leftViewMode = UITextFieldViewModeAlways;
    [vCodeTextField addTarget:self action:@selector(textFiledEditEndOnExit:) forControlEvents:UIControlEventEditingDidEndOnExit];
    vCodeTextField.size = textFieldSize;
    [baseView addSubview:vCodeTextField];
    
    [self.textInputViews appendOneTextInputView:accountTextField];
    [self.textInputViews appendOneTextInputView:setPwdTextField];
    [self.textInputViews appendOneTextInputView:vCodeTextField];
    
    grayLine1.left = 0;
    grayLine2.left = 0;
    accountTextField.left = innerLeftOffset;
    setPwdTextField.left = innerLeftOffset;
    vCodeTextField.left = innerLeftOffset;
    
    accountTextField.top = 10;//0
    grayLine1.top = accountTextField.bottom + 2;
    setPwdTextField.top = grayLine1.bottom + 10;
    grayLine2.top = setPwdTextField.bottom + 2;
    vCodeTextField.top = grayLine2.bottom + 10;
    
    baseView.backgroundColor = [UIColor colorWithHex:0xffffff];
    baseView.height = vCodeTextField.bottom + 2;
    [baseView.layer setCornerRadius:8];
    
    UIEdgeInsets capInsets = UIEdgeInsetsMake(10, 10, 10, 10);
    UIButton *vCodeButton = [[UIButton alloc] initWithImageName:@"login_vCodeBtn" highlightedImageName:@"login_vCodeBtn" capInsets:capInsets givenButtonSize:CGSizeMake(66, 26) title:@"获取验证码" titleFont:[UIFont fontWithName:@"Arial" size:12] titleColor:cBasicGreenColor];
    [vCodeButton sizeToFit];
    vCodeButton.width += 30;//15
    [vCodeButton addTarget:self action:@selector(vCodeButtonTap:) forControlEvents:UIControlEventTouchUpInside];
    vCodeButton.center = vCodeTextField.center;
    vCodeButton.right = baseView.width - 2;
    [baseView addSubview:vCodeButton];
    self.vCodeButton = vCodeButton;
    vCodeTextField.width = vCodeButton.left - vCodeTextField.left - 6;
    
    self.baseViewBaseHeight = baseView.bottom;
    
    CGFloat centernButtonTop = self.baseViewBaseHeight;
    
    UIButton *centernButton = [[UIButton alloc] initWithImageName:@"login_btn" highlightedImageName:@"login_btn" capInsets:capInsets givenButtonSize:CGSizeMake(self.view.width-34, 40) title:@"确定" titleFont:[UIFont fontWithName:@"Arial" size:18] titleColor:UIColorWithHex(0xffffff)];
    [centernButton addTarget:self action:@selector(centernButtonTap:) forControlEvents:UIControlEventTouchUpInside];
    centernButton.center = self.baseView.innerCenter;
    centernButton.top = centernButtonTop + 85;
    [self.baseView addSubview:centernButton];
    self.baseViewBaseHeight = centernButton.bottom + 20;
}

#pragma mark - TouchEvent

- (void)centernButtonTap:(UIButton *)sender
{
    [self.textInputViews allTextInputViewsResignFirstResponder];
    [self enroll];
}

- (void)vCodeButtonTap:(UIButton *)sender
{
    NSLog(@"vCodeButtonTap");
    if(self.vCodeButtonSecondNumber < 0)
    {
        [self.textInputViews allTextInputViewsResignFirstResponder];
        [self vCodeObtain];
    }
}

- (void)refreshVCodeButtonTitle
{
    if(self.vCodeButtonSecondNumber >= 0)
    {
        [self.vCodeButton setTitle:[NSString stringWithFormat:@"获取验证码(%lds)",(long)self.vCodeButtonSecondNumber] forState:UIControlStateNormal];
        self.vCodeButtonSecondNumber--;
    }
    else
    {
        [self.vCodeButton setTitle:@"获取验证码" forState:UIControlStateNormal];
        self.vCodeButton.enabled = YES;
        [self.vCodeTimer invalidate];
        self.vCodeTimer = nil;
    }
}

- (void)textFiledEditEndOnExit:(UITextField *)sender
{
    [self.textInputViews nextTextInputViewBecomeFirstResponder:sender];
}

#pragma mark - Connect To Server

///lapi/getrandcode
//
//base_param:
//
//uid:手机号
//codetype:验证码 [userreg,resetpasswd,bindmobile]
//sign:签名
//
//opt_param:
//
//token:令牌
//
//签名计算：[uid codetype token]

- (void)vCodeObtain
{
    UITextField *phoneTextField = [self.textInputViews objectInTextInputViewsAtIndex:0];
    NSString *phone = phoneTextField.text;
    
    NSString *message = nil;
    if(![self networkIsValid])
    {
        message = sNetworkFailed;
    }
    else if(phone.length == 0)
    {
        message = @"请输入账号";
    }
    else if(![BOAssistor phoneNumberIsValid:phone])
    {
        message = @"请输入有效手机号";
    }
    
    if(message)
    {
        self.noticeText = message;
    }
    else
    {
        NSString *vCodeType = sAMVCodeTypeEnroll;
        NSString *deviceInfoString = [NSString stringWithFormat:@"{\"packName\":\"%@\"}", [BOAssistor appBundleID]];
        NSLog(@"deviceInfoString:%@", deviceInfoString);
        NSString *deviceInfo = [TYDAMPostUrlRequest deviceInfoEncode:deviceInfoString];
        NSLog(@"deviceInfo:%@", deviceInfo);
        NSString *sign = [TYDAMPostUrlRequest signInfoCreateWithInfos:@[phone, vCodeType]];
        NSLog(@"sign:%@",sign);
        NSMutableDictionary *params = [NSMutableDictionary new];
        [params setValue:phone forKey:@"uid"];
        [params setValue:vCodeType forKey:@"codetype"];
        [params setValue:sign forKey:@"sign"];
        [params setValue:deviceInfo forKey:@"devinfo"];
        
        [self progressHUDShowWithText:nil];
        [TYDAMPostUrlRequest amRequestWithURL:sAMServiceUrlVcode
                                       params:params
                                completeBlock:^(id result) {
                                    [self vCodeObtainComplete:result];
                                }
                                  failedBlock:^(NSString *url, id result) {
                                      [self amPostHttpRequestFailed:url result:result];
                                  }];
    }
}

//lapi/signup
//
//base_param:
//
//token:令牌
//passwd:明文密码
//regtype:注册步骤[smsreg,randreg]
//devinfo:设备信息
//sign:签名
//
//opt_param:
//randcode:验证码
//
//签名计算：[token passwd regtype devinfo randcode]

- (void)enroll
{
    UITextField *phoneTextField = [self.textInputViews objectInTextInputViewsAtIndex:0];
    UITextField *passwordTextField = [self.textInputViews objectInTextInputViewsAtIndex:1];
    UITextField *vCodeTextField = [self.textInputViews objectInTextInputViewsAtIndex:2];
    NSString *phone = phoneTextField.text;
    NSString *password = passwordTextField.text;
    NSString *vCode = vCodeTextField.text;
    
    NSString *message = nil;
    if(![self networkIsValid])
    {
        message = sNetworkFailed;
    }
    else if(phone.length == 0)
    {
        message = @"请输入账号";
    }
    else if(![BOAssistor phoneNumberIsValid:phone])
    {
        message = @"请输入有效手机号";
    }
    else if(![BOAssistor passwordLengthIsValid:password])
    {
        message = @"密码长度6~48位";
    }
    else if (vCode.length == 0)
    {
        message = @"请输入验证码";
    }
    else if (vCode.length != 6)
    {
        message = @"验证码长度不正确";
    }
    if(message)
    {
        self.noticeText = message;
    }
    else
    {
        NSString *token = self.enrollToken;
        NSString *enrollType = sAMEnrollTypeVCode;
        NSString *deviceInfo = [TYDAMPostUrlRequest deviceInfoEncode:[BOAssistor deviceUDID]];
        NSLog(@"%@%@%@%@%@",token, password, enrollType, deviceInfo, vCode);
        NSArray *signInfos = @[token, password, enrollType, deviceInfo, vCode];
        NSString *sign = [TYDAMPostUrlRequest signInfoCreateWithInfos:signInfos];
        
        NSMutableDictionary *params = [NSMutableDictionary new];
        [params setValue:password forKey:@"passwd"];
        [params setValue:enrollType forKey:@"regtype"];
        [params setValue:deviceInfo forKey:@"devinfo"];
        [params setValue:sign forKey:@"sign"];
        [params setValue:vCode forKey:@"randcode"];
        [params setValue:token forKey:@"token"];
        
        [self progressHUDShowWithText:nil];
        [TYDAMPostUrlRequest amRequestWithURL:sAMServiceUrlEnroll
                                       params:params
                                completeBlock:^(id result) {
                                    [self enrollComplete:result];
                                }
                                  failedBlock:^(NSString *url, id result) {
                                      [self amPostHttpRequestFailed:url result:result];
                                  }];
    }
}

#pragma mark - Server Connection Receipt

- (void)enrollComplete:(id)result
{
    NSLog(@"enrollComplete:%@", result);
    NSNumber *resultStatus = [result objectForKey:@"result"];
    if(resultStatus.intValue == 0)
    {
        NSString *token = [result objectForKey:@"token"];
        self.enrollToken = token;
        [self passBackInfos];//回传数据以直接登录
        [self progressHUDShowWithCompleteText:@"注册成功" isSucceed:YES additionalTarget:self action:@selector(popBackEventWillHappen) object:nil];
    }
    else
    {
        if(self.enrollToken.length != 0)
        {
            NSString *resultDescription = [result objectForKey:@"desc"];
            self.noticeText = resultDescription;
        }
        else
        {
            self.noticeText = @"验证码错误";
        }
        
        [self progressHUDHideImmediately];
    }
}

- (void)amPostHttpRequestFailed:(NSString *)url result:(id)result
{
    [self progressHUDHideImmediately];
    self.noticeText = sNetworkError;
    
    NSError *error = result;
    NSLog(@"amPostHttpRequestFailed! url:%@, Error - %@ %@", url, [error localizedDescription], [[error userInfo] objectForKey:NSURLErrorFailingURLStringErrorKey]);
}

- (void)vCodeObtainComplete:(id)result
{
    NSLog(@"vCodeObtainComplete:%@", result);
    NSNumber *resultStatus = [result objectForKey:@"result"];
    if(resultStatus.intValue == 0)
    {
        NSString *token = [result objectForKey:@"token"];
        self.enrollToken = token;
    }
    
    NSString *resultDescription = [result objectForKey:@"desc"];
    self.noticeText = resultDescription;
    [self progressHUDHideImmediately];
    
    if(![resultDescription isEqualToString:@"用户已经存在"])
    {
        self.vCodeButton.enabled = NO;
        self.vCodeButtonSecondNumber = 60;
        
        NSTimer *vCodeTimer = [NSTimer timerWithTimeInterval:1 target:self selector:@selector(refreshVCodeButtonTitle) userInfo:nil repeats:YES];
        [[NSRunLoop currentRunLoop] addTimer:vCodeTimer forMode:NSRunLoopCommonModes];
        self.vCodeTimer = vCodeTimer;
    }
}

#pragma mark - PassBackInfosForImmediatelyLogin

- (void)passBackInfos
{
    if([self.delegate respondsToSelector:@selector(enrollSucceed:password:)])
    {
        UITextField *phoneTextField = [self.textInputViews objectInTextInputViewsAtIndex:0];
        UITextField *passwordTextField = [self.textInputViews objectInTextInputViewsAtIndex:1];
        NSString *phone = phoneTextField.text;
        NSString *password = passwordTextField.text;
        [self.delegate enrollSucceed:phone password:password];
    }
}

@end
