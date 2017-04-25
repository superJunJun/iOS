//
//  TYDAddressBookAvatarChooseBlock.m
//  DroiKids
//
//  Created by wangchao on 15/8/26.
//  Copyright (c) 2015年 TYDTech. All rights reserved.
//

#import "TYDAddressBookAvatarChooseBlock.h"
#import "TYDKidContactInfo.h"

@interface TYDAddressBookAvatarChooseBlock ()

@property (strong, nonatomic) UIImageView *checkIcon;
@property (strong, nonatomic) UIImageView *avatarImageView;
@property (strong, nonatomic) NSDictionary *avatarInfoDic;

@end

@implementation TYDAddressBookAvatarChooseBlock

- (instancetype)initWithAvatarSizeLength:(CGFloat)sizeLength relationShipName:(NSNumber *)avatarID
{
    if(self = [self init])
    {
        self.avatarID = avatarID;
        
        self.avatarInfoDic = @{@(TYDKidContactFather):@"爸爸",
                               @(TYDKidContactMother):@"妈妈",
                               @(TYDKidContactGrandFather):@"爷爷",
                               @(TYDKidContactGrandMother):@"奶奶",
                               @(TYDKidContactOther):@"其他"};
        
        self.checkIconVisible = NO;
        self.avatarImage = [UIImage imageNamed:[NSString stringWithFormat:@"addressBookAvatar_%d", avatarID.intValue]];
        
        [self avatarLoadWithLength:sizeLength avatarImage:self.avatarImage relationShipName:self.avatarInfoDic[avatarID]];
        
        [self checkIconLoad];
    }
    
    return self;
}

- (void)avatarLoadWithLength:(CGFloat)sizeLength avatarImage:(UIImage *)avatarImage relationShipName:(NSString *)relationShipName
{
    UIImageView *avatarImageView = [UIImageView new];
    avatarImageView.size = CGSizeMake(sizeLength, sizeLength);
    avatarImageView.origin = CGPointMake(0, 0);
    avatarImageView.layer.cornerRadius = sizeLength / 2;
    avatarImageView.layer.masksToBounds = YES;
    avatarImageView.image = avatarImage;
    
    self.avatarImageView = avatarImageView;
    
    UILabel *nameLabel = [UILabel new];
    nameLabel.backgroundColor = [UIColor clearColor];
    nameLabel.font = [UIFont systemFontOfSize:14];
    nameLabel.textColor = [UIColor colorWithHex:0x535457];
    nameLabel.text = relationShipName;
    [nameLabel sizeToFit];
    nameLabel.center = avatarImageView.center;
    nameLabel.top = avatarImageView.bottom + 8;
    
    [self addSubview:avatarImageView];
    [self addSubview:nameLabel];
    
    CGFloat blockHeight = avatarImageView.height + 8 + nameLabel.height;
    
    self.size = CGSizeMake(MAX(avatarImageView.width, nameLabel.width), blockHeight);
}

- (void)checkIconLoad
{
    UIImageView *checkIcon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"addressBook_selectContact"]];
    checkIcon.backgroundColor = [UIColor clearColor];
    checkIcon.frame = self.avatarImageView.frame;
    checkIcon.layer.cornerRadius = checkIcon.frame.size.width / 2;
    checkIcon.layer.masksToBounds = YES;
    [self.avatarImageView addSubview:checkIcon];
    
    checkIcon.hidden = self.checkIconVisible ? NO : YES;
    self.checkIcon = checkIcon;
}

-(void)setCheckIconVisible:(BOOL)checkIconVisible
{
    if(self.checkIconVisible != checkIconVisible)
    {
        _checkIconVisible = checkIconVisible;
        self.checkIcon.hidden = !checkIconVisible;
    }
}

@end
