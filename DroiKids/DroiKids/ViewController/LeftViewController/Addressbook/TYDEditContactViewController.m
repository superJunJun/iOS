//
//  TYDEditContactViewController.m
//  DroiKids
//
//  Created by wangchao on 15/8/29.
//  Copyright (c) 2015年 TYDTech. All rights reserved.
//

#import "TYDEditContactViewController.h"
#import "TYDContactsPickController.h"
#import "TYDChooseAvatarViewController.h"
#import "TYDDataCenter.h"
#import "TYDKidContactInfo.h"
#import "TYDPostUrlRequest.h"
#import "MBProgressHUD.h"
#import <AddressBook/AddressBook.h>

#define sContactNameMaxLength           4
#define sPhoneNumberMaxLength           12
#define sShortNumberMaxLength           6
#define sShortNumberMinLength           3

@interface TYDEditContactViewController () <TYDChooseAvatarDelegate, TYDContactsPickDelegate>

@property (strong, nonatomic) UIButton *avatarButton;
@property (strong, nonatomic) NSString *name;
@property (strong, nonatomic) NSString *phoneNumberString;
@property (strong, nonatomic) NSString *shortNumberString;

@end

@implementation TYDEditContactViewController

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
    [self updateData];
}

- (void)updateData
{
    if(self.kidContactInfo
       && self.kidContactInfo.contactType.integerValue != TYDKidContactTypeNormal)
    {
        UITextField *numberField = [self.textInputViews objectInTextInputViewsAtIndex:1];
        numberField.userInteractionEnabled = NO;
    }
}

- (void)localDataInitialize
{
    self.avatarID = self.kidContactInfo.contactAvatarID;
}

- (void)navigationBarItemsLoad
{
    if(self.editContactType == TYDEditContactTypeAdd)
    {
        self.titleText = @"添加联系人";
    }
    else if(self.editContactType == TYDEditContactTypeModify)
    {
        self.titleText = @"修改联系人";
    }
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setTitle:@"确定" forState:UIControlStateNormal];
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [button setTitleColor:[UIColor grayColor] forState:UIControlStateHighlighted];
    [button sizeToFit];
    [button addTarget:self action:@selector(saveButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *rightBarButtonItem = [[UIBarButtonItem alloc]initWithCustomView:button];
    self.navigationItem.rightBarButtonItem = rightBarButtonItem;
}

- (void)subviewsLoad
{
    [self inputViewLoad];
}

- (void)inputViewLoad
{
    CGFloat top = self.baseViewBaseHeight + 18;
    UIControl *baseView = [[UIControl alloc] initWithFrame:CGRectMake(0, top, self.baseView.width, 10)];
    baseView.backgroundColor = [UIColor whiteColor];
    [baseView addTarget:self action:@selector(tapOnSpace:) forControlEvents:UIControlEventTouchUpInside];
    [self.baseView addSubview:baseView];
    
    UILabel *modifyNameLabel = [UILabel new];
    modifyNameLabel.font = [UIFont systemFontOfSize:14];
    modifyNameLabel.textColor = [UIColor colorWithHex:0xaaaaaa];
    modifyNameLabel.text = @"修改关系:  ";
    [modifyNameLabel sizeToFit];
    
    UILabel *numberLabel = [UILabel new];
    numberLabel.font = [UIFont systemFontOfSize:14];
    numberLabel.textColor = [UIColor colorWithHex:0xaaaaaa];
    numberLabel.text = @"号       码:  ";
    [numberLabel sizeToFit];
    
    UILabel *shortNumberLabel = [UILabel new];
    shortNumberLabel.font = [UIFont systemFontOfSize:14];
    shortNumberLabel.textColor = [UIColor colorWithHex:0xaaaaaa];
    shortNumberLabel.text = @"短       号:  ";
    [shortNumberLabel sizeToFit];
    
    UIButton *avatarButton = [UIButton new];
    avatarButton.size = CGSizeMake(45, 45);
    NSString *avatarName = [NSString stringWithFormat:@"addressBookAvatar_%d", self.avatarID.intValue];
    [avatarButton setBackgroundImage:[UIImage imageNamed:avatarName] forState:UIControlStateNormal];
    avatarButton.layer.cornerRadius = avatarButton.width * 0.5;
    avatarButton.layer.masksToBounds = YES;
    [avatarButton addTarget:self action:@selector(avatarButtonTap:) forControlEvents:UIControlEventTouchUpInside];
    self.avatarButton = avatarButton;
    
    UIButton *addressbookButton = [UIButton new];
    addressbookButton.size = CGSizeMake(45, 45);
    [addressbookButton setBackgroundImage:[UIImage imageNamed:@"addressBook_icon"] forState:UIControlStateNormal];
    [addressbookButton addTarget:self action:@selector(addressbookButtonTap:) forControlEvents:UIControlEventTouchUpInside];
    
    CGSize textFieldSize = CGSizeMake(self.view.width - 36, 60);
    for(int i = 0; i < 3; i++)
    {
        UITextField *textField = [UITextField new];
        textField.backgroundColor = [UIColor whiteColor];
        textField.font = [UIFont systemFontOfSize:14];
        textField.textColor = [UIColor blackColor];
        textField.borderStyle = UITextBorderStyleNone;
        textField.autocorrectionType = UITextAutocorrectionTypeNo;
        textField.clearButtonMode = UITextFieldViewModeWhileEditing;
        textField.autocapitalizationType = UITextAutocapitalizationTypeNone;
        textField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
        textField.leftViewMode = UITextFieldViewModeAlways;
        [textField addTarget:self action:@selector(textFiledEditEndOnExit:) forControlEvents:UIControlEventEditingDidEndOnExit];
        textField.size = textFieldSize;
        textField.center = baseView.innerCenter;
        textField.top = i * (textField.height + 0.5);
        [baseView addSubview:textField];
        
        [self.textInputViews appendOneTextInputView:textField];
    }
    
    UITextField *modifyNameField = [self.textInputViews objectInTextInputViewsAtIndex:0];
    UITextField *numberField = [self.textInputViews objectInTextInputViewsAtIndex:1];
    UITextField *shortNumberField = [self.textInputViews objectInTextInputViewsAtIndex:2];
    
    numberField.placeholder = @"请输入电话号码";
    modifyNameField.keyboardType = UIKeyboardTypeDefault;
    modifyNameField.returnKeyType = UIReturnKeyNext;
    modifyNameField.leftView = modifyNameLabel;
    modifyNameField.rightView = avatarButton;
    modifyNameField.rightViewMode = UITextFieldViewModeAlways;
    modifyNameField.text = self.kidContactInfo.contactName;
    
    UIView *grayLineFirst = [UIView new];
    grayLineFirst.size = CGSizeMake(baseView.width - 17, 0.5);
    grayLineFirst.left = 17;
    grayLineFirst.backgroundColor = [UIColor colorWithHex:0xdfdfdf];
    [baseView addSubview:grayLineFirst];
    grayLineFirst.top = modifyNameField.bottom;
    
    numberField.keyboardType = UIKeyboardTypeNumberPad;
    numberField.returnKeyType = UIReturnKeyNext;
    numberField.leftView = numberLabel;
    numberField.rightView = addressbookButton;
    numberField.rightViewMode = UITextFieldViewModeAlways;
    numberField.text = self.kidContactInfo.contactNumber;
    
    UIView *grayLineSec = [UIView new];
    grayLineSec.size = CGSizeMake(baseView.width - 17, 0.5);
    grayLineSec.left = 17;
    grayLineSec.backgroundColor = [UIColor colorWithHex:0xdfdfdf];
    [baseView addSubview:grayLineSec];
    grayLineSec.top = numberField.bottom;
    
    shortNumberField.keyboardType = UIKeyboardTypeNumberPad;
    shortNumberField.returnKeyType = UIReturnKeyNext;
    shortNumberField.leftView = shortNumberLabel;
    shortNumberField.text = self.kidContactInfo.shortNumber;
    
    baseView.height = modifyNameField.height + grayLineFirst.height + numberField.height + grayLineSec.height + shortNumberField.height;
    
    self.baseViewBaseHeight = baseView.bottom;
}

- (void)confirmButtonLoad
{
    CGSize buttonSize = CGSizeMake(self.view.width - 17 * 2, 34);
    UIButton *addContactButton = [[UIButton alloc] initWithImage:[UIImage imageNamed:@"addressBook_addContacts"] highlightedImage:[UIImage imageNamed:@"addressBook_addContactsH"] capInsets:UIEdgeInsetsMake(10, 10, 10, 10) givenButtonSize:buttonSize title:@"添加联系人" titleFont:[UIFont systemFontOfSize:17] titleColor:[UIColor whiteColor]];
    addContactButton.xCenter = self.baseView.innerCenter.x;
    addContactButton.bottom = self.view.height - 100;
    [self.baseView addSubview:addContactButton];
    
    self.baseViewBaseHeight = addContactButton.bottom + 20;
}

- (void)textFiledEditEndOnExit:(UITextField *)sender
{
    [self.textInputViews nextTextInputViewBecomeFirstResponder:sender];
}

#pragma mark - OverridePropertyMethod

- (void)setAvatarID:(NSNumber *)avatarID
{
    if(!avatarID)
    {
        avatarID = @(TYDKidContactOther);
    }
    
    if(![_avatarID isEqualToNumber:avatarID])
    {
        _avatarID = avatarID;
        NSString *avatarName = [NSString stringWithFormat:@"addressBookAvatar_%d", avatarID.intValue];
        [self.avatarButton setBackgroundImage:[UIImage imageNamed:avatarName] forState:UIControlStateNormal];
    }
}

#pragma mark - touchEvent

- (void)avatarButtonTap:(UIButton *)sender
{
    NSLog(@"avatarButtonTap");
    
    if(self.editContactType == TYDEditContactTypeModify)
    {
        TYDChooseAvatarViewController *vc = [TYDChooseAvatarViewController new];
        vc.choseAvatarDelegate = self;
        vc.editContactType = self.editContactType;
        vc.avatarID = self.avatarID;
        
        [self.navigationController pushViewController:vc animated:YES];
    }
}

- (void)addressbookButtonTap:(UIButton *)sender
{
    NSLog(@"addressbookButtonTap");
    
    ABAddressBookRef addressBooks = ABAddressBookCreateWithOptions(NULL, NULL);
    //获取通讯录权限
    dispatch_semaphore_t sema = dispatch_semaphore_create(0);
    ABAddressBookRequestAccessWithCompletion(addressBooks, ^(bool granted, CFErrorRef error){
        dispatch_semaphore_signal(sema);
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if(granted)
            {
                TYDContactsPickController *contactPickerView = [TYDContactsPickController new];
                contactPickerView.delegate = self;
                
                [self.navigationController pushViewController:contactPickerView animated:YES];
            }
            else
            {
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"通讯录授权" message:@"请在手机设置中允许应用获取联系人" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
                
                [alertView show];
            }
        });
    });
    
    dispatch_semaphore_wait(sema, DISPATCH_TIME_FOREVER);
}

- (void)tapOnSpace:(id)sender
{
    [self.textInputViews allTextInputViewsResignFirstResponder];
}

- (void)saveButtonClick:(UIButton *)sender
{
    NSLog(@"saveButtonClick");
    
    [self.textInputViews allTextInputViewsResignFirstResponder];

    UITextField *modifyNameField = [self.textInputViews objectInTextInputViewsAtIndex:0];
    UITextField *numberField = [self.textInputViews objectInTextInputViewsAtIndex:1];
    UITextField *shortNumberField = [self.textInputViews objectInTextInputViewsAtIndex:2];
    NSString *name = modifyNameField.text;
    NSString *phoneNumberString = numberField.text;
    NSString *shortNumberString = shortNumberField.text;
    
    self.name = name;
    self.phoneNumberString = phoneNumberString;
    self.shortNumberString = shortNumberString;
    
    if([name stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]].length == 0)
    {
        self.noticeText = @"关系不能为空";
    }
    else if([BOAssistor textLength:name] > sContactNameMaxLength)
    {
        self.noticeText = @"关系不能超过8个字节";
    }
    else if([phoneNumberString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]].length == 0)
    {
        self.noticeText = @"电话号码不能为空";
    }
    else if([phoneNumberString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]].length > sPhoneNumberMaxLength)
    {
        self.noticeText = @"电话号码过长";
    }
    else if(![BOAssistor phoneNumberIsValid:phoneNumberString]
            || [phoneNumberString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]].length != phoneNumberString.length)
    {
        self.noticeText = @"电话号码格式错误";
    }
    else if([shortNumberString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]].length > sShortNumberMaxLength)
    {
        self.noticeText = @"短号不能超过6个数字";
    }
    else if(shortNumberString.length != 0
            && [shortNumberString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]].length < sShortNumberMinLength)
    {
        self.noticeText = @"短号不能少于3个数字";
    }
    
    else if([shortNumberString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]].length != shortNumberString.length
            || (![BOAssistor numberStringValid:shortNumberString]
                && [shortNumberString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]].length != 0))
    {
        self.noticeText = @"短号格式错误";
    }
    else if(self.editContactType == TYDEditContactTypeAdd)
    {
        BOOL contactNumberIsExist = NO;
        NSArray *kidContactInfoList = [TYDDataCenter defaultCenter].kidContactInfoList;
        for(TYDKidContactInfo *kidContactInfo in kidContactInfoList)
        {
            if([kidContactInfo.contactNumber isEqualToString:phoneNumberString])
            {
                contactNumberIsExist = YES;
                break;
            }
        }
        
        if(!contactNumberIsExist)
        {
            NSMutableDictionary *params = [NSMutableDictionary new];
            [params setValue:[TYDUserInfo sharedUserInfo].openID forKey:@"openid"];
            [params setValue:[TYDDataCenter defaultCenter].currentKidInfo.watchID forKey:@"watchid"];
            [params setValue:name forKey:@"userinfo"];
            [params setValue:phoneNumberString forKey:@"phone"];
            [params setValue:shortNumberString forKey:@"shortphone"];
            [params setValue:self.avatarID forKey:@"imgid"];
            [params setValue:@(TYDKidContactTypeNormal) forKey:@"type"];
            [params setValue:@(TYDKidContactQuickNumberNone) forKey:@"quicklyNumberType"];
            
            [self addContact:params];
        }
        else
        {
            self.noticeText = @"联系人号码已存在";
        }
    }
    else if(self.editContactType == TYDEditContactTypeModify)
    {
        BOOL modifyPhoneNumberExist = NO;
        NSArray *kidContactInfoList = [TYDDataCenter defaultCenter].kidContactInfoList;
        
        for(TYDKidContactInfo *kidContactInfo in kidContactInfoList)
        {
            if([kidContactInfo.contactNumber isEqualToString:phoneNumberString]
               && ![kidContactInfo.contactID isEqualToString:self.kidContactInfo.contactID])
            {
                modifyPhoneNumberExist = YES;
                
                break;
            }
        }
        
        if(!modifyPhoneNumberExist)
        {
            NSMutableDictionary *params = [NSMutableDictionary new];
           
            [params setValue:[TYDUserInfo sharedUserInfo].openID forKey:@"openid"];
            [params setValue:self.kidContactInfo.contactID forKey:@"id"];
            [params setValue:self.kidContactInfo.kidID forKey:@"watchid"];
            [params setValue:name forKey:@"userinfo"];
            [params setValue:phoneNumberString forKey:@"phone"];
            [params setValue:shortNumberString forKey:@"shortphone"];
            [params setValue:self.avatarID forKey:@"imgid"];
            [params setValue:self.kidContactInfo.quicklyNumberType forKey:@"familyid"];
            [params setValue:self.kidContactInfo.contactType forKey:@"type"];
            
            [self modifyContact:params];
        }
        else
        {
            self.noticeText = @"联系人号码重复";
        }
        
    }
}

#pragma mark - TYDContactsPickDelegate

- (void)contactsPickComplete:(NSString *)contactNumber
{
    UITextField *numberField = [self.textInputViews objectInTextInputViewsAtIndex:1];
    
    numberField.text = contactNumber;
}

#pragma mark - TYDChooseAvatarDelegate

- (void)choseAvatarComplete:(NSNumber *)avatarID
{
    self.avatarID = avatarID;
}

#pragma mark - connectServer

- (void)modifyContact:(NSMutableDictionary *)params
{
    [self postURLRequestWithMessageCode:ServiceMsgCodeKidContactAdd
                           HUDLabelText:nil
                                 params:params
                          completeBlock:^(id result) {
                              [self modifyContactComplete:result];
                          }];
}

- (void)modifyContactComplete:(id)result
{
    NSLog(@"result:%@", result);
    
    [self progressHUDHideImmediately];
    
    NSNumber *value = result[@"result"];
    if(value.intValue == 0)
    {
        self.kidContactInfo.contactName = self.name;
        self.kidContactInfo.contactNumber = self.phoneNumberString;
        self.kidContactInfo.shortNumber = self.shortNumberString;
        self.kidContactInfo.contactAvatarID = self.avatarID;
        
        NSMutableArray *kidContactInfoList = [TYDDataCenter defaultCenter].kidContactInfoList.mutableCopy;
        
        for(TYDKidContactInfo *kidContactInfo in kidContactInfoList)
        {
            if([kidContactInfo.contactID isEqualToString:self.kidContactInfo.contactID])
            {
                [kidContactInfoList removeObject:kidContactInfo];
                [kidContactInfoList addObject:self.kidContactInfo];
                
                if([[TYDUserInfo sharedUserInfo].openID isEqualToString:self.kidContactInfo.contactOpenID])
                {
                    [TYDUserInfo sharedUserInfo].phoneNumber = self.phoneNumberString;
                }

                break;
            }
        }
        
        [TYDDataCenter defaultCenter].kidContactInfoList = kidContactInfoList;
        [TYDDataCenter defaultCenter].isContactInfoListModified = YES;
        
        [super popBackEventWillHappen];
    }
    else
    {
        self.noticeText = @"修改联系人失败";
    }
}

- (void)addContact:(NSMutableDictionary *)params
{
    [self postURLRequestWithMessageCode:ServiceMsgCodeKidContactAdd
                           HUDLabelText:nil
                                 params:params
                          completeBlock:^(id result) {
                              [self addContactComplete:result];
                          }];
}

- (void)addContactComplete:(id)result
{
    NSLog(@"addContactComplete:%@", result);
    [self progressHUDHideImmediately];
    
    NSNumber *contactID = result[@"id"];
    NSNumber *value = result[@"result"];
    
    if(value.intValue == 0)
    {
        TYDKidContactInfo *kidContactInfo = [TYDKidContactInfo new];
        kidContactInfo.kidID = [TYDDataCenter defaultCenter].currentKidInfo.watchID;
        kidContactInfo.contactID = contactID.stringValue;
        kidContactInfo.contactName = self.name;
        kidContactInfo.contactNumber = self.phoneNumberString;
        kidContactInfo.shortNumber = self.shortNumberString;
        kidContactInfo.contactType = @(TYDKidContactTypeNormal);
        kidContactInfo.contactAvatarID = self.avatarID;
        kidContactInfo.quicklyNumberType = @(TYDKidContactQuickNumberNone);
        
        NSMutableArray *kidContactInfoList = [TYDDataCenter defaultCenter].kidContactInfoList.mutableCopy;
        [kidContactInfoList addObject:kidContactInfo];
        
        [TYDDataCenter defaultCenter].kidContactInfoList = kidContactInfoList;
        [TYDDataCenter defaultCenter].isContactInfoListModified = YES;

        NSArray *viewControllerList = self.navigationController.viewControllers;
        UIViewController *destVc = nil;

        if(viewControllerList.count == 4)
        {
            destVc = viewControllerList[viewControllerList.count - 3];
        }
        if(destVc != nil)
        {
            [self.navigationController popToViewController:destVc animated:YES];
        }
    }
    else
    {
        self.noticeText = @"添加联系人失败";
    }
}

@end
