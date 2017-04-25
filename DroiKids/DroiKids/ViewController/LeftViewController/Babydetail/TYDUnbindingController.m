//
//  TYDUnbindingController.m
//  DroiKids
//
//  Created by wangchao on 15/9/8.
//  Copyright (c) 2015年 TYDTech. All rights reserved.
//

#import "TYDUnbindingController.h"
#import "TYDDataCenter.h"
#import "TYDKidInfo.h"
#import "TYDPostUrlRequest.h"
#import "TYDChoseBundingStyleController.h"
#import "NSString+MD5Addition.h"

@interface TYDUnbindingController ()

@end

@implementation TYDUnbindingController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self localDataInitialize];
    [self navigationBarItemsLoad];
    [self subviewsLoad];
}

- (void)localDataInitialize
{
    
}

- (void)navigationBarItemsLoad
{
    self.title = @"解除绑定";
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
    accountTextField.placeholder = @"请输入手机号码";
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
    passwordTextField.placeholder = @"确认登录密码";
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
    UIButton *unbindingButton = [[UIButton alloc] initWithImageName:@"login_btn" highlightedImageName:@"login_btnH" capInsets:capInsets givenButtonSize:CGSizeMake(self.view.width - 34, 40) title:@"解除绑定" titleFont:[UIFont fontWithName:@"Arial" size:18] titleColor:UIColorWithHex(0xffffff)];
    [unbindingButton addTarget:self action:@selector(unbindingButtonTap:) forControlEvents:UIControlEventTouchUpInside];
    unbindingButton.center = center;
    unbindingButton.top = top + 85;
    [baseView addSubview:unbindingButton];
    
    self.baseViewBaseHeight = unbindingButton.bottom + 20;
}

#pragma mark - TouchEvent

- (void)textFiledEditEndOnExit:(UITextField *)sender
{
    [self.textInputViews nextTextInputViewBecomeFirstResponder:sender];
}

- (void)unbindingButtonTap:(UIButton *)sender
{
    NSLog(@"unbindingButtonTap");
    
    TYDKidInfo *currentKidInfo = [TYDDataCenter defaultCenter].currentKidInfo;
    UITextField *textField = [self.textInputViews objectInTextInputViewsAtIndex:1];
    
    NSMutableDictionary *params = [NSMutableDictionary new];
    [params setValue:currentKidInfo.watchID forKey:@"watchid"];
    [params setValue:textField.text.MD5String forKey:@"password"];
    [params setValue:[TYDUserInfo sharedUserInfo].openID forKey:sPostUrlRequestUserOpenIDKey];
    
    [TYDPostUrlRequest postUrlRequestWithMessageCode:102019
                                              params:params
                                       completeBlock:^(id result) {
                                           [self unbindingComplete:result];
                                       }
                                         failedBlock:^(NSUInteger msgCode, id result) {
                                             [self amPostHttpRequestFailed:msgCode result:result];
                                         }];
}

- (void)unbindingComplete:(id)result
{
    NSLog(@"unbindingComplete:%@", result);
    
    NSNumber *value = result[@"result"];
    
    if(value.intValue == 0)
    {
        TYDDataCenter *dataCenter = [TYDDataCenter defaultCenter];
        [dataCenter removeOneKidInfo:dataCenter.currentKidInfo];
        
        if(dataCenter.currentKidInfo)
        {
            [self.navigationController popToRootViewControllerAnimated:YES];
        }
        else
        {
            TYDChoseBundingStyleController *vc = [TYDChoseBundingStyleController new];
            [self.navigationController pushViewController:vc animated:YES];
        }
    }
    else if(value.intValue == 1)
    {
        self.noticeText = @"解绑失败";
    }
    else if(value.intValue == 11)
    {
        self.noticeText = @"输入正确的密码";
    }
    else
    {
        self.noticeText = @"解绑失败";
    }
}

- (void)amPostHttpRequestFailed:(NSInteger)url result:(id)result
{
    [self progressHUDHideImmediately];
    self.noticeText = sNetworkError;
    
    NSError *error = result;
    NSLog(@"amPostHttpRequestFailed! url:%d, Error - %@ %@", (int)url, [error localizedDescription], [[error userInfo] objectForKey:NSURLErrorFailingURLStringErrorKey]);
}

- (void)findPasswordButtonTap:(UIButton *)sender
{
    NSLog(@"findPasswordButtonTap");
}

@end
