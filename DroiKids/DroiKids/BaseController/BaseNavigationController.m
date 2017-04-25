//
//  BaseNavigationController.m
//

#import "BaseNavigationController.h"

@interface BaseNavigationController ()

@end

@implementation BaseNavigationController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationBar.barStyle = UIBarStyleBlack;
    self.navigationBar.translucent = NO;
    
    UIColor *tintColor = cBasicGreenColor;
    self.navigationBar.tintColor = tintColor;
    if([self.navigationBar respondsToSelector:@selector(barTintColor)])
    {
        self.navigationBar.barTintColor = tintColor;
    }
    
    UIFont *titleTextFont = [BOAssistor defaultTextStringFontWithSize:19];
    if(self.navigationBar.titleTextAttributes)
    {
        self.navigationBar.titleTextAttributes = @{NSFontAttributeName:titleTextFont};
    }
}

#pragma mark - Push

- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    viewController.hidesBottomBarWhenPushed = YES;
    [super pushViewController:viewController animated:animated];
}

- (void)pushViewControllerWithBottomBar:(UIViewController *)viewController animated:(BOOL)animated
{
    [super pushViewController:viewController animated:animated];
}

@end



