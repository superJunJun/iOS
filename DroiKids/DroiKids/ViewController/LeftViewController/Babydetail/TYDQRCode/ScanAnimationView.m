//
//  ScanAnimationView.m
//  ScanQRCode
//
//  Created by Darren Xie on 14-7-30.
//  Copyright (c) 2014年 Darren Xie. All rights reserved.
//

#import "ScanAnimationView.h"

#define SCREEN_WIDTH  [UIScreen mainScreen].bounds.size.width
#define SCREEN_HEIGHT [UIScreen mainScreen].bounds.size.height

#define kAnimationKeyPath @"position"
#define kCornerLength 10.0f

@interface ScanAnimationView()

@property (assign, nonatomic) CGRect scanFrame;
@property (strong, nonatomic) CALayer *scanLineLayer;

@end

@implementation ScanAnimationView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        [self commonInit];
    }
    
    return self;
}

- (void)commonInit
{
    self.backgroundColor = [UIColor clearColor];
    
    float scanFrameWidth  = SCREEN_WIDTH  * 2.0f / 3.0f;
    float scanFrameheight = SCREEN_WIDTH  * 2.0f / 3.0f;
    CGRect frame = self.frame;
    
    CGRect scanFrame = CGRectMake((frame.size.width - scanFrameWidth) / 2.0f, ((frame.size.height - 64) * 4 / 5 - scanFrameheight) / 2.0f, scanFrameWidth, scanFrameheight);

    CALayer *scanLineLayer = [CALayer layer];
    scanLineLayer.frame = CGRectMake(0, 0, scanFrame.size.width - 10, 12);
    scanLineLayer.contents = (id)[UIImage imageNamed:@"QRScanLine"].CGImage;
    scanLineLayer.position = CGPointMake(CGRectGetMidX(scanFrame), CGRectGetMinY(scanFrame));
    
    [self.layer addSublayer:scanLineLayer];
    self.scanLineLayer = scanLineLayer;
    self.scanFrame = scanFrame;
    
    UILabel *scanPromptLabel = [UILabel new];
    scanPromptLabel.font = [UIFont systemFontOfSize:11];
    scanPromptLabel.textColor = [UIColor colorWithHex:0xd4d4d4];
    scanPromptLabel.text = @"将二维码/条码放入框内，即可自动扫描";
    [scanPromptLabel sizeToFit];
    scanPromptLabel.xCenter = frame.size.width / 2;
    scanPromptLabel.top = ((frame.size.height - 64) * 4 / 5 + scanFrameheight) / 2.0f + 13;
    
    [self addSubview:scanPromptLabel];
    
    self.scanPromptLabel = scanPromptLabel;
    
    CGSize buttonSize = CGSizeMake(self.width - 34 * 2, 34);
    UIButton *bindingInputButton = [[UIButton alloc] initWithImage:[UIImage imageNamed:@"addressBook_addContacts"]
                                             highlightedImage:[UIImage imageNamed:@"addressBook_addContactsH"]
                                                    capInsets:UIEdgeInsetsMake(10, 10, 10, 10)
                                              givenButtonSize:buttonSize
                                                        title:@"输入绑定号"
                                                    titleFont:[UIFont systemFontOfSize:17]
                                                   titleColor:[UIColor whiteColor]];
    
    bindingInputButton.xCenter = self.xCenter;
    bindingInputButton.bottom = self.height - 64 - 30;
    
    [bindingInputButton addTarget:self action:@selector(bindingInputButtonTap:) forControlEvents:UIControlEventTouchUpInside];
    
    [self addSubview:bindingInputButton];
}

- (void)startScanAnimation
{
    [self stopScanAnimation];

    CGPoint scanLineStartPosition, scanLineEndPosition;
    scanLineStartPosition = CGPointMake(CGRectGetMidX(self.scanFrame), CGRectGetMinY(self.scanFrame));
    scanLineEndPosition = CGPointMake(CGRectGetMidX(self.scanFrame), CGRectGetMaxY(self.scanFrame));
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:kAnimationKeyPath];
    [animation setFromValue:[NSValue valueWithCGPoint:scanLineStartPosition]];
    [animation setToValue:[NSValue valueWithCGPoint:scanLineEndPosition]];
    [animation setDuration:2.50f];
    [animation setRepeatCount:100000];
    [self.scanLineLayer addAnimation:animation forKey:kAnimationKeyPath];
}

- (void)stopScanAnimation
{
    if ([self.scanLineLayer animationForKey:kAnimationKeyPath])
    {
        [self.scanLineLayer removeAnimationForKey:kAnimationKeyPath];
    }
}

- (void)drawRect:(CGRect)rect
{
    self.backgroundColor = [UIColor whiteColor];
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSaveGState(context);
    
    UIColor *color = [[UIColor blackColor] colorWithAlphaComponent:0.5];
    [color set];
    UIRectFill(self.bounds);
    
    UIColor *clearColor = [UIColor clearColor];
    [clearColor set];
    UIRectFill(self.scanFrame);
    
    //画边框
    CGContextSetStrokeColorWithColor(context, [UIColor whiteColor].CGColor);
    CGContextStrokeRectWithWidth(context, CGRectInset(self.scanFrame, -1, -1), 1.0);
    
    //画边角
    CGPoint leftUp = self.scanFrame.origin;
    CGPoint rightUp = CGPointMake(CGRectGetMaxX(self.scanFrame), leftUp.y);
    CGPoint rightDown = CGPointMake(rightUp.x, CGRectGetMaxY(self.scanFrame));
    //左上角
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathMoveToPoint(path, NULL, leftUp.x, leftUp.y + kCornerLength);
    CGPathAddLineToPoint(path, NULL, leftUp.x, leftUp.y);
    CGPathAddLineToPoint(path, NULL, leftUp.x + kCornerLength, leftUp.y);
    //右上角
    CGPathMoveToPoint(path, NULL, rightUp.x - kCornerLength, rightUp.y);
    CGPathAddLineToPoint(path, NULL, rightUp.x, rightUp.y);
    CGPathAddLineToPoint(path, NULL, rightUp.x, rightUp.y + kCornerLength);
    //右下角
    CGPathMoveToPoint(path, NULL, rightDown.x, rightDown.y - kCornerLength);
    CGPathAddLineToPoint(path, NULL, rightDown.x, rightDown.y);
    CGPathAddLineToPoint(path, NULL, rightDown.x - kCornerLength, rightDown.y);
    //左下角
    CGPathMoveToPoint(path, NULL, leftUp.x, rightDown.y - kCornerLength);
    CGPathAddLineToPoint(path, NULL, leftUp.x, rightDown.y);
    CGPathAddLineToPoint(path, NULL, leftUp.x + kCornerLength, rightDown.y);
    
    CGContextSetStrokeColorWithColor(context, [UIColor colorWithRed:0.2 green:1.0 blue:0.2 alpha:1.0].CGColor);
    CGContextSetLineWidth(context, 4.0);
    CGContextAddPath(context, path);
    CGContextStrokePath(context);
    
    CGContextRestoreGState(context);
    
    CGPathRelease(path);
}

#pragma mark - TouchEvent

- (void)bindingInputButtonTap:(UIButton *)sender
{
    NSLog(@"bindingInputButtonTap");
    
    if([self.delegate respondsToSelector:@selector(bindingButtonTap)])
    {
        [self.delegate bindingButtonTap];
    }
}

@end
