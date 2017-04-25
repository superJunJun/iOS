//
//  BaseNavigationController.h
//

#import <UIKit/UIKit.h>

@interface BaseNavigationController : UINavigationController

- (void)pushViewControllerWithBottomBar:(UIViewController *)viewController animated:(BOOL)animated;

@end
