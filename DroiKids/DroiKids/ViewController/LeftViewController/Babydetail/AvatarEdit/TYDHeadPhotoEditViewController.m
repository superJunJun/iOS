//
//  TYDHeadPhotoEditViewController.m
//  EMove
//
//  Created by caiyajie on 15-1-30.
//  Copyright (c) 2015年 Young. All rights reserved.
//

#import "TYDHeadPhotoEditViewController.h"

#define SCALE_FRAME_Y           500.0f
#define BOUNDCE_DURATION        0.3f

@interface TYDHeadPhotoEditViewController ()

@property (strong, nonatomic) UIImage *originalImage;
@property (nonatomic, retain) UIImage *editedImage;
@property (assign, nonatomic) CGFloat originalImageWidth;
@property (assign, nonatomic) CGFloat originalImageHeight;

@property (strong,nonatomic) UIImageView *showImgView;
@property (strong,nonatomic) UIView *overlayView;
@property (nonatomic, retain) UIView *ratioView;

@property (nonatomic, assign) CGRect oldFrame;
@property (nonatomic, assign) CGRect largeFrame;
@property (nonatomic, assign) CGFloat limitRatio;

@property (nonatomic, assign) CGRect latestFrame;

@end

@implementation TYDHeadPhotoEditViewController

- (id)initWithImage:(UIImage *)originalImage cropFrame:(CGRect)cropFrame limitScaleRatio:(NSInteger)limitRatio
{
    self = [super init];
    if (self)
    {
        self.cropFrame = cropFrame;
        self.limitRatio = limitRatio;
        self.originalImage = originalImage;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor blackColor];
    [self initView];
    [self overlayClipping];
    [self controlBarLoad];
}

- (void)initView
{
    CGRect showImageViewFrame = self.view.bounds;
    self.showImgView = [[UIImageView  alloc]initWithFrame:CGRectMake(0, 0, showImageViewFrame.size.width, showImageViewFrame.size.height - 72)];
    [self.showImgView setMultipleTouchEnabled:YES];
    [self.showImgView setUserInteractionEnabled:YES];
    [self.showImgView setImage:self.originalImage];
    
    // scale to fit the screen
    CGFloat oriWidth = self.cropFrame.size.width;
    CGFloat oriHeight = self.originalImage.size.height * (oriWidth / self.originalImage.size.width);
    CGFloat oriX = self.cropFrame.origin.x;
    CGFloat oriY = self.cropFrame.origin.y;
    self.oldFrame = CGRectMake(oriX, oriY, oriWidth, oriHeight);
    self.latestFrame = self.oldFrame;
    self.showImgView.frame = self.oldFrame;
    
    self.largeFrame = CGRectMake(0, 0, self.limitRatio * self.oldFrame.size.width, self.limitRatio * self.oldFrame.size.height);
    
    [self addGestureRecognizers];
    [self.view addSubview:self.showImgView];
    
    self.overlayView = [[UIView alloc] initWithFrame:self.view.bounds];
    self.overlayView.alpha = 0.6f;
    self.overlayView.backgroundColor = [UIColor blackColor];
    self.overlayView.userInteractionEnabled = NO;
    self.overlayView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    [self.view addSubview:self.overlayView];
    
    CGRect frame = self.cropFrame;
    self.ratioView = [[UIView alloc] initWithFrame:frame];
    self.ratioView.layer.borderColor = [UIColor yellowColor].CGColor;
    self.ratioView.layer.borderWidth = 1.0f;
    self.ratioView.layer.cornerRadius = self.cropFrame.size.width / 2;
    self.ratioView.autoresizingMask = UIViewAutoresizingNone;
    [self.view addSubview:self.ratioView];
}

- (void)controlBarLoad
{
    UIView *bottomControlBar = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, 72)];
    bottomControlBar.bottom = self.view.height;
    bottomControlBar.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
    bottomControlBar.backgroundColor = [UIColor blackColor];
    [self.view addSubview:bottomControlBar];
    
    CGFloat leftSpace = 18;
    CGSize  controlBtnSize = CGSizeMake(44, 44);
    NSInteger controlBtnNumber = 4;
    CGFloat interval = (self.view.width - leftSpace * 2 - controlBtnSize.width * controlBtnNumber) / ( controlBtnNumber - 1);
    NSArray *controlBtnImg = @[@"babyDetail_PhotoEditCancle", @"babyDetail_PhotoLeftRotate", @"babyDetail_PhotoRightRotate", @"babyDetail_PhotoEditOK"];
    NSArray *controlBtnImgH = @[@"babyDetail_PhotoEditCancleH", @"babyDetail_PhotoLeftRotateH", @"babyDetail_PhotoRightRotateH", @"babyDetail_PhotoEditOKH"];
    NSMutableArray *controlButtons = [NSMutableArray new];
    for(int i = 0; i < controlBtnNumber; i++)
    {
        UIButton *button = [UIButton new];
        button.size = controlBtnSize;
        button.center = CGPointMake(leftSpace + controlBtnSize.width / 2 + i * (controlBtnSize.width + interval), bottomControlBar.size.height / 2);
        [button setImage:[UIImage imageNamed:controlBtnImg[i]] forState:UIControlStateNormal];
        [button setImage:[UIImage imageNamed:controlBtnImgH[i]] forState:UIControlStateHighlighted];
        [bottomControlBar addSubview:button];
        [controlButtons addObject:button];
    }
    
    UIButton *cancelButton = controlButtons[0];
    UIButton *anticlockwiseButton = controlButtons[1];
    UIButton *clockwiseButton = controlButtons[2];
    UIButton *confirmButton = controlButtons[3];
    [cancelButton addTarget:self action:@selector(cancel:) forControlEvents:UIControlEventTouchUpInside];
    [anticlockwiseButton addTarget:self action:@selector(anticlockwise:) forControlEvents:UIControlEventTouchUpInside];
    [clockwiseButton addTarget:self action:@selector(clockwise:) forControlEvents:UIControlEventTouchUpInside];
    [confirmButton addTarget:self action:@selector(confirm:) forControlEvents:UIControlEventTouchUpInside];
}

#pragma mark - TouchEvent

- (void)anticlockwise:(UIButton *)sender
{
    NSLog(@"anticlockwise");
    [UIView animateWithDuration:0.25
                     animations:^{
                         self.showImgView.transform = CGAffineTransformRotate(self.showImgView.transform, -M_PI_2);
                         self.latestFrame = self.showImgView.frame;
                         self.originalImage = [self imageRotatedByDegrees:-M_PI_2 withImage:self.originalImage];
                     }];
    
}

- (void)clockwise:(UIButton *)sender
{
    NSLog(@"clockwise");
    [UIView animateWithDuration:0.25
                     animations:^{
                         self.showImgView.transform = CGAffineTransformRotate(self.showImgView.transform, M_PI_2);
                         self.latestFrame = self.showImgView.frame;
                         self.originalImage = [self imageRotatedByDegrees:M_PI_2 withImage:self.originalImage];
                     }];
}

- (void)cancel:(id)sender
{
    if(self.delegate && [self.delegate conformsToProtocol:@protocol(TYDHeadPhotoEditDelegate)])
    {
        [self.delegate imageCropperDidCancel:self];
    }
}

- (void)confirm:(id)sender
{
    if(self.delegate && [self.delegate conformsToProtocol:@protocol(TYDHeadPhotoEditDelegate)])
    {
        UIImage *clipImage = [self getSubImage];
        [self.delegate editImageDidFinished:clipImage];
    }
}


- (UIImage *)imageRotatedByDegrees:(CGFloat)angle withImage:(UIImage *)image
{
    // calculate the size of the rotated view's containing box for our drawing space
    UIView *rotatedViewBox = [[UIView alloc] initWithFrame:CGRectMake(0, 0, image.size.width, image.size.height)];
    CGAffineTransform transform = CGAffineTransformMakeRotation(angle);
    rotatedViewBox.transform = transform;
    CGSize rotatedSize = rotatedViewBox.frame.size;
    
    // Create the bitmap context
    UIGraphicsBeginImageContext(rotatedSize);
    CGContextRef bitmap = UIGraphicsGetCurrentContext();
    
    // Move the origin to the middle of the image so we will rotate and scale around the center.
    CGContextTranslateCTM(bitmap, rotatedSize.width / 2, rotatedSize.height / 2);
    
    // Rotate the image context
    CGContextRotateCTM(bitmap, angle);
    
    // Now, draw the rotated/scaled image into the context
    CGContextScaleCTM(bitmap, 1.0, -1.0);
    CGContextDrawImage(bitmap, CGRectMake(-image.size.width / 2, -image.size.height / 2, image.size.width, image.size.height), [image CGImage]);
    
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

- (void)overlayClipping
{
    CGFloat radius = self.ratioView.frame.size.width / 2;
    CGPoint point = CGPointMake(radius, radius + 44);
    UIBezierPath *maskPath = [UIBezierPath bezierPathWithRect:self.view.bounds];
    [maskPath appendPath:[UIBezierPath bezierPathWithArcCenter:point radius:radius startAngle:0 endAngle:2 * M_PI clockwise:NO]];
    
    CAShapeLayer *shapeLayer = [CAShapeLayer layer];
    shapeLayer.path = maskPath.CGPath;
    
    self.overlayView.layer.mask = shapeLayer;
}

- (void)addGestureRecognizers
{
    // add pinch gesture
    UIPinchGestureRecognizer *pinchGestureRecognizer = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(pinchView:)];
    [self.view addGestureRecognizer:pinchGestureRecognizer];
    
    // add pan gesture
    UIPanGestureRecognizer *panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panView:)];
    [self.view addGestureRecognizer:panGestureRecognizer];
}

- (void)pinchView:(UIPinchGestureRecognizer *)pinchGestureRecognizer
{
    UIView *view = self.showImgView;
    if (pinchGestureRecognizer.state == UIGestureRecognizerStateBegan || pinchGestureRecognizer.state == UIGestureRecognizerStateChanged)
    {
        view.transform = CGAffineTransformScale(view.transform, pinchGestureRecognizer.scale, pinchGestureRecognizer.scale);
        pinchGestureRecognizer.scale = 1;
    }
    else if (pinchGestureRecognizer.state == UIGestureRecognizerStateEnded)
    {
        CGRect newFrame = self.showImgView.frame;
        newFrame = [self handleScaleOverflow:newFrame];
        newFrame = [self handleBorderOverflow:newFrame];
        [UIView animateWithDuration:BOUNDCE_DURATION animations:^{
            self.showImgView.frame = newFrame;
            self.latestFrame = newFrame;
        }];
    }
}

// pan gesture handler
- (void)panView:(UIPanGestureRecognizer *)panGestureRecognizer
{
    UIView *view = self.showImgView;
    if (panGestureRecognizer.state == UIGestureRecognizerStateBegan || panGestureRecognizer.state == UIGestureRecognizerStateChanged)
    {
        CGFloat absCenterX = self.cropFrame.origin.x + self.cropFrame.size.width / 2;
        CGFloat absCenterY = self.cropFrame.origin.y + self.cropFrame.size.height / 2;
        CGFloat scaleRatio = self.showImgView.frame.size.width / self.cropFrame.size.width;
        CGFloat acceleratorX = 1 - ABS(absCenterX - view.center.x) / (scaleRatio * absCenterX);
        CGFloat acceleratorY = 1 - ABS(absCenterY - view.center.y) / (scaleRatio * absCenterY);
        CGPoint translation = [panGestureRecognizer translationInView:view.superview];
        [view setCenter:(CGPoint){view.center.x + translation.x * acceleratorX, view.center.y + translation.y * acceleratorY}];
        [panGestureRecognizer setTranslation:CGPointZero inView:view.superview];
    }
    else if (panGestureRecognizer.state == UIGestureRecognizerStateEnded)
    {
        // bounce to original frame
        CGRect newFrame = self.showImgView.frame;
        newFrame = [self handleBorderOverflow:newFrame];
        [UIView animateWithDuration:BOUNDCE_DURATION animations:^{
            self.showImgView.frame = newFrame;
            self.latestFrame = newFrame;
        }];
    }
}

- (CGRect)handleScaleOverflow:(CGRect)newFrame
{
    // bounce to original frame
    CGPoint oriCenter = CGPointMake(newFrame.origin.x + newFrame.size.width / 2, newFrame.origin.y + newFrame.size.height / 2);
    if (newFrame.size.width < self.oldFrame.size.width)
    {
        newFrame = self.oldFrame;
    }
    if (newFrame.size.width > self.largeFrame.size.width)
    {
        newFrame = self.largeFrame;
    }
    newFrame.origin.x = oriCenter.x - newFrame.size.width / 2;
    newFrame.origin.y = oriCenter.y - newFrame.size.height / 2;
    return newFrame;
}

- (CGRect)handleBorderOverflow:(CGRect)newFrame
{
    // horizontally
    if (newFrame.origin.x > self.cropFrame.origin.x)
    {
        newFrame.origin.x = self.cropFrame.origin.x;
    }
    if (CGRectGetMaxX(newFrame) < self.cropFrame.size.width)
    {
        newFrame.origin.x = self.cropFrame.size.width - newFrame.size.width;
    }
    // vertically
    if (newFrame.origin.y > self.cropFrame.origin.y)
    {
        newFrame.origin.y = self.cropFrame.origin.y;
    }
    if (CGRectGetMaxY(newFrame) < self.cropFrame.origin.y + self.cropFrame.size.height)
    {
        newFrame.origin.y = self.cropFrame.origin.y + self.cropFrame.size.height - newFrame.size.height;
    }
    // adapt horizontally rectangle
    if (self.showImgView.frame.size.width > self.showImgView.frame.size.height && newFrame.size.height <= self.cropFrame.size.height)
    {
        newFrame.origin.y = self.cropFrame.origin.y + (self.cropFrame.size.height - newFrame.size.height) / 2;
    }
    return newFrame;
}

- (UIImage *)getSubImage
{
    CGRect frame = self.cropFrame;
    CGRect squareFrame = frame;
    CGFloat scaleRatio = self.latestFrame.size.width / self.originalImage.size.width;
    CGFloat x = (squareFrame.origin.x - self.latestFrame.origin.x) / scaleRatio;
    CGFloat y = (squareFrame.origin.y - self.latestFrame.origin.y) / scaleRatio;
    CGFloat w = squareFrame.size.width / scaleRatio;
    CGFloat h = squareFrame.size.width / scaleRatio;
    if (self.latestFrame.size.width < self.cropFrame.size.width)
    {
        CGFloat newW = self.originalImage.size.width;
        CGFloat newH = newW * (self.cropFrame.size.height / self.cropFrame.size.width);
        x = 0;
        y = y + (h - newH) / 2;
        w = newH;
        h = newH;
    }
    if (self.latestFrame.size.height < self.cropFrame.size.height)
    {
        CGFloat newH = self.originalImage.size.height;
        CGFloat newW = newH * (self.cropFrame.size.width / self.cropFrame.size.height);
        x = x + (w - newW) / 2;
        y = 0;
        w = newH;
        h = newH;
    }
    CGRect myImageRect = CGRectMake(x, y, w, h);
    CGImageRef imageRef = self.originalImage.CGImage;
    CGImageRef subImageRef = CGImageCreateWithImageInRect(imageRef, myImageRect);
    CGSize size;
    size.width = myImageRect.size.width;
    size.height = myImageRect.size.height;
    UIGraphicsBeginImageContext(size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextDrawImage(context, myImageRect, subImageRef);
    UIImage *smallImage = [UIImage imageWithCGImage:subImageRef];
    UIGraphicsEndImageContext();
    return smallImage;
}

@end
