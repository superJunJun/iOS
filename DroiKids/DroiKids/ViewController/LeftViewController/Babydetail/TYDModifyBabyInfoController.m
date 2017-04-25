//
//  TYDModifyBabyInfoController.m
//  DroiKids
//
//  Created by wangchao on 15/8/29.
//  Copyright (c) 2015年 TYDTech. All rights reserved.
//

#import "TYDModifyBabyInfoController.h"
#import "TYDGenderBlock.h"
#import "TYDBackgroundColorBlock.h"

#define sBabyNameMaxLength              5

@interface TYDModifyBabyInfoController ()

@property (strong, nonatomic) NSArray *cellTitle;
@property (strong, nonatomic) NSArray *colorTypeArray;
@property (strong, nonatomic) NSDictionary *colorDic;
@property (strong, nonatomic) UITextField *editNameTextField;
@property (strong, nonatomic) TYDBackgroundColorBlock *selectColorBlock;
@property (strong, nonatomic) TYDGenderBlock *selectGenderBlock;

@end

@implementation TYDModifyBabyInfoController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self localDataInitialize];
    [self navigationBarItemsLoad];
    [self subviewsLoad];
}

- (void)localDataInitialize
{
    self.cellTitle = @[@"姓名",
                       @"性别",
                       @"颜色"];
    
    self.colorTypeArray = @[@(TYDKidColorTypeGreen),
                            @(TYDKidColorTypeYellow),
                            @(TYDKidColorTypeBlue),
                            @(TYDKidColorTypePurple),
                            @(TYDKidColorTypeRed)];
}

- (void)navigationBarItemsLoad
{
    self.title = @"资料修改";
}

- (void)subviewsLoad
{
    [self editNameCellLoad];
    [self editGenderCellLoad];
    [self selectColorBlockCellLoad];
}

- (void)editNameCellLoad
{
    CGFloat top = self.baseViewBaseHeight + 18;
    UIControl *baseView = [[UIControl alloc] initWithFrame:CGRectMake(0, top, self.baseView.width, 60.5)];
    baseView.backgroundColor = [UIColor whiteColor];
    [baseView addTarget:self action:@selector(tapOnSpace:) forControlEvents:UIControlEventTouchUpInside];
    [self.baseView addSubview:baseView];
    
    UILabel *nameTitleLabel = [UILabel new];
    nameTitleLabel.backgroundColor = [UIColor clearColor];
    nameTitleLabel.font = [UIFont systemFontOfSize:14];
    nameTitleLabel.textColor = [UIColor colorWithHex:0xaaaaaa];
    nameTitleLabel.text = @"姓名             ";
    [nameTitleLabel sizeToFit];
    
    CGSize textFieldSize = CGSizeMake(baseView.width - 34, 60);
    
    UITextField *editNameTextField = [UITextField new];
    editNameTextField.backgroundColor = [UIColor whiteColor];
    editNameTextField.font = [UIFont systemFontOfSize:14];
    editNameTextField.textColor = [UIColor colorWithHex:0x000000];
    editNameTextField.placeholder = self.nickname ? self.nickname : @"姓名";
    editNameTextField.text = self.nickname ? self.nickname : @"姓名";
    editNameTextField.borderStyle = UITextBorderStyleNone;
    editNameTextField.keyboardType = UIKeyboardTypeDefault;
    editNameTextField.returnKeyType = UIReturnKeyNext;
    editNameTextField.autocorrectionType = UITextAutocorrectionTypeNo;
    editNameTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
    editNameTextField.autocapitalizationType = UITextAutocapitalizationTypeNone;
    editNameTextField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    editNameTextField.leftViewMode = UITextFieldViewModeAlways;
    editNameTextField.leftView = nameTitleLabel;
    [editNameTextField addTarget:self action:@selector(textFiledEditEndOnExit:) forControlEvents:UIControlEventEditingDidEndOnExit];
    
    editNameTextField.size = textFieldSize;
    editNameTextField.left = 17;
    editNameTextField.top = 0;
    [baseView addSubview:editNameTextField];
    
    self.editNameTextField = editNameTextField;
    
    [self.textInputViews appendOneTextInputView:editNameTextField];
    
    UIView *grayLine = [UIView new];
    grayLine.backgroundColor = [UIColor colorWithHex:0xdfdfdf];
    grayLine.size = CGSizeMake(baseView.width - 17, 0.5);
    grayLine.top = editNameTextField.bottom;
    grayLine.left = 17;
    [baseView addSubview:grayLine];
    
    self.baseViewBaseHeight = baseView.bottom;
}

- (void)editGenderCellLoad
{
    UIControl *baseView = [[UIControl alloc] initWithFrame:CGRectMake(0, self.baseViewBaseHeight, self.baseView.width, 60.5)];
    baseView.backgroundColor = [UIColor whiteColor];
    [baseView addTarget:self action:@selector(tapOnSpace:) forControlEvents:UIControlEventTouchUpInside];
    [self.baseView addSubview:baseView];
    
    UILabel *genderTitleLabel = [UILabel new];
    genderTitleLabel.backgroundColor = [UIColor clearColor];
    genderTitleLabel.font = [UIFont systemFontOfSize:14];
    genderTitleLabel.textColor = [UIColor colorWithHex:0xaaaaaa];
    genderTitleLabel.text = @"姓别";
    [genderTitleLabel sizeToFit];
    genderTitleLabel.left = 17;
    genderTitleLabel.yCenter = baseView.innerCenter.y;
    
    [baseView addSubview:genderTitleLabel];
    
    TYDGenderBlock *maleBlock = [[TYDGenderBlock alloc] initWithGenderName:@"男" genderNameFont:[UIFont systemFontOfSize:14] genderIconSize:CGSizeMake(12, 12)];
    maleBlock.left = genderTitleLabel.right + 43;
    maleBlock.yCenter = baseView.innerCenter.y;
    [maleBlock addTarget:self action:@selector(genderBlockTap:) forControlEvents:UIControlEventTouchUpInside];
    [baseView addSubview:maleBlock];
    
    TYDGenderBlock *femaleBlock = [[TYDGenderBlock alloc] initWithGenderName:@"女" genderNameFont:[UIFont systemFontOfSize:14] genderIconSize:CGSizeMake(12, 12)];
    femaleBlock.left = maleBlock.right + 80;
    femaleBlock.yCenter = maleBlock.yCenter;
    [femaleBlock addTarget:self action:@selector(genderBlockTap:) forControlEvents:UIControlEventTouchUpInside];
    [baseView addSubview:femaleBlock];
    
    self.selectGenderBlock = [self.gender isEqualToString:@"男"] ? maleBlock : femaleBlock;
    self.selectGenderBlock.selected = YES;
    
    UIView *grayLine = [UIView new];
    grayLine.backgroundColor = [UIColor colorWithHex:0xdfdfdf];
    grayLine.size = CGSizeMake(baseView.width - 17, 0.5);
    grayLine.bottom = baseView.height;
    grayLine.left = 17;
    [baseView addSubview:grayLine];
    
    self.baseViewBaseHeight = baseView.bottom;
}

- (void)selectColorBlockCellLoad
{
    UIControl *baseView = [[UIControl alloc] initWithFrame:CGRectMake(0, self.baseViewBaseHeight, self.baseView.width, 60)];
    baseView.backgroundColor = [UIColor whiteColor];
    [baseView addTarget:self action:@selector(tapOnSpace:) forControlEvents:UIControlEventTouchUpInside];
    [self.baseView addSubview:baseView];
    
    UILabel *colorTitleLabel = [UILabel new];
    colorTitleLabel.backgroundColor = [UIColor clearColor];
    colorTitleLabel.font = [UIFont systemFontOfSize:14];
    colorTitleLabel.textColor = [UIColor colorWithHex:0xaaaaaa];
    colorTitleLabel.text = @"颜色";
    [colorTitleLabel sizeToFit];
    colorTitleLabel.left = 17;
    colorTitleLabel.yCenter = baseView.innerCenter.y;
    
    [baseView addSubview:colorTitleLabel];
    
    for(int i = 0; i < self.colorTypeArray.count; i++)
    {
        TYDBackgroundColorBlock *colorBlock = [[TYDBackgroundColorBlock alloc] initWithSizeLength:32 andBackgroundColor:self.colorTypeArray[i]];
        
        colorBlock.yCenter = baseView.innerCenter.y;
        colorBlock.left = colorTitleLabel.right + 43 + i * (colorBlock.width + 15);
        
        if(self.colorType == colorBlock.colorType)
        {
            colorBlock.checkIconVisible = YES;
            self.selectColorBlock = colorBlock;
        }
        
        [colorBlock addTarget:self action:@selector(colorBlockTap:) forControlEvents:UIControlEventTouchUpInside];
        
        [baseView addSubview:colorBlock];
    }
    
    self.baseViewBaseHeight = baseView.bottom;
}

#pragma mark - TouchEvent

- (void)textFiledEditEndOnExit:(UITextField *)sender
{
    [self.textInputViews nextTextInputViewBecomeFirstResponder:sender];
}

- (void)tapOnSpace:(id)sender
{
    [self.textInputViews allTextInputViewsResignFirstResponder];
}

- (void)colorBlockTap:(UIControl *)sender
{
    NSLog(@"colorBlockTap");
    
    TYDBackgroundColorBlock *colorBlock = (TYDBackgroundColorBlock *)sender;
    
    if(self.selectColorBlock != colorBlock)
    {
        self.selectColorBlock.checkIconVisible = NO;
        colorBlock.checkIconVisible = YES;
        
        self.selectColorBlock = nil;
        _selectColorBlock = colorBlock;
    }
}

- (void)genderBlockTap:(UIButton *)sender
{
    TYDGenderBlock *genderBlock = (TYDGenderBlock *)sender;
    
    if(self.selectGenderBlock != genderBlock)
    {
        self.selectGenderBlock.selected = NO;
        genderBlock.selected = YES;
        
        self.selectGenderBlock = nil;
        _selectGenderBlock = genderBlock;
    }
}

#pragma mark - OverrideMethod

- (void)popBackEventWillHappen
{
    [self editComplete];
}

- (void)editComplete
{
    NSLog(@"completeButtonTap");
    
    NSString *textFieldTextString = (self.editNameTextField.text.length == 0) ? self.editNameTextField.placeholder : self.editNameTextField.text;
    
    if([BOAssistor stringTrim:textFieldTextString].length == 0)
    {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"编辑资料" message:@"姓名不能为空" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        
        [alertView show];
    }
    else if([self textLength:textFieldTextString] > sBabyNameMaxLength)
    {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"编辑资料" message:@"姓名不能超过5个字节" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        
        [alertView show];
    }
    else if(self.colorType.intValue != self.selectColorBlock.colorType.intValue
       || ![self.nickname isEqualToString:textFieldTextString]
       || ![self.gender isEqualToString:self.selectGenderBlock.gender])
    {
        if([self.delegate respondsToSelector:@selector(modifyBabyInfoCompleteWithHeaderViewColor:nickname:gender:)])
        {
            [self.delegate modifyBabyInfoCompleteWithHeaderViewColor:self.selectColorBlock.colorType nickname:textFieldTextString gender:self.selectGenderBlock.gender];
        }
        
        long colorHex = [TYDKidInfo kidColorHexWithKidColorType:self.selectColorBlock.colorType];
        self.navigationController.navigationBar.barTintColor = [UIColor colorWithHex:colorHex];
        
        [super popBackEventWillHappen];
    }
    else
    {
        [super popBackEventWillHappen];
    }
}

#pragma mark - NSStringUtil

- (int)textLength:(NSString *)text
{
    float length = 0.0;
    
    for(int index = 0; index < [text length]; index++)
    {
        NSString *character = [text substringWithRange:NSMakeRange(index, 1)];
        
        if ([character lengthOfBytesUsingEncoding:NSUTF8StringEncoding] == 3)
        {
            length++;
        }
        else
        {
            length = length + 0.5;
        }
    }
    
    return ceil(length);
}

@end
