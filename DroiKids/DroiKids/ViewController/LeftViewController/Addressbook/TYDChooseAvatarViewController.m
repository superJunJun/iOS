//
//  TYDChooseAvatarViewController.m
//  DroiKids
//
//  Created by superjunjun on 15/8/21.
//  Copyright (c) 2015年 superjunjun. All rights reserved.
//

#import "TYDChooseAvatarViewController.h"
#import "TYDAddressBookAvatarChooseBlock.h"
#import "TYDKidContactInfo.h"

@interface TYDChooseAvatarViewController ()

@property (strong, nonatomic) TYDAddressBookAvatarChooseBlock *selectAvatarBlock;
@property (strong, nonatomic) NSMutableArray *avatarBlockArray;

@end

@implementation TYDChooseAvatarViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self localDataInitialize];
    [self navigationBarItemsLoad];
    [self subviewsLoad];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
//    if(self.isFirstLoginSituation)
//    {
//        self.backButtonVisible = NO;
//    }
    
    [self initSelectBlock];
}

- (void)localDataInitialize
{
    self.avatarBlockArray = [NSMutableArray new];
    
    if(!self.avatarID)
    {
        self.avatarID = @(TYDKidContactOther);
    }
}

- (void)navigationBarItemsLoad
{
    self.titleText = @"选择头像";
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    
//    if(self.isFirstLoginSituation
//       || self.editContactType == TYDEditContactTypeModify)
    if(self.editContactType == TYDEditContactTypeModify)
    {
        [button setTitle:@"确定" forState:UIControlStateNormal];
    }
    else
    {
        [button setTitle:@"下一步" forState:UIControlStateNormal];
    }
    
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [button setTitleColor:[UIColor grayColor] forState:UIControlStateHighlighted];
    [button sizeToFit];
    [button addTarget:self action:@selector(editContactButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *rightBarButtonItem = [[UIBarButtonItem alloc]initWithCustomView:button];
    self.navigationItem.rightBarButtonItem = rightBarButtonItem;
}

- (void)subviewsLoad
{
    [self headSectionViewLoad];
}

- (void)headSectionViewLoad
{
    CGRect frame = self.baseView.frame;
    UILabel *label = [UILabel new];
    label.backgroundColor = [UIColor clearColor];
    label.font = [UIFont systemFontOfSize:12];
    label.textColor = [UIColor grayColor];
    label.textAlignment = NSTextAlignmentCenter;
    label.text = @"选择合适的头像，默认关系可在下一步进行修改";
    [label sizeToFit];
    label.width = self.baseView.width;
    label.top = 10;
    [self.baseView addSubview:label];
    
    NSArray *contactArray = @[@(TYDKidContactFather),
                              @(TYDKidContactMother),
                              @(TYDKidContactGrandFather),
                              @(TYDKidContactGrandMother),
                              @(TYDKidContactOther)];
    
    NSInteger buttonCountSum = contactArray.count;
    NSInteger buttonCountPerRow = 2;
    NSInteger horInterval = self.view.width / 9;
    NSInteger verInterval = 50;
    NSInteger buttonWidth = 100;
    NSInteger buttonverInterval = 40;
    CGFloat buttonHorInterval = (frame.size.width - horInterval * 2 - buttonWidth * buttonCountPerRow) / (buttonCountPerRow - 1);
    
    for(NSInteger index = 0; index < buttonCountSum; index++)
    {
        CGPoint blockPoint = CGPointMake(horInterval + (index % 2) * (buttonWidth + buttonHorInterval), verInterval + (index / 2) * (buttonWidth + buttonverInterval));
        
        TYDAddressBookAvatarChooseBlock *avatarBlock = [[TYDAddressBookAvatarChooseBlock alloc] initWithAvatarSizeLength:100 relationShipName:contactArray[index]];
        avatarBlock.origin = blockPoint;
        
        [avatarBlock addTarget:self action:@selector(avatarBlockTap:) forControlEvents:UIControlEventTouchUpInside];
        
        [self.baseView addSubview:avatarBlock];
        [self.avatarBlockArray addObject:avatarBlock];
        
        if(index == buttonCountSum - 1)
        {
            self.baseViewBaseHeight = avatarBlock.bottom + verInterval;
        }
    }
}

- (void)initSelectBlock
{
    for(TYDAddressBookAvatarChooseBlock *avatarBlock in self.avatarBlockArray)
    {
        if(self.avatarID.intValue == avatarBlock.avatarID.intValue)
        {
            self.selectAvatarBlock = avatarBlock;
            
            break;
        }
    }
}

#pragma mark - touchEvent

- (void)editContactButtonClick:(UIButton *)sender
{
    NSLog(@"editContactButtonClick");
    
    if(self.editContactType == TYDEditContactTypeModify)
    {
        if([self.choseAvatarDelegate respondsToSelector:@selector(choseAvatarComplete:)])
        {
            [self.choseAvatarDelegate choseAvatarComplete:self.avatarID];
            
            [super popBackEventWillHappen];
        }
    }
    else if(self.editContactType == TYDEditContactTypeAdd)
    {
        TYDEditContactViewController *vc = [TYDEditContactViewController new];
        vc.avatarID = self.avatarID;
        vc.editContactType = TYDEditContactTypeAdd;
        
        [self.navigationController pushViewController:vc animated:YES];
    }
}

- (void)contactButtonClick:(UIButton *)sender
{
    NSLog(@"contactButtonClick");
}

- (void)avatarBlockTap:(TYDAddressBookAvatarChooseBlock *)sender
{
    NSLog(@"avatarBlockTap");
    
    self.selectAvatarBlock = sender;
}

- (void)setSelectAvatarBlock:(TYDAddressBookAvatarChooseBlock *)selectAvatarBlock
{
    if(self.selectAvatarBlock != selectAvatarBlock)
    {
        _selectAvatarBlock.checkIconVisible = NO;
        selectAvatarBlock.checkIconVisible = YES;
        _selectAvatarBlock = selectAvatarBlock;
        
        self.avatarID = self.selectAvatarBlock.avatarID;
    }
}

@end
