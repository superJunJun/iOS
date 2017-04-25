//
//  TYDTakePhotoAndEditController.h
//  EMove
//
//  Created by wangchao on 15/3/31.
//  Copyright (c) 2015年 Young. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol getEditAvatarImageDelegate <NSObject>

- (void)getEditCustomAvatarImage:(UIImage *)customImage;

@end

@interface TYDTakePhotoAndEditController : UIViewController

@property (nonatomic, assign) UIImagePickerControllerSourceType imageEditSourceType;
@property (nonatomic, assign) id<getEditAvatarImageDelegate> delegate;

@end
