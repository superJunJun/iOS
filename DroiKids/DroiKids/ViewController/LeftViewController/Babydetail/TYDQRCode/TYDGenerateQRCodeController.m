//
//  TYDGenerateQRCodeController.m
//  DroiKids
//
//  Created by wangchao on 15/8/20.
//  Copyright (c) 2015年 superjunjun. All rights reserved.
//

#import "TYDGenerateQRCodeController.h"

@interface TYDGenerateQRCodeController ()

@end

@implementation TYDGenerateQRCodeController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self localDataInitialize];
    [self navigationBarItemsLoad];
    [self subviewsLoad];
}

- (void)localDataInitialize
{
}

- (void)navigationBarItemsLoad
{
    self.title = @"生成二维码";
}

- (void)subviewsLoad
{
    UIImageView *imageView = [UIImageView new];
    imageView.size = CGSizeMake(self.view.width * 2 / 3, self.view.width * 2 / 3);
    imageView.xCenter = self.view.width / 2;
    imageView.yCenter = self.view.height * 2 / 5;
    imageView.layer.borderWidth = 0.5;
    imageView.layer.borderColor = [UIColor blackColor].CGColor;
    imageView.image = [self makeQRCodeImage];
    
    [self.baseView addSubview:imageView];
    
    
    UILabel *label = [UILabel new];
    label.backgroundColor = [UIColor clearColor];
    label.font = [UIFont systemFontOfSize:11];
    label.textColor = [UIColor colorWithHex:0x686868];
    label.text = @"扫描二维码,绑定手表";
    [label sizeToFit];
    label.xCenter = imageView.xCenter;
    label.top = imageView.bottom + 16;
    
    [self.baseView addSubview:label];
    
    self.baseViewBaseHeight = label.bottom;
}

- (UIImage *)makeQRCodeImage
{
    CIFilter *filter_qrcode = [CIFilter filterWithName:@"CIQRCodeGenerator"];
    [filter_qrcode setDefaults];
    
    NSData *data = [self.watchID dataUsingEncoding:NSUTF8StringEncoding];
    [filter_qrcode setValue:data forKey:@"inputMessage"];
    CIImage *outputImage = [filter_qrcode outputImage];
    CIContext *context = [CIContext contextWithOptions:nil];
    CGImageRef cgImage = [context createCGImage:outputImage
                                       fromRect:[outputImage extent]];
    
    UIImage *image = [UIImage imageWithCGImage:cgImage
                                         scale:1
                                   orientation:UIImageOrientationUp];
    
    //大小控制
    UIImage *resizedImage = [self resizeImage:image
                                  withQuality:kCGInterpolationHigh
                                         rate:50];
    
    //颜色控制
    resizedImage = [self imageBlackToTransparent:resizedImage withRed:0x0 andGreen:0x0 andBlue:0x0];
    
    CGImageRelease(cgImage);
    
    return resizedImage;
}

- (UIImage *)resizeImage:(UIImage *)image
             withQuality:(CGInterpolationQuality)quality
                    rate:(CGFloat)rate
{
    UIImage *resized = nil;
    CGFloat width = image.size.width * rate;
    CGFloat height = image.size.height * rate;
    
    UIGraphicsBeginImageContext(CGSizeMake(width, height));
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetInterpolationQuality(context, quality);
    [image drawInRect:CGRectMake(0, 0, width, height)];
    resized = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return resized;
}

void ProviderReleaseData (void *info, const void *data, size_t size)
{
    free((void *)data);
}

- (UIImage *)imageBlackToTransparent:(UIImage *)image withRed:(CGFloat)red andGreen:(CGFloat)green andBlue:(CGFloat)blue
{
    const int imageWidth = image.size.width;
    const int imageHeight = image.size.height;
    
    size_t bytesPerRow = imageWidth * 4;
    uint32_t *rgbImageBuf = (uint32_t *)malloc(bytesPerRow * imageHeight);
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef context = CGBitmapContextCreate(rgbImageBuf, imageWidth, imageHeight, 8, bytesPerRow, colorSpace, kCGBitmapByteOrder32Little | kCGImageAlphaNoneSkipLast);
    CGContextDrawImage(context, CGRectMake(0, 0, imageWidth, imageHeight), image.CGImage);
    
    // 遍历像素
    int pixelNum = imageWidth * imageHeight;
    uint32_t *pCurPtr = rgbImageBuf;
    
    for(int i = 0; i < pixelNum; i++, pCurPtr++)
    {
        if((*pCurPtr & 0xFFFFFF00) < 0x99999900) // 将白色变成透明
        {
            // 改成下面的代码，会将图片转成想要的颜色
            uint8_t *ptr = (uint8_t*)pCurPtr;
            ptr[3] = red; //0~255
            ptr[2] = green;
            ptr[1] = blue;
        }
        else
        {
            uint8_t *ptr = (uint8_t*)pCurPtr;
            ptr[0] = 0;
        }
    }
    
    // 输出图片
    CGDataProviderRef dataProvider = CGDataProviderCreateWithData(NULL, rgbImageBuf, bytesPerRow * imageHeight, ProviderReleaseData);
    CGImageRef imageRef = CGImageCreate(imageWidth, imageHeight, 8, 32, bytesPerRow, colorSpace, kCGImageAlphaLast | kCGBitmapByteOrder32Little, dataProvider, NULL, true, kCGRenderingIntentDefault);
    CGDataProviderRelease(dataProvider);
    
    UIImage *resultUIImage = [UIImage imageWithCGImage:imageRef];
    
    // 清理空间
    CGImageRelease(imageRef);
    CGContextRelease(context);
    CGColorSpaceRelease(colorSpace);
    
    return resultUIImage;
}

@end
