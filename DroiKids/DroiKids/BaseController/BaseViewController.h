//
//  BaseViewController.h
//

#import <UIKit/UIKit.h>

@interface BaseViewController : UIViewController

@property (strong, nonatomic) UIColor *navigationBarTintColor;
@property (assign, nonatomic) UIRectEdge customEdgesForExtendedLayout;
@property (strong, nonatomic) NSString *titleText;
@property (assign, nonatomic) BOOL backButtonVisible;

@property (assign, nonatomic) CGPoint noticeBarCenter;
@property (assign, nonatomic) BOOL isNoticeStyleBlack;
@property (assign, nonatomic) NSString *noticeText;

@property (assign, nonatomic) BOOL isSuspendEventEnable;
@property (assign, nonatomic) BOOL isNeedToHideNavigationBar;

- (void)popBackEventWillHappen;
- (void)popBackDirectly;

- (void)progressHUDShowWithText:(NSString *)text;
- (void)progressHUDShowWithCompleteText:(NSString *)text isSucceed:(BOOL)isSucceed;
- (void)progressHUDMomentaryShowWithTarget:(id)target action:(SEL)action object:(id)object;
- (void)progressHUDMomentaryShowWithText:(NSString *)text target:(id)target action:(SEL)action object:(id)object;
- (void)progressHUDShowWithCompleteText:(NSString *)text isSucceed:(BOOL)isSucceed additionalTarget:(id)target action:(SEL)action object:(id)object;
- (void)progressHUDHideImmediately;

- (BOOL)networkIsValid;
- (void)postURLRequestFailed:(NSUInteger)msgCode result:(id)result;
- (void)postURLRequestWithMessageCode:(NSUInteger)msgCode
                         HUDLabelText:(NSString *)text
                               params:(NSDictionary *)params
                        completeBlock:(PostUrlRequestCompleteBlock)completeBlock;

- (void)applicationWillResignActive;
- (void)applicationDidBecomeActive;

@end
