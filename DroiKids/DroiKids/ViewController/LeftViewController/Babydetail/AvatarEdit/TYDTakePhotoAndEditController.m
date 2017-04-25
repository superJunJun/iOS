//
//  TYDTakePhotoAndEditController.m
//  EMove
//
//  Created by wangchao on 15/3/31.
//  Copyright (c) 2015年 Young. All rights reserved.
//

#import "TYDTakePhotoAndEditController.h"
#import "TYDHeadPhotoEditViewController.h"

#define SCALE_FRAME_Y           300.0f

@interface TYDTakePhotoAndEditController ()<UINavigationControllerDelegate ,UIImagePickerControllerDelegate, TYDHeadPhotoEditDelegate>

@property (strong, nonatomic) UIImagePickerController *imagePickerController;
@property (strong, nonatomic) UIImage *editImage;

@end

@implementation TYDTakePhotoAndEditController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self subviewsLoad];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)subviewsLoad
{
    UIImagePickerController *imagePickerController = [UIImagePickerController new];
    imagePickerController.delegate = self;
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    
    if(self.imageEditSourceType == UIImagePickerControllerSourceTypeCamera)
    {
        imagePickerController.sourceType = UIImagePickerControllerSourceTypeCamera;
    }
    else if(self.imageEditSourceType == UIImagePickerControllerSourceTypePhotoLibrary)
    {
        imagePickerController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    }
    [self addChildViewController:imagePickerController];
    [self.view addSubview: imagePickerController.view];
    self.imagePickerController = imagePickerController;
}

#pragma mark - UIImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    UIImage * headPhotoImage = [info objectForKey:@"UIImagePickerControllerOriginalImage"];
    headPhotoImage = [self headPhotoImageScaleToMaxSize:headPhotoImage originalMaxWidth:600.0];  //编辑图片像素大小
    CGFloat cropSizeLength = self.view.frame.size.width;  //图片编辑框的宽度
    TYDHeadPhotoEditViewController *imgEditVc = [[TYDHeadPhotoEditViewController alloc]initWithImage:headPhotoImage cropFrame:CGRectMake(0, 44, cropSizeLength, cropSizeLength) limitScaleRatio:3];
    imgEditVc.delegate = self;
    
    [self addChildViewController:imgEditVc];
    [self transitionFromViewController:self.imagePickerController
                      toViewController:imgEditVc
                              duration:0.3
                               options:UIViewAnimationOptionTransitionFlipFromRight
                            animations:nil
                            completion:^(BOOL finished){
                                if(finished)
                                {
                                    [imgEditVc didMoveToParentViewController:self];
                                    [self.imagePickerController willMoveToParentViewController:nil];
                                    [self.imagePickerController removeFromParentViewController];
                                }
                            }];
}

- (UIImage *)headPhotoImageScaleToMaxSize:(UIImage *)sourceImage originalMaxWidth:(CGFloat)originalMaxWidth
{
    if(sourceImage.size.width < originalMaxWidth
        || sourceImage.size.height < originalMaxWidth)
    {
        return sourceImage;
    }
    
    CGFloat btWidth = 0.0f;
    CGFloat btHeight = 0.0f;
    
    if(sourceImage.size.width < sourceImage.size.height)
    {
        btHeight = originalMaxWidth;
        btWidth = sourceImage.size.width * (originalMaxWidth / sourceImage.size.height);
    }
    else
    {
        btWidth = originalMaxWidth;
        btHeight = sourceImage.size.height * (originalMaxWidth / sourceImage.size.width);
    }
    
    CGSize targetSize = CGSizeMake(btWidth, btHeight);
    return [self imageByScalingAndCroppingForSourceImage:sourceImage targetSize:targetSize];
}

- (UIImage *)imageByScalingAndCroppingForSourceImage:(UIImage *)sourceImage targetSize:(CGSize)targetSize
{
    UIImage *newImage = nil;
    CGSize imageSize = sourceImage.size;
    CGFloat width = imageSize.width;
    CGFloat height = imageSize.height;
    CGFloat targetWidth = targetSize.width;
    CGFloat targetHeight = targetSize.height;
    CGFloat scaleFactor = 0.0;
    CGFloat scaledWidth = targetWidth;
    CGFloat scaledHeight = targetHeight;
    CGPoint thumbnailPoint = CGPointMake(0.0, 0.0);
    
    if(CGSizeEqualToSize(imageSize, targetSize) == NO)
    {
        CGFloat widthFactor = targetWidth / width;
        CGFloat heightFactor = targetHeight / height;
        
        if(widthFactor > heightFactor)
        {
            scaleFactor = widthFactor; // scale to fit height
        }
        else
        {
            scaleFactor = heightFactor; // scale to fit width
        }
        
        scaledWidth  = width * scaleFactor;
        scaledHeight = height * scaleFactor;
        
        // center the image
        if(widthFactor > heightFactor)
        {
            thumbnailPoint.y = (targetHeight - scaledHeight) * 0.5;
        }
        else if(widthFactor < heightFactor)
        {
            thumbnailPoint.x = (targetWidth - scaledWidth) * 0.5;
        }
    }
    
    UIGraphicsBeginImageContext(targetSize); // this will crop
    CGRect thumbnailRect = CGRectZero;
    thumbnailRect.origin = thumbnailPoint;
    thumbnailRect.size.width  = scaledWidth;
    thumbnailRect.size.height = scaledHeight;
    
    [sourceImage drawInRect:thumbnailRect];
    
    newImage = UIGraphicsGetImageFromCurrentImageContext();
    if(newImage == nil)
    {
        NSLog(@"could not scale image");
    }
    
    //pop the context to get back to the default
    UIGraphicsEndImageContext();
    return newImage;
}


#pragma mark TYDHeadPhotoEditDelegate

- (void)editImageDidFinished:(UIImage *)editedImage
{
    NSLog(@"editImageDidFinished:");
    if(self.delegate
       && [self.delegate conformsToProtocol:@protocol(getEditAvatarImageDelegate)])
    {
        editedImage = [self headPhotoImageScaleToMaxSize:editedImage originalMaxWidth:SCALE_FRAME_Y];
        [self.delegate getEditCustomAvatarImage:editedImage];
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)imageCropperDidCancel:(TYDHeadPhotoEditViewController *)cropperViewController
{
    NSLog(@"imageCropperDidCancel:");
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
