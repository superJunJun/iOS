//
//  TYDContactTableViewCell.m
//  DroiKids
//
//  Created by superjunjun on 15/8/21.
//  Copyright (c) 2015年 superjunjun. All rights reserved.
//

#import "TYDContactTableViewCell.h"

@interface TYDContactTableViewCell ()

@property (strong, nonatomic) UIImageView *appAccessoryView;
@property (strong, nonatomic) UILabel *managerAccessoryView;
@property (strong, nonatomic) UILabel *quicklyDialLabel;

@end

@implementation TYDContactTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if(self = [super initWithStyle:style reuseIdentifier:reuseIdentifier])
    {
        self.textLabel.textColor = [UIColor colorWithHex:0x000000];
        self.detailTextLabel.textColor = [UIColor colorWithHex:0x686868];
        
        self.contactType = TYDKidContactTypeNormal;
        self.quicklyNumberType = -1;
        
        UILabel *quicklyDialLabel = [UILabel new];
        quicklyDialLabel.backgroundColor = [UIColor clearColor];
        quicklyDialLabel.font = [UIFont systemFontOfSize:8];
        quicklyDialLabel.textColor = [UIColor colorWithHex:0x6cbb52];
        quicklyDialLabel.text = @" ";
        [quicklyDialLabel sizeToFit];
        [self addSubview:quicklyDialLabel];
        self.quicklyDialLabel = quicklyDialLabel;
        
        UIImageView *appAccessoryView = [UIImageView new];
        appAccessoryView.size = CGSizeMake(19, 19);
        appAccessoryView.image = [UIImage imageNamed:@"addressBook_APP"];
        self.appAccessoryView = appAccessoryView;
        
        UILabel *managerAccessoryView = [UILabel new];
        managerAccessoryView.backgroundColor = [UIColor clearColor];
        managerAccessoryView.font = [UIFont systemFontOfSize:11];
        managerAccessoryView.textColor = [UIColor colorWithHex:0x6cbb52];
        managerAccessoryView.text = @"管理员";
        [managerAccessoryView sizeToFit];
        self.managerAccessoryView = managerAccessoryView;
    }
    
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGPoint imageViewCenter = self.imageView.center;
    self.imageView.size = CGSizeMake(48, 48);
    self.imageView.center = imageViewCenter;
    self.imageView.layer.cornerRadius = self.imageView.width / 2;
    self.imageView.layer.masksToBounds = YES;
    
    [self.quicklyDialLabel sizeToFit];
    self.quicklyDialLabel.left = self.textLabel.right + 2;
    self.quicklyDialLabel.bottom = self.textLabel.bottom;
}

+ (CGFloat)cellHeight
{
    return 60;
}

#pragma mark - OverridePropertyMethod

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
}

- (void)setContactType:(TYDKidContactType)contactType
{
    if(self.contactType != contactType)
    {
        if(contactType == TYDKidContactTypeManager)
        {
            self.accessoryView = self.managerAccessoryView;
        }
        else if(contactType == TYDKidContactTypeGuardian)
        {
            self.accessoryView = self.appAccessoryView;
        }
        else
        {
            self.accessoryView.hidden = YES;
        }
        
        _contactType = contactType;
    }
}

- (void)setQuicklyNumberType:(TYDKidContactQuickNumber)quicklyNumberType
{
    if(self.quicklyNumberType != quicklyNumberType)
    {
        if(quicklyNumberType == TYDKidContactQuickNumber1st)
        {
            self.quicklyDialLabel.text = @"快捷拨号1";
        }
        else if(quicklyNumberType == TYDKidContactQuickNumber2nd)
        {
            self.quicklyDialLabel.text = @"快捷拨号2";
        }
        else if(quicklyNumberType == TYDKidContactQuickNumberNone)
        {
            self.quicklyDialLabel.text = @" ";
        }
        
        _quicklyNumberType = quicklyNumberType;
    }
}

- (void)setKidContactInfo:(TYDKidContactInfo *)kidContactInfo
{
    NSString *userOpenID = [TYDUserInfo sharedUserInfo].openID;
    NSString *titleText = [userOpenID isEqualToString:kidContactInfo.contactOpenID] ? @"我" : kidContactInfo.contactName;
    NSString *avatarString = [NSString stringWithFormat:@"addressBookAvatar_%@", kidContactInfo.contactAvatarID];
    NSString *detailText = nil;
    NSMutableAttributedString *attributedText = nil;
    
    if(kidContactInfo.shortNumber.length == 0)
    {
        detailText = kidContactInfo.contactNumber;
        self.detailTextLabel.text = detailText;
    }
    else
    {
        NSString *string = [NSString stringWithFormat:@"%@ | %@", kidContactInfo.contactNumber, kidContactInfo.shortNumber];
        
        attributedText = [self labelTextAttributedString:string textColor:[UIColor colorWithHex:0x686868] symbol:@"|" symbolColor:[UIColor colorWithHex:0xdfdfdf]];
        self.detailTextLabel.attributedText = attributedText;
    }

    
    self.textLabel.text = titleText;
    self.imageView.image = [UIImage imageNamed:avatarString];
    
    self.quicklyNumberType = kidContactInfo.quicklyNumberType.integerValue;
    self.contactType = kidContactInfo.contactType.integerValue;
    
    _kidContactInfo = kidContactInfo;
}

#pragma mark - DisplayUtil

- (NSMutableAttributedString *)labelTextAttributedString:(NSString *)text  textColor:(UIColor *)textColor symbol:(NSString *)symbol symbolColor:(UIColor *)symbolColor
{
    NSMutableAttributedString *attributeString = [[NSMutableAttributedString alloc] initWithString:text attributes:@{NSForegroundColorAttributeName:textColor}];
    [attributeString setAttributes:@{NSForegroundColorAttributeName:symbolColor} range:[text rangeOfString:symbol]];
    
    return attributeString;
}

@end
