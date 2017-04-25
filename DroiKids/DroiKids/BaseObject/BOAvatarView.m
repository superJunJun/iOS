//
//  BOAvatarView.m
//
//  用户头像视图，带填边的圆形图标，并伴有底缘阴影
//

#import "BOAvatarView.h"
#import "UIImageView+WebCacheAssistor.h"
#import "TYDAvatarInfo.h"

#define cBolderColorForLoggedIn     [UIColor colorWithHex:0xffffff]
#define cBolderColorForLoggedOut    [UIColor colorWithHex:0xf098b8]

@interface BOAvatarView ()

@property (strong, nonatomic) UIImageView *avatarIcon;

@end

@implementation BOAvatarView

- (instancetype)initWithAvatarRadius:(CGFloat)radius
{
    CGRect frame = CGRectMake(0, 0, radius * 2, radius * 2);
    if(self = [super initWithFrame:frame])
    {
        //阴影
        self.backgroundColor = [UIColor clearColor];
        self.layer.shadowColor = [UIColor grayColor].CGColor;
        self.layer.shadowOffset = CGSizeMake(0, 2);
        self.layer.shadowOpacity = 1;
        self.layer.shadowRadius = 1.0;
        
        //圆形头像图标
        frame = self.bounds;
        UIImageView *avatarIcon = [[UIImageView alloc] initWithFrame:frame];
        avatarIcon.layer.cornerRadius = radius;
        avatarIcon.layer.borderColor = [UIColor whiteColor].CGColor;
        avatarIcon.layer.borderWidth = 1;
        avatarIcon.layer.masksToBounds = YES;
        [self addSubview:avatarIcon];
        
        self.avatarIcon = avatarIcon;
        self.image = [UIImage imageNamed:sAvatarDefaultName];
        self.shadowEnable = YES;
    }
    return self;
}

#pragma mark - Interface

- (void)setImageWithURLString:(NSString *)urlString
{
    [self.avatarIcon setImageWithURLString:urlString placeholderImage:[UIImage imageNamed:sAvatarDefaultName]];
}

- (void)setAvatarImageWithAvatarID:(NSNumber *)avatarID
{
    NSString *avatarName = sAvatarDefaultName;
    if(avatarID)
    {
        avatarName = [TYDAvatarInfo avatarIconNameWithAvatarID:avatarID];
    }
    self.avatarIcon.image = [UIImage imageNamed:avatarName];
}

#pragma mark - Override Property

- (void)setShadowEnable:(BOOL)shadowEnable
{
    _shadowEnable = shadowEnable;
    if(shadowEnable)
    {
        self.layer.shadowColor = [UIColor grayColor].CGColor;
    }
    else
    {
        self.layer.shadowColor = [UIColor clearColor].CGColor;
    }
}

- (void)setImage:(UIImage *)image
{
    if(!image)
    {
        self.avatarIcon.image = [UIImage imageNamed:sAvatarDefaultName];
        self.avatarIcon.layer.borderColor = cBolderColorForLoggedOut.CGColor;
    }
    else
    {
        self.avatarIcon.image = image;
        self.avatarIcon.layer.borderColor = cBolderColorForLoggedIn.CGColor;
    }
}

- (UIImage *)image
{
    return self.avatarIcon.image;
}

- (void)setBorderWidth:(CGFloat)borderWidth
{
    self.avatarIcon.layer.borderWidth = borderWidth;
}

- (CGFloat)borderWidth
{
    return self.avatarIcon.layer.borderWidth;
}

@end
