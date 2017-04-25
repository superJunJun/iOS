//
//  UIButton+ImageCreation.h
//

#import <UIKit/UIKit.h>

@interface UIButton (ImageCreation)

- (instancetype)initWithImage:(UIImage *)image;
- (instancetype)initWithImage:(UIImage *)image
             highlightedImage:(UIImage *)highlightedImage;
- (instancetype)initWithImage:(UIImage *)image
             highlightedImage:(UIImage *)highlightedImage
              givenButtonSize:(CGSize)size;

- (instancetype)initWithImage:(UIImage *)image
             highlightedImage:(UIImage *)highlightedImage
                        title:(NSString *)title;
- (instancetype)initWithImage:(UIImage *)image
             highlightedImage:(UIImage *)highlightedImage
                        title:(NSString *)title
                    titleFont:(UIFont *)titleFont
                   titleColor:(UIColor *)titleColor;
- (instancetype)initWithImage:(UIImage *)image
             highlightedImage:(UIImage *)highlightedImage
                    capInsets:(UIEdgeInsets)capInsets
              givenButtonSize:(CGSize)size
                        title:(NSString *)title
                    titleFont:(UIFont *)titleFont
                   titleColor:(UIColor *)titleColor;
- (instancetype)initWithImage:(UIImage *)image
                selectedImage:(UIImage *)selectedImage
                    capInsets:(UIEdgeInsets)capInsets
              givenButtonSize:(CGSize)size
                        title:(NSString *)title
                    titleFont:(UIFont *)titleFont
                   titleColor:(UIColor *)titleColor;

- (instancetype)initWithImageName:(NSString *)imageName;
- (instancetype)initWithImageName:(NSString *)imageName
             highlightedImageName:(NSString *)highlightedImage;
- (instancetype)initWithImageName:(NSString *)imageName
             highlightedImageName:(NSString *)highlightedImageName
                  givenButtonSize:(CGSize)size;

- (instancetype)initWithImageName:(NSString *)imageName
             highlightedImageName:(NSString *)highlightedImageName
                            title:(NSString *)title;
- (instancetype)initWithImageName:(NSString *)imageName
             highlightedImageName:(NSString *)highlightedImageName
                            title:(NSString *)title
                        titleFont:(UIFont *)titleFont
                       titleColor:(UIColor *)titleColor;
- (instancetype)initWithImageName:(NSString *)imageName
             highlightedImageName:(NSString *)highlightedImageName
                        capInsets:(UIEdgeInsets)capInsets
                  givenButtonSize:(CGSize)size
                            title:(NSString *)title
                        titleFont:(UIFont *)titleFont
                       titleColor:(UIColor *)titleColor;

@end
