//
//  TYDHeadPhotoEditViewController.h
//  EMove
//
//  Created by caiyajie on 15-1-30.
//  Copyright (c) 2015年 Young. All rights reserved.
//

#import <UIKit/UIKit.h>

@class TYDHeadPhotoEditViewController;

@protocol TYDHeadPhotoEditDelegate <NSObject>
@optional
- (void)editImageDidFinished:(UIImage *)editedImage;
- (void)imageCropperDidCancel:(TYDHeadPhotoEditViewController *)cropperViewController;
@end

@interface TYDHeadPhotoEditViewController : UIViewController

@property (nonatomic, assign) id<TYDHeadPhotoEditDelegate> delegate;
@property (nonatomic, assign) CGRect cropFrame;

- (id)initWithImage:(UIImage *)originalImage cropFrame:(CGRect)cropFrame limitScaleRatio:(NSInteger)limitRatio;

@end
