//
//  BOHUDManager.m
//

#import "BOHUDManager.h"
#import "MBProgressHUD.h"
#import "AppDelegate.h"

#define MBProgressHUDCompleteStayTime                   0.6
#define MBProgressHUDCompleteAdditionalFuncDelayTime    0.65

@interface BOHUDManager ()

@property (strong, nonatomic) MBProgressHUD *progressHUD;
@property (strong, nonatomic) UIImageView *customSuccessSignImageView;

@end

@implementation BOHUDManager

#pragma mark - SingleTon

+ (instancetype)defaultManager
{
    static BOHUDManager *sharedManagerInstance = nil;
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
        sharedManagerInstance = [[self alloc] init];
    });
    return sharedManagerInstance;
}


#pragma mark - OverridePropertyMethod

- (MBProgressHUD *)progressHUD
{
    if(!_progressHUD)
    {
        UIWindow *mainWindow = [[UIApplication sharedApplication].delegate window];
        
        MBProgressHUD *progressHUD = [MBProgressHUD showHUDAddedTo:mainWindow animated:NO];
        progressHUD.animationType = MBProgressHUDAnimationFade;
        progressHUD.removeFromSuperViewOnHide = YES;
        progressHUD.mode = MBProgressHUDModeIndeterminate;
        progressHUD.dimBackground = YES;
        progressHUD.customView = self.customSuccessSignImageView;
        _progressHUD = progressHUD;
    }
    return _progressHUD;
}

- (UIImageView *)customSuccessSignImageView
{
    if(!_customSuccessSignImageView)
    {
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 37, 37)];
        imageView.image = [UIImage imageNamed:@"40x-Checkmark"];
        imageView.highlightedImage = [UIImage imageNamed:@"40x-Cancelmark"];
        
        _customSuccessSignImageView = imageView;
    }
    return _customSuccessSignImageView;
}

#pragma mark - Event

- (void)progressHUDShowWithText:(NSString *)text
{
    self.progressHUD.mode = MBProgressHUDModeIndeterminate;
    self.progressHUD.labelText = text;
    [self.progressHUD show:YES];
}

- (void)progressHUDShowWithCompleteText:(NSString *)text isSucceed:(BOOL)isSucceed
{
    self.customSuccessSignImageView.highlighted = !isSucceed;
    self.progressHUD.labelText = text;
    self.progressHUD.mode = MBProgressHUDModeCustomView;
    [self.progressHUD hide:YES afterDelay:MBProgressHUDCompleteStayTime];
    self.progressHUD = nil;
}

- (void)progressHUDMomentaryShowWithText:(NSString *)text target:(id)target action:(SEL)action object:(id)object
{
    [self.progressHUD hide:YES afterDelay:MBProgressHUDCompleteStayTime];
    [target performSelector:action withObject:object afterDelay:MBProgressHUDCompleteAdditionalFuncDelayTime];
    self.progressHUD = nil;
}

- (void)progressHUDMomentaryShowWithTarget:(id)target action:(SEL)action object:(id)object
{
    [self progressHUDMomentaryShowWithText:nil target:target action:action object:object];
}

- (void)progressHUDShowWithCompleteText:(NSString *)text isSucceed:(BOOL)isSucceed additionalTarget:(id)target action:(SEL)action object:(id)object
{
    [self progressHUDShowWithCompleteText:text isSucceed:isSucceed];
    [target performSelector:action withObject:object afterDelay:MBProgressHUDCompleteAdditionalFuncDelayTime];
    self.progressHUD = nil;
}

- (void)progressHUDHideImmediately
{
    [self.progressHUD hide:NO];
    self.progressHUD = nil;
}

@end
