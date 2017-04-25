//
//  TYDBabyDetailViewController.m
//  DroiKids
//
//  Created by superjunjun on 15/8/7.
//  Copyright (c) 2015年 superjunjun. All rights reserved.
//

#import "TYDBabyDetailViewController.h"
#import "TYDModifyBabyInfoController.h"
#import "BOBottomPopupView.h"
#import "TYDSearchAddressController.h"
#import "TYDSearchAddressResultController.h"
#import "TYDGenerateQRCodeController.h"
#import "TYDChoseBundingStyleController.h"
#import "TYDAvatarModifyController.h"
#import "TYDUnbindingController.h"
#import "TYDDataCenter.h"
#import "GTMBase64.h"
#import "TYDPostUrlRequest.h"
#import "TYDCharacterRollLabel.h"
#import "TYDKidContactInfo.h"
#import "TYDQRCodeViewController.h"
#import "NSString+MD5Addition.h"

#define sBabyDetailCellHeight       60

#define sBabyMaxBirthdayYear        10
#define sBabyMinimumHeight          60
#define sBabyMaximumHeight          220
#define sBabyMinimumWeight          15
#define sBabyMaximumWeight          201

@interface TYDBabyDetailTableViewCell : UITableViewCell

@property (strong, nonatomic) TYDCharacterRollLabel *contentLabel;
@property (assign, nonatomic) BOOL showAccessoryView;

- (instancetype)initWithCellTitle:(NSString *)cellTitle
                cellDetailContent:(NSString *)detailText
                  reuseIdentifier:(NSString *)reuseIdentifier
                showAccessoryView:(BOOL)showAccessoryView;

@end

@implementation TYDBabyDetailTableViewCell

- (instancetype)initWithCellTitle:(NSString *)cellTitle
                cellDetailContent:(NSString *)detailText
                  reuseIdentifier:(NSString *)reuseIdentifier
                showAccessoryView:(BOOL)showAccessoryView

{
    if(self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier])
    {
        self.textLabel.text = cellTitle;
        self.showAccessoryView = showAccessoryView;
        
        UIFont *font = [UIFont fontWithName:@"Arial" size:16];
        UIColor *textColor = [UIColor colorWithHex:0xaaaaaa];
        
        TYDCharacterRollLabel *detailTextLabel = [TYDCharacterRollLabel new];
        detailTextLabel.size = CGSizeMake(150, 30);
        detailTextLabel.font = font;
        detailTextLabel.textColor = textColor;
        detailTextLabel.textAlignment = NSTextAlignmentRight;
        detailTextLabel.text = detailText;
        detailTextLabel.time = 3;
        detailTextLabel.type = CharacterRollLabelRepeat;
        detailTextLabel.gestureEnable = NO;
        
        [self addSubview:detailTextLabel];
        self.contentLabel = detailTextLabel;
    }
    
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    if(self.showAccessoryView)
    {
        self.contentLabel.right = self.right - 30;
    }
    else
    {
        self.contentLabel.right = self.right - 20;
    }               
    
    self.contentLabel.yCenter = self.contentView.yCenter;
    
    [self.contentLabel startAnimation];
}

#pragma mark - ClassMethod

+ (CGFloat)cellHeight
{
    return sBabyDetailCellHeight;
}

@end

#pragma mark - TYDBabyDetailViewController

typedef NS_ENUM(NSInteger, cellPickerViewTag)
{
    sHeightPickerViewTag,
    sWeightPickerViewTag,
};

@interface TYDBabyDetailViewController () <UITableViewDataSource, UITableViewDelegate, UIPickerViewDelegate, UIPickerViewDataSource, UIAlertViewDelegate, BOBottomPopupViewDelegate,TYDSearchAddressDelegate, TYDAvatarModifyCompleteDelegate, TYDModifyBabyInfoDelegate>

@property (strong, nonatomic) NSArray *cellTitles;
@property (strong, nonatomic) UITableView *tableView;
@property (strong, nonatomic) BOBottomPopupView *bottomPopView;
@property (strong, nonatomic) UIDatePicker *birthdayPickerView;
@property (strong, nonatomic) UIPickerView *heightPickerView;
@property (strong, nonatomic) UIPickerView *weightPickerView;

@property (strong, nonatomic) UIView *headerView;
@property (strong, nonatomic) UIImage *avatarImage;
@property (strong, nonatomic) NSString *nickname;
@property (strong, nonatomic) NSString *gender;
@property (assign, nonatomic) NSNumber *colorType;
@property (strong, nonatomic) NSString *kidAvatarPath;

@property (strong, nonatomic) UIImageView *avatarImageView;
@property (strong, nonatomic) UIImageView *genderImageView;
@property (strong, nonatomic) UILabel *nickNameLabel;

@property (strong, nonatomic) NSString *phoneNumber;
@property (strong, nonatomic) NSNumber *birthday;
@property (assign, nonatomic) NSInteger height;
@property (assign, nonatomic) CGFloat weightAll;
@property (assign, nonatomic) NSInteger weight;
@property (assign, nonatomic) NSInteger newWeight;
@property (strong, nonatomic) NSArray *schoolAddressArray;
@property (strong, nonatomic) NSString *schoolAddressAll;
@property (strong, nonatomic) NSString *schoolAddress;
@property (strong, nonatomic) NSArray *famliyAddressArray;
@property (strong, nonatomic) NSString *familyAddressAll;
@property (strong, nonatomic) NSString *famliyAddress;
@property (assign, nonatomic) NSInteger seletedCellRow;

@property (assign, nonatomic) BOOL babyDetailIsChange;
@property (assign, nonatomic) BOOL babyAvatarIsChange;
@property (strong, nonatomic) NSDictionary *modifyInfoDic;

@end

@implementation TYDBabyDetailViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    [self localDataInitialize];
    [self navigationBarItemsLoad];
    [self subviewsLoad];
    
//    [self babyDetailUploadServer];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    long colorHex = [TYDKidInfo kidColorHexWithKidColorType:self.colorType];
    self.navigationController.navigationBar.barTintColor = [UIColor colorWithHex:colorHex];
    
    if(self.bottomPopView.superview == nil)
    {
        [self.navigationController.view addSubview:self.bottomPopView];
    }
    
    [self.tableView reloadData];
}

- (void)viewWillDisappear:(BOOL)animated
{
    self.navigationController.navigationBar.barTintColor = [UIColor colorWithHex:0x6cbb52];
    [self.bottomPopView removeFromSuperview];
}

- (void)localDataInitialize
{
    self.cellTitles = @[@"手机号码",
                        @"生       日",
                        @"身       高",
                        @"体       重",
                        @"学校信息",
                        @"家庭住址"];
    
    TYDKidInfo *currentKidInfo = [TYDDataCenter defaultCenter].currentKidInfo;
    
    self.phoneNumber = currentKidInfo.phoneNumber;
    self.birthday = currentKidInfo.kidBirthday;
    self.height = currentKidInfo.kidHeight.integerValue;
    self.weightAll = currentKidInfo.kidWeight.floatValue;
    
    self.weight = floor(self.weightAll);
    self.newWeight = (self.weightAll -  self.weight) * 10;
    
    self.colorType = currentKidInfo.kidColorType;
    self.nickname = currentKidInfo.kidName;
    self.gender = [TYDKidInfo kidGenderStringWithGender:currentKidInfo.kidGender.integerValue];
    self.kidAvatarPath = currentKidInfo.kidAvatarPath;
    
    self.schoolAddressAll = currentKidInfo.schoolAddress;
    self.schoolAddressArray = [self.schoolAddressAll componentsSeparatedByString:@"&"];
    self.schoolAddress = self.schoolAddressArray[0];
    self.familyAddressAll = currentKidInfo.homeAddress;
    self.famliyAddressArray = [self.familyAddressAll componentsSeparatedByString:@"&"];
    self.famliyAddress = self.famliyAddressArray[0];
    
    self.seletedCellRow = -1;
    self.babyDetailIsChange = NO;
    self.babyAvatarIsChange = NO;
}

- (void)navigationBarItemsLoad
{
    self.title = @"宝贝资料";
    
    UIButton *QRCodeButton = [UIButton new];
    [QRCodeButton setImage:[UIImage imageNamed:@"babyDetail_QRCode"] forState:UIControlStateNormal];
    [QRCodeButton addTarget:self action:@selector(QRCodeButtonTap:) forControlEvents:UIControlEventTouchUpInside];
    [QRCodeButton sizeToFit];
    UIBarButtonItem *QRCodeButtonItem = [[UIBarButtonItem alloc] initWithCustomView:QRCodeButton];
    self.navigationItem.rightBarButtonItem = QRCodeButtonItem;
}

- (void)subviewsLoad
{
    [self tableViewLoad];
}

- (void)tableViewLoad
{
    UIView *tableFootView = [UIView new];
    BOOL tableViewCellCanSelect = NO;
    
    TYDKidInfo *currentKidInfo = [TYDDataCenter defaultCenter].currentKidInfo;
    if(currentKidInfo.kidGuardianType.integerValue == TYDKidContactTypeManager)
    {
        tableViewCellCanSelect = YES;
        
        tableFootView.size = CGSizeMake(self.view.width, 120);
        
        UIImage *buttonBgImageH = [UIImage imageNamed:@"common_buttonBackgroundH"];
        buttonBgImageH = [buttonBgImageH resizableImageWithCapInsets:UIEdgeInsetsMake(1, 1, 1, 1) resizingMode:UIImageResizingModeStretch];
        UIImage *buttonBgImage = [UIImage imageNamed:@"common_buttonBackground"];
        buttonBgImage = [buttonBgImage resizableImageWithCapInsets:UIEdgeInsetsMake(1, 1, 1, 1) resizingMode:UIImageResizingModeStretch];
        
        UIButton *unbindingButton = [UIButton new];
        [unbindingButton setBackgroundImage:buttonBgImageH forState:UIControlStateHighlighted];
        [unbindingButton setBackgroundImage:buttonBgImage forState:UIControlStateNormal];
        [unbindingButton setTitle:@"解除绑定" forState:UIControlStateNormal];
        [unbindingButton setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
        unbindingButton.size = CGSizeMake(self.view.width, 60);
        unbindingButton.center = tableFootView.innerCenter;
        
        [unbindingButton addTarget:self action:@selector(unbindingButtonTap:) forControlEvents:UIControlEventTouchUpInside];
        [tableFootView addSubview:unbindingButton];
    }
    else
    {
        tableFootView.size = CGSizeMake(self.view.width, 20);
        tableFootView.backgroundColor = [UIColor clearColor];
    }

    UITableView *tableView = [[UITableView alloc] initWithFrame:self.view.frame style:UITableViewStylePlain];
    tableView.backgroundColor = cBasicBackgroundColor;
    tableView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    tableView.showsVerticalScrollIndicator = NO;
    tableView.allowsSelection = tableViewCellCanSelect;
    tableView.dataSource = self;
    tableView.delegate = self;
    tableView.tableFooterView = tableFootView;
    [self.view addSubview:tableView];
    
    self.tableView = tableView;
}

#pragma mark - OverridePickerPropertyMethod

- (UIPickerView *)heightPickerView
{
    if(_heightPickerView == nil)
    {
        UIPickerView *pickerView = [UIPickerView new];
        pickerView.backgroundColor = [UIColor colorWithHex:0xefeef0];
        pickerView.delegate = self;
        pickerView.dataSource = self;
        pickerView.tag = sHeightPickerViewTag;
        
        UILabel *cmLabel = [UILabel new];
        cmLabel.backgroundColor = [UIColor clearColor];
        cmLabel.textColor = [UIColor blackColor];
        cmLabel.font = [UIFont systemFontOfSize:20];
        cmLabel.text = @"CM";
        [cmLabel sizeToFit];
        cmLabel.center = pickerView.innerCenter;
        cmLabel.left += 70;
        [pickerView addSubview:cmLabel];
        
        if(self.height >= sBabyMinimumHeight)
        {
            [pickerView selectRow:(self.height - sBabyMinimumHeight) inComponent:0 animated:YES];
        }
        
        _heightPickerView = pickerView;
    }
    return _heightPickerView;
}

- (UIPickerView *)weightPickerView
{
    if(_weightPickerView == nil)
    {
        UIPickerView *pickerView = [UIPickerView new];
        pickerView.backgroundColor = [UIColor colorWithHex:0xefeef0];
        pickerView.delegate = self;
        pickerView.dataSource = self;
        
        pickerView.tag = sWeightPickerViewTag;
        
        UILabel *dotLabel = [[UILabel alloc] initWithFrame:CGRectMake(pickerView.xCenter, pickerView.yCenter, 6, 6)];
        dotLabel.backgroundColor = [UIColor blackColor];
        dotLabel.layer.cornerRadius = 3;
        dotLabel.layer.masksToBounds = YES;
        [pickerView addSubview:dotLabel];
        
        UILabel *kgLabel = [UILabel new];
        kgLabel.backgroundColor = [UIColor clearColor];
        kgLabel.textColor = [UIColor blackColor];
        kgLabel.font = [UIFont systemFontOfSize:20];
        kgLabel.text = @"KG";
        [kgLabel sizeToFit];
        kgLabel.center = CGPointMake(pickerView.right - 35, pickerView.center.y);
        [pickerView addSubview:kgLabel];
        
        if(self.weight >= sBabyMinimumWeight)
        {
            [pickerView selectRow:(self.weight - sBabyMinimumWeight) inComponent:0 animated:YES];
            [pickerView selectRow:self.newWeight inComponent:1 animated:YES];
        }
        
        _weightPickerView = pickerView;
    }
    
    return _weightPickerView;
}

- (UIDatePicker *)birthdayPickerView
{
    if(_birthdayPickerView == nil)
    {
        int currentYear = [BOTimeStampAssistor getYearStringWithTimeStamp:[BOTimeStampAssistor getCurrentTime]].intValue;
        NSString *minDateString = [NSString stringWithFormat:@"%04d0101", (int)currentYear - sBabyMaxBirthdayYear];
        NSDateFormatter *dateFormat = [NSDateFormatter new];
        dateFormat.dateFormat = @"yyyyMMdd";
        NSDate *minDate = [dateFormat dateFromString:minDateString];
        NSTimeInterval maxTimeInterval = [BOTimeStampAssistor getCurrentTime];
        NSDate *maxDate = [[NSDate alloc] initWithTimeIntervalSince1970:maxTimeInterval];
        
        UIDatePicker *birthdayPickerView = [UIDatePicker new];
        birthdayPickerView.backgroundColor = [UIColor colorWithHex:0xefeef0];
        birthdayPickerView.datePickerMode = UIDatePickerModeDate;
        birthdayPickerView.minimumDate = minDate;
        birthdayPickerView.maximumDate = maxDate;
        
        [birthdayPickerView setDate:[NSDate dateWithTimeIntervalSince1970:self.birthday.longLongValue]];
        [birthdayPickerView addTarget:self action:@selector(datePickerValueChanged:) forControlEvents:UIControlEventValueChanged];
        _birthdayPickerView = birthdayPickerView;
    }
    return _birthdayPickerView;
}

- (BOBottomPopupView *)bottomPopView
{
    if(_bottomPopView == nil)
    {
        BOBottomPopupView *bottomPopupView = [[BOBottomPopupView alloc] initWithCustomViews:@[self.birthdayPickerView, self.heightPickerView, self.weightPickerView]];
        bottomPopupView.delegate = self;
        
        [self.navigationController.view addSubview:bottomPopupView];
        _bottomPopView = bottomPopupView;
    }
    
    return _bottomPopView;
}

#pragma mark - TouchEvent

- (void)QRCodeButtonTap:(UIButton *)sender
{
    NSLog(@"QRCodeButtonTap");
    
    //生成二维码
    TYDGenerateQRCodeController *vc = [TYDGenerateQRCodeController new];
    vc.watchID = [TYDDataCenter defaultCenter].currentKidInfo.watchID;
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)datePickerValueChanged:(UIDatePicker *)datePicker
{
    NSDate *birthdayDate = datePicker.date;
    self.birthday = @(birthdayDate.timeIntervalSince1970);
    
    NSDateFormatter *dateFormatter = [NSDateFormatter new];
    dateFormatter.dateFormat = @"yyyy-MM-dd";
    NSString *birthdayString = [dateFormatter stringFromDate:birthdayDate];
    
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:self.seletedCellRow inSection:0];
    TYDBabyDetailTableViewCell *cell = (TYDBabyDetailTableViewCell *)[self.tableView cellForRowAtIndexPath:indexPath];
    cell.contentLabel.text = birthdayString;
}

- (void)modifyButtonTap:(UITapGestureRecognizer *)sender
{
    TYDKidInfo *currentKidInfo = [TYDDataCenter defaultCenter].currentKidInfo;
    if(currentKidInfo.kidGuardianType.integerValue == TYDKidContactTypeManager)
    {
        TYDModifyBabyInfoController *vc = [TYDModifyBabyInfoController new];
        vc.colorType = self.colorType;
        vc.nickname = self.nickname;
        vc.gender = self.gender;
        vc.delegate = self;
        
        [self.navigationController pushViewController:vc animated:YES];
    }
}

- (void)avatarImageViewTap:(UITapGestureRecognizer *)sender
{
    TYDKidInfo *currentKidInfo = [TYDDataCenter defaultCenter].currentKidInfo;
    if(currentKidInfo.kidGuardianType.integerValue == TYDKidContactTypeManager)
    {
        NSString *avatarImageName = [self.gender isEqualToString:@"男"] ? @"main_left_babyMale" : @"main_left_babyFemale";
        
        TYDAvatarModifyController *vc = [TYDAvatarModifyController new];
        vc.avatarImage = self.avatarImage ? self.avatarImage : [UIImage imageNamed:avatarImageName];
        vc.delegate = self;
        
        [self.navigationController pushViewController:vc animated:YES];
    }
}

- (void)unbindingButtonTap:(UIButton *)sender
{
//    TYDUnbindingController *vc = [TYDUnbindingController new];
//    [self.navigationController pushViewController:vc animated:YES];
    
    UIAlertView *passwordDialog = [[UIAlertView alloc] initWithTitle:@"解除设备" message:@"设备将恢复出厂设置，请输入密码确认" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确认", nil];
    passwordDialog.alertViewStyle = UIAlertViewStylePlainTextInput;
    [[passwordDialog textFieldAtIndex:0] setKeyboardType:UIKeyboardTypeNumbersAndPunctuation];
    [passwordDialog textFieldAtIndex:0].secureTextEntry = YES;

    [passwordDialog show];
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.cellTitles.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.row == 0)
    {
        TYDBabyDetailTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cellIdentifier"];
        if(!cell)
        {
            cell = [[TYDBabyDetailTableViewCell alloc] initWithCellTitle:self.cellTitles[indexPath.row] cellDetailContent:self.phoneNumber reuseIdentifier:@"cellIdentifier" showAccessoryView:NO];
        }
        
        return cell;
    }
    else if(indexPath.row == 1)
    {
        NSString *birthdayString = [BOTimeStampAssistor getDateStringWithTimeStamp:self.birthday.longValue];
        
        TYDBabyDetailTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cellIdentifier"];
        if(!cell)
        {
            cell = [[TYDBabyDetailTableViewCell alloc] initWithCellTitle:self.cellTitles[indexPath.row] cellDetailContent:birthdayString reuseIdentifier:@"cellIdentifier" showAccessoryView:NO];
        }
        
        return cell;
    }
    else if(indexPath.row == 2)
    {
        NSString *heightString = [NSString stringWithFormat:@"%dCM", (int)self.height];
        
        TYDBabyDetailTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cellIdentifier"];
        if(!cell)
        {
            cell = [[TYDBabyDetailTableViewCell alloc] initWithCellTitle:self.cellTitles[indexPath.row] cellDetailContent:heightString  reuseIdentifier:@"cellIdentifier" showAccessoryView:NO];
        }
        
        return cell;
    }
    else if(indexPath.row == 3)
    {
        NSString *weightString = [NSString stringWithFormat:@"%.1fKG", self.weightAll];
        
        TYDBabyDetailTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cellIdentifier"];
        if(!cell)
        {
            cell = [[TYDBabyDetailTableViewCell alloc] initWithCellTitle:self.cellTitles[indexPath.row] cellDetailContent:weightString  reuseIdentifier:@"cellIdentifier" showAccessoryView:NO];
        }
        
        return cell;
    }
    else if(indexPath.row == 4)
    {
        TYDBabyDetailTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"addressCell"];
        if(!cell)
        {
            cell = [[TYDBabyDetailTableViewCell alloc] initWithCellTitle:self.cellTitles[indexPath.row] cellDetailContent:self.schoolAddress  reuseIdentifier:@"addressCell" showAccessoryView:YES];
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        }
        
        return cell;
    }
    else
    {
        TYDBabyDetailTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"addressCell"];
        if(!cell)
        {
            cell = [[TYDBabyDetailTableViewCell alloc] initWithCellTitle:self.cellTitles[indexPath.row] cellDetailContent:self.famliyAddress  reuseIdentifier:@"addressCell" showAccessoryView:YES];
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        }
        
        return cell;
    }
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [TYDBabyDetailTableViewCell cellHeight];
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *baseView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, 124)];
    baseView.backgroundColor = [UIColor colorWithHex:[TYDKidInfo kidColorHexWithKidColorType:self.colorType]];
    self.headerView = baseView;
    
    UIImageView *avatarImageView = [UIImageView new];
    avatarImageView.backgroundColor = [UIColor grayColor];
    avatarImageView.userInteractionEnabled = YES;
    avatarImageView.size = CGSizeMake(70, 70);
    avatarImageView.center = CGPointMake(baseView.xCenter, 13 + avatarImageView.height / 2);
    avatarImageView.layer.borderWidth = 2;
    avatarImageView.layer.borderColor = [UIColor colorWithHex:0xffdd3e].CGColor;
    avatarImageView.layer.cornerRadius = avatarImageView.width / 2;
    avatarImageView.layer.masksToBounds = YES;
    
    NSString *avatarImageName = [self.gender isEqualToString:@"男"] ? @"main_left_babyMale" : @"main_left_babyFemale";
    UIImage *avatarImage = self.avatarImage ? self.avatarImage : [UIImage imageNamed:avatarImageName];
    if(self.kidAvatarPath && self.kidAvatarPath.length != 0 && !self.babyAvatarIsChange)
    {
        [avatarImageView setImageWithURL:[NSURL URLWithString:self.kidAvatarPath]
                        placeholderImage:[UIImage imageNamed:avatarImageName]
                               completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType){
                                   _avatarImage = image;
                               }];
    }
    else
    {
        avatarImageView.image = avatarImage;
    }
    
    UITapGestureRecognizer *GR = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(avatarImageViewTap:)];
    [avatarImageView addGestureRecognizer:GR];
    [baseView addSubview:avatarImageView];
    self.avatarImageView = avatarImageView;
    
    UILabel *nickNameLabel = [UILabel new];
    nickNameLabel.backgroundColor = [UIColor clearColor];
    nickNameLabel.textColor = [UIColor whiteColor];
    nickNameLabel.font = [BOAssistor defaultTextStringFontWithSize:14];
    nickNameLabel.text = self.nickname;
    [nickNameLabel sizeToFit];
    nickNameLabel.xCenter = avatarImageView.xCenter;
    nickNameLabel.top = avatarImageView.bottom + 9;
    [baseView addSubview:nickNameLabel];
    self.nickNameLabel = nickNameLabel;
    
    UIImageView *genderImageView = [UIImageView new];
    NSString *genderViewName = [self.gender isEqualToString:@"女"] ? @"babyDetail_female" : @"babyDetail_male";
    genderImageView.size = CGSizeMake(11, 11);
    genderImageView.left = nickNameLabel.right + 8;
    genderImageView.yCenter = nickNameLabel.yCenter;
    genderImageView.image = [UIImage imageNamed:genderViewName];
    [baseView addSubview:genderImageView];
    self.genderImageView = genderImageView;
    
    UIButton *modifyButton = [UIButton new];
    modifyButton.size = CGSizeMake(30, 30);
    modifyButton.bottom = baseView.height - 10;
    modifyButton.right = baseView.width - 17;
    [modifyButton setImage:[UIImage imageNamed:@"babyDetail_modify"] forState:UIControlStateNormal];
    [modifyButton addTarget:self action:@selector(modifyButtonTap:) forControlEvents:UIControlEventTouchUpInside];
    [baseView addSubview:modifyButton];

    return baseView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 124;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    TYDKidInfo *currentKidInfo = [TYDDataCenter defaultCenter].currentKidInfo;
    if(currentKidInfo.kidGuardianType.integerValue != TYDKidContactTypeManager)
    {
        [tableView deselectRowAtIndexPath:indexPath animated:NO];
        return;
    }
    
    self.seletedCellRow = indexPath.row;
    
    if(indexPath.row == 0)
    {
        UIAlertView *passwordDialog = [[UIAlertView alloc] initWithTitle:@"修改号码"
                                                                 message:@"请输入手机号码"
                                                                delegate:self
                                                       cancelButtonTitle:@"取消"
                                                       otherButtonTitles:@"确定", nil];
        passwordDialog.alertViewStyle = UIAlertViewStylePlainTextInput;
        [[passwordDialog textFieldAtIndex:0] setKeyboardType:UIKeyboardTypeNumbersAndPunctuation];
        
        [passwordDialog show];
    }
    else if(indexPath.row == 1)
    {
        self.bottomPopView.currentVisibleCustomView = self.birthdayPickerView;
        [self.bottomPopView bottomPopupViewShowAnimated];
    }
    else if(indexPath.row == 2)
    {
        self.bottomPopView.currentVisibleCustomView = self.heightPickerView;
        [self.bottomPopView bottomPopupViewShowAnimated];
    }
    else if(indexPath.row == 3)
    {
        self.bottomPopView.currentVisibleCustomView = self.weightPickerView;
        [self.bottomPopView bottomPopupViewShowAnimated];
    }
    else if(indexPath.row == 4)
    {
        TYDSearchAddressController *vc = [TYDSearchAddressController new];
        vc.delegate = self;
        vc.addressType = TYDAddressSchoolType;
        vc.addressArray = self.schoolAddressArray;
        [self.navigationController pushViewController:vc animated:YES];
    }
    else if(indexPath.row == 5)
    {
        TYDSearchAddressController *vc = [TYDSearchAddressController new];
        vc.delegate = self;
        vc.addressType = TYDAddressFamilyType;
        vc.addressArray = self.famliyAddressArray;
        [self.navigationController pushViewController:vc animated:YES];
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - UIPickerViewDataSource & UIPickerViewDelegate

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    if(pickerView.tag == sHeightPickerViewTag)
    {
        return 1;
    }
    else
    {
        return 2;
    }
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    if(pickerView.tag == sHeightPickerViewTag)
    {
        return sBabyMaximumHeight - sBabyMinimumHeight + 1;
    }
    else
    {
        if(component == 0)
        {
            return sBabyMaximumWeight - sBabyMinimumWeight;
        }
        else
        {
            return 10;
        }
    }
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    if(pickerView.tag == sHeightPickerViewTag)
    {
        return [NSString stringWithFormat:@"%d", (int)(row + sBabyMinimumHeight)];
    }
    else
    {
        if(component == 0)
        {
            return [NSString stringWithFormat:@"%d", (int)(row + sBabyMinimumWeight)];
        }
        else
        {
            return [NSString stringWithFormat:@"%d", (int)row];
        }
    }
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    if(pickerView.tag == sHeightPickerViewTag)
    {
        self.height = row + sBabyMinimumHeight;
    }
    else
    {
        if(component == 0)
        {
            self.weight = row + sBabyMinimumWeight;
        }
        else
        {
            self.newWeight = row;
        }
    }
}

#pragma mark - BOBottomPopupViewDelegate

- (void)bottomPopupViewDidHidden:(BOBottomPopupView *)view
{
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:self.seletedCellRow inSection:0];
    TYDBabyDetailTableViewCell *cell = (TYDBabyDetailTableViewCell *)[self.tableView cellForRowAtIndexPath:indexPath];
    
    if(self.seletedCellRow == 2)
    {
        cell.contentLabel.text = [NSString stringWithFormat:@"%dCM", (int)self.height];
    }
    else if(self.seletedCellRow == 3)
    {
        cell.contentLabel.text = [NSString stringWithFormat:@"%d.%dKG", (int)self.weight, (int)self.newWeight];
        
        self.weightAll = cell.contentLabel.text.floatValue;
    }
    
    self.seletedCellRow = -1;
}

#pragma mark - TYDModifyBabyInfoDelegate

- (void)modifyBabyInfoCompleteWithHeaderViewColor:(NSNumber *)colorType
                                         nickname:(NSString *)nickname
                                           gender:(NSString *)gender
{
    self.colorType = colorType;
    self.nickname = nickname;
    self.gender = gender;
    
    self.babyDetailIsChange = YES;
}

#pragma mark - TYDSearchAddressDelegate

- (void)searchAddressComplete:(NSString *)addressString
{
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:self.seletedCellRow inSection:0];
    TYDBabyDetailTableViewCell *cell = (TYDBabyDetailTableViewCell *)[self.tableView cellForRowAtIndexPath:indexPath];
    
    NSArray *addressArray = [addressString componentsSeparatedByString:@"&"];
    
    cell.contentLabel.text = addressArray[0];
    
    if(self.seletedCellRow == 4)
    {
        self.schoolAddressAll = addressString;
        self.schoolAddressArray = addressArray;
        self.schoolAddress = addressArray[0];
    }
    else if(self.seletedCellRow == 5)
    {
        self.familyAddressAll = addressString;
        self.famliyAddressArray = addressArray;
        self.famliyAddress = addressArray[0];
    }
}

#pragma mark - TYDAvatarModifyCompleteDelegate

- (void)avatarModifyComplete:(UIImage *)avatarImage
{
    NSLog(@"avatarModifyComplete");
    
    self.avatarImage = avatarImage;
    
    self.babyAvatarIsChange = YES;
}

#pragma mark - OverrideMethod

- (void)setAvatarImage:(UIImage *)avatarImage
{
    if(self.avatarImage != avatarImage)
    {
        _avatarImage = avatarImage;
        self.avatarImageView.image = avatarImage;
    }
}

-(void)setNickname:(NSString *)nickname
{
    if(self.nickname != nickname)
    {
        _nickname = nickname;
        self.nickNameLabel.text = nickname;
        
        [self.nickNameLabel sizeToFit];
        
        self.nickNameLabel.xCenter = self.avatarImageView.xCenter;
        self.nickNameLabel.top = self.avatarImageView.bottom + 9;
        
        self.genderImageView.left = self.nickNameLabel.right + 8;
        self.genderImageView.yCenter = self.nickNameLabel.yCenter;
    }
}

- (void)setGender:(NSString *)gender
{
    if(self.gender != gender)
    {
        if([gender isEqualToString:@"男"])
        {
            self.genderImageView.image = [UIImage imageNamed:@"babyDetail_male"];
        }
        else
        {
            self.genderImageView.image = [UIImage imageNamed:@"babyDetail_female"];
        }
        
        if(!self.kidAvatarPath || self.kidAvatarPath.length == 0)
        {
            if([gender isEqualToString:@"男"])
            {
                self.avatarImageView.image = [UIImage imageNamed:@"main_left_babyMale"];
            }
            else if([gender isEqualToString:@"女"])
            {
                self.avatarImageView.image = [UIImage imageNamed:@"main_left_babyFemale"];
            }
        }
        
        _gender = gender;
    }
}

- (void)setColorType:(NSNumber *)colorType
{
    long colorHex = [TYDKidInfo kidColorHexWithKidColorType:colorType];
    self.headerView.backgroundColor = [UIColor colorWithHex:colorHex];
    
    _colorType = colorType;
}

#pragma mark - OverrideMethod

- (void)popBackEventWillHappen
{
    if([self kidInfoChangeCheck])
    {
        [self babyDetailUploadServer];
    }
    else
    {
        [super popBackEventWillHappen];
    }
}

- (BOOL)kidInfoChangeCheck
{
    TYDKidInfo *currentKidInfo = [TYDDataCenter defaultCenter].currentKidInfo;
    
    if(![currentKidInfo.kidBirthday isEqualToNumber:self.birthday]
       || currentKidInfo.kidHeight.integerValue != self.height
       || currentKidInfo.kidWeight.integerValue != self.weightAll
       || ![currentKidInfo.homeAddress isEqualToString:self.familyAddressAll]
       || ![currentKidInfo.schoolAddress isEqualToString:self.schoolAddressAll]
       || ![currentKidInfo.phoneNumber isEqualToString:self.phoneNumber]
       || self.babyDetailIsChange
       || self.babyAvatarIsChange)
    {
        return YES;
    }
    
    return NO;
}

#pragma mark - BabyDetailUploadServer

- (void)babyDetailUploadServer
{
    if([TYDPostUrlRequest networkConnectionIsAvailable])
    {
        TYDKidInfo *currentKidInfo = [TYDDataCenter defaultCenter].currentKidInfo;
        
        double birthdayTimeInterval = self.birthday.doubleValue;
        double currentTimeInterval = [BOTimeStampAssistor getCurrentTime];
        int age = (currentTimeInterval - birthdayTimeInterval) / (365 * 24 * 60 * 60);
        NSNumber *gender = [TYDKidInfo kidGenderWithGenderString:self.gender];
        
        NSMutableDictionary *params = [NSMutableDictionary new];
        
        if(self.avatarImage && self.babyAvatarIsChange)
        {
            //将图片数据转换格式
            NSData *cameraAvatarData = UIImagePNGRepresentation(self.avatarImage);
            NSString *cameraAvatarString = [GTMBase64 stringByEncodingData:cameraAvatarData];
            [params setValue:cameraAvatarString forKey:@"img"];
        }
        
        [params setValue:currentKidInfo.kidID forKey:@"childid"];
        [params setValue:self.nickname forKey:@"childname"];
        [params setValue:gender forKey:@"sex"];
        [params setValue:@(age) forKey:@"age"];
        [params setValue:self.birthday forKey:@"birthday"];
        [params setValue:self.colorType forKey:@"color"];
        [params setValue:self.phoneNumber forKey:@"phone"];
        [params setValue:self.familyAddressAll forKey:@"address"];
        [params setValue:self.schoolAddressAll forKey:@"school"];
        [params setValue:currentKidInfo.watchID forKey:@"watchid"];
        [params setValue:@(self.height) forKey:@"height"];
        [params setValue:@(self.weightAll) forKey:@"weight"];
        
        [params setValue:currentKidInfo.autoConnectState forKey:@"autoconnect"];
        [params setValue:currentKidInfo.silentState forKey:@"silentstatus"];
        [params setValue:currentKidInfo.silentTime forKey:@"silenttime"];
        [params setValue:currentKidInfo.backlightTime forKey:@"backlighttime"];
        [params setValue:currentKidInfo.watchSoundState forKey:@"watchsound"];
        [params setValue:currentKidInfo.watchShockState forKey:@"watchshock"];
        [params setValue:currentKidInfo.capInterval forKey:@"cpinterval"];
        [params setValue:currentKidInfo.electronicFenceState forKey:@"electronicfence"];
        [params setValue:currentKidInfo.fenceCenterPoint forKey:@"electronicFencePoints"];
        [params setValue:currentKidInfo.fenceRadius forKey:@"radius"];
        [params setValue:currentKidInfo.castOff forKey:@"castoff"];
        
        self.modifyInfoDic = params;
        
//        [params setValue:@"141414141414145" forKey:@"watchid"];
//        [params setValue:@"15556690171" forKey:@"phone"];
//        [params setValue:@"1111111111111111" forKey:@"deviceid"];
        
        [self postURLRequestWithMessageCode:ServiceMsgCodeKidInfoUpdate
                               HUDLabelText:nil
                                     params:params
                              completeBlock:^(id result) {
                                   [self modifyComplete:result];
                              }];
    }
    else
    {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"网络连接" message:@"请保持网络连接，是否放弃保存？" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"放弃", nil];
        [alertView show];
    }
}

- (void)modifyComplete:(id)result
{
    NSLog(@"modifyComplete:%@", result);
    
    [self progressHUDHideImmediately];
    
    NSString *imgUrlString = result[@"img"];
    NSNumber *value = result[@"result"];
    
    if(value.intValue == 0)
    {
        [self.modifyInfoDic setValue:imgUrlString forKey:@"img"];
        [[TYDDataCenter defaultCenter].currentKidInfo setAttributes:self.modifyInfoDic];
        
        [super popBackEventWillHappen];
    }
    else
    {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"保存失败" message:@"宝贝资料，是否重新保存？" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
        [alertView show];
    }
}

- (void)unbindingWatchWithPassword:(NSString *)password
{
    NSMutableDictionary *params = [NSMutableDictionary new];
    [params setValue:[TYDUserInfo sharedUserInfo].openID forKey:@"openid"];
    [params setValue:[TYDDataCenter defaultCenter].currentKidInfo.watchID forKey:@"watchid"];
    [params setValue:password forKey:@"password"];
    
    [self postURLRequestWithMessageCode:ServiceMsgCodeUnbindWatchAdmin
                           HUDLabelText:nil
                                 params:params
                          completeBlock:^(id result) {
                              [self unbindingWatchSuccess:result];
                          }];
}

- (void)unbindingWatchSuccess:(id)result
{
    NSLog(@"unbindingWatchSuccess");
    
    [self progressHUDHideImmediately];
    
    NSNumber *value = result[@"result"];
    
    if(value && value.integerValue == 0)
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
    else if(value.integerValue == 11)
    {
        self.noticeText = @"密码错误";
    }
    else
    {
        self.noticeText = @"解绑失败";
    }
}

- (void)postURLRequestFailed:(NSUInteger)msgCode result:(id)result
{
    [super postURLRequestFailed:msgCode result:result];
    
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"保存失败" message:@"宝贝资料，是否重新保存？" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
    [alertView show];
}

#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSString *buttonTitle = [alertView buttonTitleAtIndex:buttonIndex];
    
    if([alertView.title isEqualToString:@"保存失败"])
    {
        if(alertView.cancelButtonIndex == buttonIndex)
        {
            [super popBackEventWillHappen];
        }
        else
        {
            if([buttonTitle isEqualToString:@"确定"])
            {
                [self babyDetailUploadServer];
            }
        }
    }
    else if([alertView.title isEqualToString:@"网络连接"])
    {
        if(alertView.cancelButtonIndex != buttonIndex)
        {
            if([buttonTitle isEqualToString:@"放弃"])
            {
                [super popBackEventWillHappen];
            }
        }
    }
    else if([alertView.title isEqualToString:@"修改号码"])
    {
        if(alertView.cancelButtonIndex != buttonIndex)
        {
            if([buttonTitle isEqualToString:@"确定"])
            {
                NSString *phoneNumber = [alertView textFieldAtIndex:0].text;
                
                if([BOAssistor cellPhoneNumberIsValid:phoneNumber])
                {
                    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:self.seletedCellRow inSection:0];
                    TYDBabyDetailTableViewCell *cell = (TYDBabyDetailTableViewCell *)[self.tableView cellForRowAtIndexPath:indexPath];
                    cell.contentLabel.text = phoneNumber;
                    
                    self.phoneNumber = phoneNumber;
                }
                else
                {
                    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"号码输入" message:@"您输入的号码有误，请重新输入" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
                    [alertView show];
                }
            }
        }
    }
    else if([alertView.title isEqualToString:@"解除设备"])
    {
        if(alertView.cancelButtonIndex != buttonIndex)
        {
            if([buttonTitle isEqualToString:@"确认"])
            {
                NSString *password = [alertView textFieldAtIndex:0].text;
                [self unbindingWatchWithPassword:password.MD5String];
            }
        }
    }
}

@end

