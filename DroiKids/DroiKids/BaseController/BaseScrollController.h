//
//  BaseScrollController.h
//

#import "BaseViewController.h"
#import "BOTextInputViewCollection.h"

@interface BaseScrollController : BaseViewController

@property (strong, nonatomic, readonly) UIScrollView *scrollView;
@property (strong, nonatomic, readonly) UIView *baseView;
@property (nonatomic) CGFloat baseViewBaseHeight;

//UITextField、UITextView
@property (strong, nonatomic, readonly) BOTextInputViewCollection *textInputViews;

- (void)tapOnSpace:(id)sender;

- (void)keyboardShowOrRiseWithKeyboardFrame:(CGRect)frameOfKeyboard animationDuration:(NSTimeInterval)duration animationOptions:(UIViewAnimationOptions)options;
- (void)keyboardHideWithAnimationDuration:(NSTimeInterval)duration animationOptions:(UIViewAnimationOptions)options;

@end
