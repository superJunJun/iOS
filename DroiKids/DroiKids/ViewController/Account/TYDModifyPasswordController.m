//
//  TYDModifyPasswordController.m
//  DroiKids
//
//  Created by caiyajie on 15/8/15.
//  Copyright (c) 2015年 superjunjun. All rights reserved.
//

#import "TYDModifyPasswordController.h"
#import "TYDFindPwdViewController.h"
#import "TYDAMPostUrlRequest.h"
#import "NSString+MD5Addition.h"

@interface TYDModifyPasswordController ()

@end

@implementation TYDModifyPasswordController

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
    self.title = @"修改密码";
}

- (void)subviewsLoad
{
    CGFloat sideOffset = 17;
    CGFloat innerLeftOffset = 8;
    CGFloat startTop = self.baseViewBaseHeight + 20;
    CGRect  startFrame = CGRectMake(sideOffset, startTop,self.baseView.width - sideOffset * 2, 10);
    UIControl *startBaseView = [[UIControl alloc]initWithFrame:startFrame];
    startBaseView.backgroundColor = [UIColor clearColor];
    [startBaseView addTarget:self action:@selector(tapOnSpace:) forControlEvents:UIControlEventTouchUpInside];
    [self.baseView addSubview:startBaseView];
   
    UIFont *textFont = [UIFont fontWithName:@"Arial" size:14];
    UIColor *textColor = [UIColor colorWithHex:0x323232];
    CGSize textFieldSize = CGSizeMake(startBaseView.width - 9, 30);
    UITextField *nowPwdTextField = [UITextField new];
    nowPwdTextField.placeholder = @"当前密码";
    nowPwdTextField.font = textFont;
    nowPwdTextField.textColor = textColor;
    nowPwdTextField.borderStyle = UITextBorderStyleNone;
    nowPwdTextField.returnKeyType = UIReturnKeyDone;//Return键
    nowPwdTextField.keyboardType = UIKeyboardTypeNumbersAndPunctuation;
    nowPwdTextField.autocorrectionType = UITextAutocorrectionTypeNo;
    nowPwdTextField.secureTextEntry = YES;
    nowPwdTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
    nowPwdTextField.autocapitalizationType = UITextAutocapitalizationTypeNone;
    nowPwdTextField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    nowPwdTextField.leftViewMode = UITextFieldViewModeAlways;
    [nowPwdTextField addTarget:self action:@selector(textFiledEditEndOnExit:) forControlEvents:UIControlEventEditingDidEndOnExit];
    nowPwdTextField.size = textFieldSize;
    [startBaseView addSubview:nowPwdTextField];
    [self.textInputViews appendOneTextInputView:nowPwdTextField];
    
    nowPwdTextField.left = innerLeftOffset;
    nowPwdTextField.top = 10;//0
    startBaseView.height = nowPwdTextField.bottom + 2;
    [startBaseView.layer setCornerRadius:8];
    startBaseView.backgroundColor = [UIColor whiteColor];
    self.baseViewBaseHeight = startBaseView.bottom;
    
    UIButton *findPasswordButton = [UIButton new];
    findPasswordButton.titleLabel.font = [UIFont systemFontOfSize:12];
    [findPasswordButton setTitle:@"忘记密码" forState:UIControlStateNormal];
    [findPasswordButton setTitleColor:cBasicGreenColor forState:UIControlStateNormal];
    [findPasswordButton setTitleColor:[UIColor colorWithHex:0xe23674] forState:UIControlStateHighlighted];
    [findPasswordButton addTarget:self action:@selector(findPasswordButtonTap:) forControlEvents:UIControlEventTouchUpInside];
    [findPasswordButton sizeToFit];
    findPasswordButton.top = self.baseViewBaseHeight;
    findPasswordButton.right = self.baseView.width - 18;
    [self.baseView addSubview:findPasswordButton];
    self.baseViewBaseHeight = findPasswordButton.bottom;
    
    CGFloat top = self.baseViewBaseHeight + 20;
    CGRect frame = CGRectMake(sideOffset, top, self.baseView.width - sideOffset * 2, 10);
    UIControl *baseView = [[UIControl alloc] initWithFrame:frame];
    baseView.backgroundColor = [UIColor clearColor];
    [baseView addTarget:self action:@selector(tapOnSpace:) forControlEvents:UIControlEventTouchUpInside];
    [self.baseView addSubview:baseView];
    
    UIView *grayLine1 = [UIView new];
    grayLine1.size = CGSizeMake(baseView.width, 0.5);
    grayLine1.backgroundColor = [UIColor colorWithHex:0xdfdfdf];
    [baseView addSubview:grayLine1];
    
    UITextField *newPwdTextField = [UITextField new];
    newPwdTextField.placeholder = @"新密码";
    newPwdTextField.font = textFont;
    newPwdTextField.textColor = textColor;
    newPwdTextField.borderStyle = UITextBorderStyleNone;
    newPwdTextField.returnKeyType = UIReturnKeyDone;//Return键
    newPwdTextField.keyboardType = UIKeyboardTypeNumbersAndPunctuation;
    newPwdTextField.autocorrectionType = UITextAutocorrectionTypeNo;
    newPwdTextField.secureTextEntry = YES;
    newPwdTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
    newPwdTextField.autocapitalizationType = UITextAutocapitalizationTypeNone;
    newPwdTextField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    newPwdTextField.leftViewMode = UITextFieldViewModeAlways;
    [newPwdTextField addTarget:self action:@selector(textFiledEditEndOnExit:) forControlEvents:UIControlEventEditingDidEndOnExit];
    newPwdTextField.size = textFieldSize;
    [baseView addSubview:newPwdTextField];
    
    UITextField *confirmPwdTextField = [UITextField new];
    confirmPwdTextField.placeholder = @"确认密码";
    confirmPwdTextField.font = textFont;
    confirmPwdTextField.textColor = textColor;
    confirmPwdTextField.borderStyle = UITextBorderStyleNone;
    confirmPwdTextField.returnKeyType = UIReturnKeyDone;
    confirmPwdTextField.keyboardType = UIKeyboardTypeNumbersAndPunctuation;
    confirmPwdTextField.autocorrectionType = UITextAutocorrectionTypeNo;
    confirmPwdTextField.secureTextEntry = YES;
    confirmPwdTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
    confirmPwdTextField.autocapitalizationType = UITextAutocapitalizationTypeNone;
    confirmPwdTextField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    confirmPwdTextField.leftViewMode = UITextFieldViewModeAlways;
    [confirmPwdTextField addTarget:self action:@selector(textFiledEditEndOnExit:) forControlEvents:UIControlEventEditingDidEndOnExit];
    confirmPwdTextField.size = textFieldSize;
    [baseView addSubview:confirmPwdTextField];
    
    [self.textInputViews appendOneTextInputView:newPwdTextField];
    [self.textInputViews appendOneTextInputView:confirmPwdTextField];
    
    grayLine1.left = 0;
    newPwdTextField.left = innerLeftOffset;
    confirmPwdTextField.left = innerLeftOffset;
    
    newPwdTextField.top = 10;//0
    grayLine1.top = newPwdTextField.bottom + 2;
    confirmPwdTextField.top = grayLine1.bottom + 10;
    
    baseView.backgroundColor = [UIColor colorWithHex:0xffffff];
    baseView.height = confirmPwdTextField.bottom + 2;
    [baseView.layer setCornerRadius:8];
    
    self.baseViewBaseHeight = baseView.bottom;
    
    UIEdgeInsets capInsets = UIEdgeInsetsMake(10, 10, 10, 10);
    UIButton *centerButton = [[UIButton alloc] initWithImageName:@"login_btn" highlightedImageName:@"login_btn" capInsets:capInsets givenButtonSize:CGSizeMake(self.view.width-34, 40) title:@"确认" titleFont:[UIFont fontWithName:@"Arial" size:18] titleColor:UIColorWithHex(0xffffff)];
    [centerButton addTarget:self action:@selector(certainButtonTap:) forControlEvents:UIControlEventTouchUpInside];
    centerButton.center = self.baseView.innerCenter;
    centerButton.bottom =  self.view.height - 50 - 44;
    [self.baseView addSubview:centerButton];
    self.baseViewBaseHeight = centerButton.bottom + 20;
}


- (void)findPasswordButtonTap:(UITapGestureRecognizer *)sender
{
    TYDFindPwdViewController *vc = [TYDFindPwdViewController new];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)textFiledEditEndOnExit:(UITextField *)sender
{
    [self.textInputViews nextTextInputViewBecomeFirstResponder:sender];
}

- (void)certainButtonTap:(UIButton *)sender
{
    NSLog(@"certainButtonTap");
    [self.textInputViews allTextInputViewsResignFirstResponder];
    [self modifyPassword];
}

- (void)modifyPassword
{
    UITextField *nowPwdTextField = [self.textInputViews objectInTextInputViewsAtIndex:0];
    UITextField *newPwdTextField = [self.textInputViews objectInTextInputViewsAtIndex:1];
    UITextField *confirmPwd = [self.textInputViews objectInTextInputViewsAtIndex:2];
    
    NSString *nowPwdString = nowPwdTextField.text;
    NSString *newPwdString = newPwdTextField.text;
    NSString *confirmPwdString = confirmPwd.text;
    NSString *message = nil;
    if(![self networkIsValid])
    {
        message = sNetworkFailed;
    }
    else if(nowPwdString.length == 0
            || newPwdString.length == 0
            || confirmPwdString.length == 0)
    {
        message = @"所有输入条目都为必填项";
    }
    else if(![BOAssistor passwordLengthIsValid:newPwdString])
    {
        message = @"密码长度6~48位";;
    }
    else if (![newPwdString isEqualToString:confirmPwdString])
    {
        message = @"确认密码与密码不一致";
    }
    else if ([newPwdString isEqualToString:nowPwdString])
    {
        message = @"修改的密码与原密码相同，请重新输入！";
    }
    
    if(message)
    {
        self.noticeText = message;
    }
    else
    {
        NSString *nowPwdMD5String = nowPwdString.MD5String;
        NSString *token = [[NSUserDefaults standardUserDefaults]objectForKey:sResetPwdThroughOldPwdTokenKey];
        NSString *sign = [TYDAMPostUrlRequest signInfoCreateWithInfos:@[token, nowPwdMD5String, newPwdString]];
        
        
        NSMutableDictionary *params = [NSMutableDictionary new];
        [params setValue:nowPwdMD5String forKey:@"oldpasswd"];
        [params setValue:newPwdString forKey:@"newpasswd"];
        [params setValue:sign forKey:@"sign"];
        [params setValue:token forKey:@"token"];
        
        [self progressHUDShowWithText:nil];
        [TYDAMPostUrlRequest amRequestWithURL:sAMServiceUrlResetOldPwd
                                       params:params
                                completeBlock:^(id result) {
                                    [self findPasswordComplete:result];
                                }
                                  failedBlock:^(NSString *url, id result) {
                                      [self amPostHttpRequestFailed:url result:result];
                                  }];
    }
}

#pragma mark - Server Connection Receipt

- (void)amPostHttpRequestFailed:(NSString *)url result:(id)result
{
    [self progressHUDHideImmediately];
    self.noticeText = sNetworkError;
    
    NSError *error = result;
    NSLog(@"amPostHttpRequestFailed! url:%@, Error - %@ %@", url, [error localizedDescription], [[error userInfo] objectForKey:NSURLErrorFailingURLStringErrorKey]);
}

- (void)findPasswordComplete:(id)result
{
    NSLog(@"findPasswordComplete:%@", result);
    NSNumber *resultStatus = [result objectForKey:@"result"];
    if(resultStatus.intValue == 0)
    {
        [self progressHUDShowWithCompleteText:@"密码已重置" isSucceed:YES additionalTarget:self action:@selector(popBackEventWillHappen) object:nil];
    }
    else
    {
        NSString *resultDescription = [result objectForKey:@"desc"];
        self.noticeText = resultDescription;
        [self progressHUDHideImmediately];
    }
}

@end
