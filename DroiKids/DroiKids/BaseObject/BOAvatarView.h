//
//  BOAvatarView.h
//
//  用户头像视图，带填边的圆形图标，并伴有底缘阴影
//

#import <UIKit/UIKit.h>

@interface BOAvatarView : UIView

- (instancetype)initWithAvatarRadius:(CGFloat)radius;

@property (strong, nonatomic) UIImage *image;
@property (nonatomic) BOOL shadowEnable;
@property (nonatomic) CGFloat borderWidth;
- (void)setAvatarImageWithAvatarID:(NSNumber *)avatarID;
- (void)setImageWithURLString:(NSString *)urlString;

@end
