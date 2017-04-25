//
//  TYDAvatarModifyController.m
//  DroiKids
//
//  Created by wangchao on 15/8/22.
//  Copyright (c) 2015年 superjunjun. All rights reserved.
//

#import "TYDAvatarModifyController.h"
#import "TYDTakePhotoAndEditController.h"
#import "TYDHeadPhotoEditViewController.h"

@interface TYDAvatarModifyController () <getEditAvatarImageDelegate>

@property (strong, nonatomic) UIImageView *avatarImageView;
@property (strong, nonatomic) UIImage *editResultImage;

@end

@implementation TYDAvatarModifyController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self localDataInitialize];
    [self navigationBarItemsLoad];
    [self subviewsLoad];
}

- (void)localDataInitialize
{
    self.editResultImage = self.avatarImage;
}

- (void)navigationBarItemsLoad
{
    self.title = @"宝贝头像";
    
    UIButton *confirmButton = [UIButton new];
    [confirmButton setTitle:@"确认" forState:UIControlStateNormal];
    [confirmButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [confirmButton setTitleColor:[UIColor grayColor] forState:UIControlStateHighlighted];
    [confirmButton sizeToFit];
    [confirmButton addTarget:self action:@selector(confirmButtonTap:) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *buttonItem = [[UIBarButtonItem alloc] initWithCustomView:confirmButton];
    self.navigationItem.rightBarButtonItem = buttonItem;
}

- (void)subviewsLoad
{
    CGSize buttonSize = CGSizeMake(self.view.width, 59);
    UIButton *takePhotoButton = [[UIButton alloc] initWithImage:nil highlightedImage:[UIImage imageNamed:@"common_buttonBackgroundH"] capInsets:UIEdgeInsetsMake(10, 10, 10, 10) givenButtonSize:buttonSize title:@"拍照" titleFont:[UIFont systemFontOfSize:17] titleColor:[UIColor blackColor]];
    takePhotoButton.backgroundColor = [UIColor whiteColor];
    [takePhotoButton addTarget:self action:@selector(takePhotoButtonTap:) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *selectFromAlbumButton = [[UIButton alloc] initWithImage:nil highlightedImage:[UIImage imageNamed:@"common_buttonBackgroundH"] capInsets:UIEdgeInsetsMake(10, 10, 10, 10) givenButtonSize:buttonSize title:@"从相册中选取" titleFont:[UIFont systemFontOfSize:17] titleColor:[UIColor blackColor]];
    selectFromAlbumButton.backgroundColor = [UIColor whiteColor];
    [selectFromAlbumButton addTarget:self action:@selector(selectFromAlbumButtonTap:) forControlEvents:UIControlEventTouchUpInside];
    
    selectFromAlbumButton.bottom = self.view.height - 64;
    selectFromAlbumButton.xCenter = self.view.width / 2;
    
    takePhotoButton.bottom = selectFromAlbumButton.top - 1;
    takePhotoButton.xCenter = self.view.width / 2;
    
    [self.view addSubview:selectFromAlbumButton];
    [self.view addSubview:takePhotoButton];
    
    CGFloat height = self.view.height - 64 - (selectFromAlbumButton.height + 1 + takePhotoButton.height);
    
    CGSize avatarImageSize = CGSizeZero;
    if(height <= self.view.width)
    {
        avatarImageSize = CGSizeMake(height * 2 / 3, height * 2 / 3);
    }
    else
    {
        avatarImageSize = CGSizeMake(self.view.width * 2 / 3, self.view.width * 2 / 3);
    }
    
    UIImageView *avatarImageView = [UIImageView new];
    avatarImageView.image = self.avatarImage;
    avatarImageView.backgroundColor = [UIColor grayColor];
    avatarImageView.size = avatarImageSize;
    avatarImageView.center = CGPointMake(self.view.width / 2, height / 2);
    
    [self.view addSubview:avatarImageView];
    self.avatarImageView = avatarImageView;
}

#pragma mark - OverrideMethod

- (void)setEditResultImage:(UIImage *)editResultImage
{
    if(self.editResultImage != editResultImage)
    {
        _editResultImage = editResultImage;
        self.avatarImageView.image = editResultImage;
    }
}

#pragma mark - TouchEvent

- (void)takePhotoButtonTap:(UIButton *)sender
{
    if(![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
    {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"通知" message:@"该设备不支持拍照" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
        [alertView show];
        
        return;
    }
    else
    {
        TYDTakePhotoAndEditController *takePhotoAndEditController = [TYDTakePhotoAndEditController new];
        takePhotoAndEditController.delegate = self;
        takePhotoAndEditController.imageEditSourceType = UIImagePickerControllerSourceTypeCamera;
        [self presentViewController:takePhotoAndEditController animated:YES completion:nil];
    }
}

- (void)selectFromAlbumButtonTap:(UIButton *)sender
{
    TYDTakePhotoAndEditController *takePhotoAndEditController = [TYDTakePhotoAndEditController new];
    takePhotoAndEditController.delegate = self;
    takePhotoAndEditController.imageEditSourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    [self presentViewController:takePhotoAndEditController animated:YES completion:nil];
}

- (void)confirmButtonTap:(UIButton *)button
{
    NSLog(@"TYDAvatarModifyController confirmButtonTap");
    
    if(self.editResultImage != self.avatarImage)
    {
        if([self.delegate respondsToSelector:@selector(avatarModifyComplete:)])
        {
            [self.delegate avatarModifyComplete:self.editResultImage];
        }
    }
    
    [super popBackEventWillHappen];
}

#pragma mark - getEditAvatarImageDelegate

- (void)getEditCustomAvatarImage:(UIImage *)customImage
{
    self.editResultImage = customImage;
}

@end
