//
//  UIImage+ScaleExt.h
//
//  缩放图片
//

#import <UIKit/UIKit.h>

@interface UIImage (ScaleExt)

//按大小缩放，不按比例
- (UIImage *)scaleToSize:(CGSize)size;

//按大小等比例缩放，有边缘裁剪效果
- (UIImage *)imageByScalingAndCroppingForSize:(CGSize)targetSize;

//按大小缩放，不按比例，类方法
+ (UIImage *)scaleImage:(UIImage *)image toSize:(CGSize)size;

@end


@interface UIImage (OrientationFix)

//暂未验证
- (UIImage *)fixImageOrientationToOrientationUp;

@end
