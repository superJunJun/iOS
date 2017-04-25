//
//  TYDBindWatchIDController.m
//  DroiKids
//
//  Created by wangchao on 15/9/9.
//  Copyright (c) 2015年 TYDTech. All rights reserved.
//

#import "TYDBindWatchIDController.h"
#import "TYDChooseAvatarViewController.h"
#import "TYDBindAuthorizeController.h"
#import "TYDWatchInfo.h"
#import "TYDDataCenter.h"
#import "TYDKidContactInfo.h"

@interface TYDBindWatchIDController ()<UITextFieldDelegate>//<TYDChooseAvatarDelegate>

@property (strong, nonatomic) UILabel  *noticeLabel;
@property (strong, nonatomic) UIButton *avatarButton;
@property (strong, nonatomic) UIButton *bindingButton;

@end

@implementation TYDBindWatchIDController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self localDataInitialize];
    [self navigationBarItemsLoad];
    [self subviewsLoad];
}

- (void)localDataInitialize
{
    if(!self.avatarID)
    {
        self.avatarID = @4;
    }
}

- (void)navigationBarItemsLoad
{
    self.title = @"添加绑定号";
}

- (void)subviewsLoad
{
    [self inputViewsLoad];
//    [self noticeLabelLoad];
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
    
    UIFont *textFont = [UIFont fontWithName:@"Arial" size:14];
    UIColor *textColor = [UIColor colorWithHex:0x323232];
    CGSize textFieldSize = CGSizeMake(baseView.width - 9, 30);//baseView.width - innerLeftOffset
    
//    UIView *grayLine1 = [UIView new];
//    grayLine1.size = CGSizeMake(baseView.width, 0.5);
//    grayLine1.backgroundColor = [UIColor colorWithHex:0xdfdfdf];
//    [baseView addSubview:grayLine1];
    
//    NSString *avatarString = [NSString stringWithFormat:@"addressBookAvatar_%@", self.avatarID];
//    UIButton *avatarButton = [UIButton new];
//    avatarButton.size = CGSizeMake(40, 40);
//    [avatarButton setBackgroundImage:[UIImage imageNamed:avatarString] forState:UIControlStateNormal];
//    avatarButton.layer.cornerRadius = avatarButton.width * 0.5;
//    avatarButton.layer.masksToBounds = YES;
//    [avatarButton addTarget:self action:@selector(avatarButtonTap:) forControlEvents:UIControlEventTouchUpInside];
//    self.avatarButton = avatarButton;
    
    UITextField *accountTextField = [UITextField new];
    accountTextField.delegate = self;
    [accountTextField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    accountTextField.placeholder = @"请输入绑定号";
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
    [accountTextField addTarget:self action:@selector(textFiledEditEndOnExit:) forControlEvents:UIControlEventEditingDidEndOnExit];
    accountTextField.size = textFieldSize;
    [baseView addSubview:accountTextField];
    
//    UITextField *textField = [UITextField new];
//    textField.placeholder = @"请输入与宝贝的关系";
//    textField.font = [UIFont systemFontOfSize:14];
//    textField.textColor = [UIColor blackColor];
//    textField.borderStyle = UITextBorderStyleNone;
//    textField.autocorrectionType = UITextAutocorrectionTypeNo;
//    textField.clearButtonMode = UITextFieldViewModeWhileEditing;
//    textField.autocapitalizationType = UITextAutocapitalizationTypeNone;
//    textField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
//    textField.leftViewMode = UITextFieldViewModeAlways;
//    [textField addTarget:self action:@selector(textFiledEditEndOnExit:) forControlEvents:UIControlEventEditingDidEndOnExit];
//    textField.size = textFieldSize;
//    textField.center = baseView.innerCenter;
//    [baseView addSubview:textField];
//    textField.keyboardType = UIKeyboardTypeDefault;
//    textField.returnKeyType = UIReturnKeyDone;
    [self.textInputViews appendOneTextInputView:accountTextField];
//    [self.textInputViews appendOneTextInputView:textField];
    
//    grayLine1.left = 0;
    accountTextField.left = innerLeftOffset;
//    textField.left = innerLeftOffset;
    
    accountTextField.top = 10;//0
//    grayLine1.top = accountTextField.bottom + 2;
//    textField.top = grayLine1.bottom + 10;
    
//    baseView.height = textField.bottom + 2;
    baseView.height = accountTextField.bottom + 2;
    baseView.backgroundColor = [UIColor colorWithHex:0xffffff];
    baseView.layer.cornerRadius = 8;
    
//    avatarButton.top = grayLine1.bottom + (12 + textField.height- avatarButton.height)*0.5;
//    avatarButton.right = baseView.width - 2;
//    [baseView addSubview:avatarButton];
//    textField.width = avatarButton.left - textField.left - 6;
    
    self.baseViewBaseHeight = baseView.bottom;
}

- (void)noticeLabelLoad
{
    UILabel *noticeLabel = [UILabel new];
    noticeLabel.backgroundColor = [UIColor clearColor];
    noticeLabel.font = [UIFont systemFontOfSize:11];
    noticeLabel.textColor = [UIColor grayColor];
    noticeLabel.text = @"jkj";
    [noticeLabel sizeToFit];
    noticeLabel.xCenter = self.view.width / 2;
    noticeLabel.top = self.baseViewBaseHeight + 12;
    
    [self.baseView addSubview:noticeLabel];
    
    self.baseViewBaseHeight = noticeLabel.bottom;
}

- (void)buttonViewsLoad
{
    CGFloat top = self.baseViewBaseHeight;
    UIView *baseView = self.baseView;
    CGPoint center = baseView.innerCenter;

    UIEdgeInsets capInsets = UIEdgeInsetsMake(10, 10, 10, 10);
    UIButton *bindingButton = [[UIButton alloc] initWithImageName:@"login_btnEnable" highlightedImageName:@"login_btnH" capInsets:capInsets givenButtonSize:CGSizeMake(self.view.width-34, 40) title:@"确定" titleFont:[UIFont fontWithName:@"Arial" size:18] titleColor:UIColorWithHex(0xffffff)];
    [bindingButton addTarget:self action:@selector(bindingButtonTap:) forControlEvents:UIControlEventTouchUpInside];
    bindingButton.center = center;
    bindingButton.top = top + 85;
    [baseView addSubview:bindingButton];
    bindingButton.enabled = NO;
    self.bindingButton = bindingButton;
    self.baseViewBaseHeight = bindingButton.bottom + 20;

}

- (void)textFiledEditEndOnExit:(UITextField *)sender
{
    [self.textInputViews nextTextInputViewBecomeFirstResponder:sender];
}

#pragma mark - TouchEvent

- (void)bindingButtonTap:(UIButton *)sender
{
    [self.textInputViews allTextInputViewsResignFirstResponder];
    UITextField *watchNumberTextField = [self.textInputViews objectInTextInputViewsAtIndex:0];
    NSString *watchNumber = watchNumberTextField.text;
    
    NSString *message = nil;
    if(![self networkIsValid])
    {
        message = sNetworkFailed;
    }
//    else if(watchNumber.length != 15)
//    {
//        message = @"请输入15为绑定号！";
//    }
    if(message)
    {
        self.noticeText = message;
    }
    else
    {
        NSMutableDictionary *params = [NSMutableDictionary new];
        [params setValue:[TYDUserInfo sharedUserInfo].openID forKey:sPostUrlRequestUserOpenIDKey];
        [params setValue:@"其他" forKey:@"relationship"];
        [params setValue:watchNumber forKey:@"watchid"];
        
        [self postURLRequestWithMessageCode:ServiceMsgCodeBindWatchNormal
                               HUDLabelText:nil
                                     params:params
                              completeBlock:^(id result) {
                                  [self bindWatchNormalComplete:result];
                              }];
    }
}

- (void)bindWatchNormalComplete:(id)result
{
    NSLog(@"bindWatchNormalComplete:%@",result);
    [self progressHUDHideImmediately];
    NSNumber *resultCode = result[@"result"];
    NSDictionary *childInfo = result[@"watchChild"];
    
    if(resultCode != nil
       && resultCode.intValue == 0)
    {
        self.noticeText = @"绑定成功";
        
        [self bindingSucceedWithChildInfo:childInfo];
    }
    else if (resultCode.integerValue == 4)
    {
        if([TYDDataCenter defaultCenter].currentKidInfo)
        {
            [self.navigationController popToRootViewControllerAnimated:YES];
        }
        else
        {
            //等待审
            [[NSUserDefaults standardUserDefaults]setBool:YES forKey:[TYDUserInfo sharedUserInfo].openID];
            TYDBindAuthorizeController *vc = [TYDBindAuthorizeController new];
            [self.navigationController pushViewController:vc animated:YES];
        }
        
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"绑定手表" message:@"请等待管理员审核" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alertView show];
    }	
    else
    {
        self.noticeText = @"绑定失败";
    }
    [self progressHUDHideImmediately];
}

- (void)bindingSucceedWithChildInfo:(NSDictionary *)childInfo
{
    TYDDataCenter *dataCenter = [TYDDataCenter defaultCenter];
    NSMutableArray *kidInfoList = dataCenter.kidInfoList.mutableCopy;
    
    TYDKidInfo *kidInfo = [TYDKidInfo new];
    [kidInfo setAttributes:childInfo];
    
    [kidInfoList addObject:kidInfo];
    [dataCenter saveKidInfoList:kidInfoList];
    dataCenter.currentKidInfo = kidInfo;
    
    if(self.isFirstLoginSituation)
    {
        UINavigationController *mainNavigationController = [self.storyboard instantiateViewControllerWithIdentifier:@"mainNavigationController"];
        [self presentViewController:mainNavigationController animated:YES completion:^{
            [self.navigationController popViewControllerAnimated:NO];
        }];
    }
    else
    {
        [self.navigationController popToRootViewControllerAnimated:YES];
    }
}

#pragma mark - UITextViewDelegate

- (void)textFieldDidChange:(UITextField *)textField
{
    NSLog(@"textViewDidChange");
    UIImage *imageNomal = [UIImage imageNamed:@"login_btnEnable"];
    imageNomal = [imageNomal resizableImageWithCapInsets:UIEdgeInsetsMake(10, 10, 10, 10) resizingMode:UIImageResizingModeStretch];
    UIImage *imageVisible = [UIImage imageNamed:@"login_btn"];
    imageVisible = [imageVisible resizableImageWithCapInsets:UIEdgeInsetsMake(10, 10, 10, 10) resizingMode:UIImageResizingModeStretch];
    
    UITextField *watchNumberTextField = [self.textInputViews objectInTextInputViewsAtIndex:0];
    NSString *watchNumber = watchNumberTextField.text;

    if (textField.text.length == 0 || watchNumber.length != 16)
    {
        [self.bindingButton setBackgroundImage:imageNomal forState:UIControlStateNormal];
        self.bindingButton.enabled = NO;
    }
    else
    {
        [self.bindingButton setBackgroundImage:imageVisible forState:UIControlStateNormal];
        self.bindingButton.enabled = YES;
    }
}

@end
