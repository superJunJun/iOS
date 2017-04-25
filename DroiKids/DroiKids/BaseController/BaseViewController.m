//
//  BaseViewController.m
//

#import "BaseViewController.h"
#import "TYDPostUrlRequest.h"
#import "BOHUDManager.h"
#import "BONoticeBar.h"
#import "SBJson.h"
#import "DESUtil.h"

@interface BaseViewController () 

@property (strong, nonatomic) UIButton *backButton;
@property (strong, nonatomic) UIBarButtonItem *naviBackButtonItem;
@property (strong, nonatomic) BOHUDManager *hudManager;
@property (strong, nonatomic) BONoticeBar *noticeBar;

@end

@implementation BaseViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = cBasicBackgroundColor;
    
    [self localBasicInfosInitialize];
}

- (void)localBasicInfosInitialize
{
    self.customEdgesForExtendedLayout = UIRectEdgeNone;
    self.hudManager = [BOHUDManager defaultManager];
    self.backButtonVisible = YES;
    self.isSuspendEventEnable = NO;
    self.isNeedToHideNavigationBar = NO;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    //self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:self action:nil];
    if(self.navigationController.viewControllers.count > 1
       && (self.navigationItem.leftBarButtonItem == nil
           || self.navigationItem.leftBarButtonItems.count == 0))
    {
        self.navigationItem.leftBarButtonItem = self.naviBackButtonItem;
    }
    
    [self.navigationController setNavigationBarHidden:self.isNeedToHideNavigationBar animated:animated];
    _naviBackButtonItem.enabled = YES;
    self.backButton.hidden = !self.backButtonVisible;
//    [self.navigationController.navigationBar setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIFont fontWithName:@"Marion-Italic" size:20.0],NSFontAttributeName,nil]];
    [self basicAppendSuspendEventNotifications];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    _naviBackButtonItem.enabled = NO;
    [self basicRemoveSuspendEventNotifications];
}

#pragma mark - TouchEvent

- (void)popBackEventWillHappen
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)popBackDirectly
{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - OverridePropertyMethod

- (void)setCustomEdgesForExtendedLayout:(UIRectEdge)customEdgesForExtendedLayout
{
    if([self respondsToSelector:@selector(edgesForExtendedLayout)])
    {
        self.edgesForExtendedLayout = customEdgesForExtendedLayout;
        _customEdgesForExtendedLayout = customEdgesForExtendedLayout;
    }
}

- (void)setNavigationBarTintColor:(UIColor *)navigationBarTintColor
{
    _navigationBarTintColor = navigationBarTintColor;
    UINavigationBar *navigationBar = self.navigationController.navigationBar;
    navigationBar.tintColor = navigationBarTintColor;
    if([navigationBar respondsToSelector:@selector(barTintColor)])
    {
        navigationBar.barTintColor = navigationBarTintColor;
    }
}

- (void)setTitleText:(NSString *)titleText
{
    _titleText = titleText;
    self.navigationItem.title = titleText;
}

- (void)setBackButtonVisible:(BOOL)backButtonVisible
{
    if(_backButtonVisible != backButtonVisible)
    {
        _backButtonVisible = backButtonVisible;
        self.backButton.hidden = !backButtonVisible;
    }
}

- (UIBarButtonItem *)naviBackButtonItem
{
    if(_naviBackButtonItem == nil)
    {
        UIImage *backBtnImage = [UIImage imageNamed:@"common_naviBackBtn"];
        UIImage *backBtnImageH = [UIImage imageNamed:@"common_naviBackBtnH"];
        UIButton *backButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, backBtnImage.size.width, backBtnImage.size.height)];
        [backButton setImage:backBtnImage forState:UIControlStateNormal];
        [backButton setImage:backBtnImageH forState:UIControlStateHighlighted];
        [backButton addTarget:self action:@selector(popBackEventWillHappen) forControlEvents:UIControlEventTouchUpInside];
        UIBarButtonItem *backItem = [[UIBarButtonItem alloc] initWithCustomView:backButton];
        
        _naviBackButtonItem = backItem;
        _naviBackButtonItem.enabled = NO;
        self.backButton = backButton;
    }
    return _naviBackButtonItem;
}

- (UIStoryboard *)storyboard
{
    UIStoryboard *storyboard = super.storyboard;
    if(storyboard == nil)
    {
        storyboard = [UIStoryboard storyboardWithName:sMainStoryboardName bundle:[NSBundle mainBundle]];
    }
    return storyboard;
}

#pragma mark - HUD

- (void)progressHUDShowWithText:(NSString *)text
{
    [self.hudManager progressHUDShowWithText:text];
}

- (void)progressHUDShowWithCompleteText:(NSString *)text isSucceed:(BOOL)isSucceed
{
    [self.hudManager progressHUDShowWithCompleteText:text isSucceed:isSucceed];
}

- (void)progressHUDMomentaryShowWithTarget:(id)target action:(SEL)action object:(id)object
{
    [self.hudManager progressHUDMomentaryShowWithTarget:target action:action object:object];
}

- (void)progressHUDMomentaryShowWithText:(NSString *)text target:(id)target action:(SEL)action object:(id)object
{
    [self.hudManager progressHUDMomentaryShowWithText:text target:target action:action object:object];
}

- (void)progressHUDShowWithCompleteText:(NSString *)text isSucceed:(BOOL)isSucceed additionalTarget:(id)target action:(SEL)action object:(id)object
{
    [self.hudManager progressHUDShowWithCompleteText:text isSucceed:isSucceed additionalTarget:target action:action object:object];
}

- (void)progressHUDHideImmediately
{
    [self.hudManager progressHUDHideImmediately];
}

#pragma mark - NoticeBar

- (BONoticeBar *)noticeBar
{
    if(!_noticeBar)
    {
        _noticeBar = [BONoticeBar defaultBar];
    }
    return _noticeBar;
}

- (void)setNoticeText:(NSString *)noticeText
{
    self.noticeBar.noticeText = noticeText;
}

- (void)setNoticeBarCenter:(CGPoint)noticeBarCenter
{
    self.noticeBar.centerPoint = noticeBarCenter;
}

- (void)setIsNoticeStyleBlack:(BOOL)isNoticeStyleBlack
{
    self.noticeBar.style = isNoticeStyleBlack ? BONoticeBarStyleBlack : BONoticeBarStyleWhite;
}

#pragma mark - URLRequest

- (BOOL)networkIsValid
{
    return [TYDPostUrlRequest networkConnectionIsAvailable];
}

- (void)postURLRequestFailed:(NSUInteger)msgCode result:(id)result
{
    NSError *error = result;
    NSString *errorDescription = sNetworkError;
    if([error.localizedDescription isEqualToString:@"The request timed out."])
    {
        errorDescription = sNetworkTimeout;
    }
    
    [self progressHUDHideImmediately];
    self.noticeText = errorDescription;
    
    NSLog(@"httpRequestFailed! msgCode:%lu, Error - %@ %@", (unsigned long)msgCode, [error localizedDescription], [[error userInfo] objectForKey:NSURLErrorFailingURLStringErrorKey]);
}

- (void)postURLRequestWithMessageCode:(NSUInteger)msgCode
                         HUDLabelText:(NSString *)text
                               params:(NSDictionary *)params
                        completeBlock:(PostUrlRequestCompleteBlock)completeBlock
{
    [self progressHUDShowWithText:text];
    
    if(![self networkIsValid])
    {
        [self progressHUDHideImmediately];
        self.noticeText = sNetworkFailed;
        return;
    }
    __weak typeof(self) wself = self;
    [TYDPostUrlRequest postUrlRequestWithMessageCode:msgCode
                                              params:params
                                       completeBlock:completeBlock
                                         failedBlock:^(NSUInteger msgCode, id result) {
                                             [wself postURLRequestFailed:msgCode result:result];
                                         }];
}

#pragma mark - SuspendEvent

- (void)basicAppendSuspendEventNotifications
{
    if(self.isSuspendEventEnable == YES)
    {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didBecomeActiveNotification:) name:UIApplicationDidBecomeActiveNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(willResignActiveNotification:) name:UIApplicationWillResignActiveNotification object:nil];
    }
}

- (void)basicRemoveSuspendEventNotifications
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidBecomeActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationWillResignActiveNotification object:nil];
}

- (void)didBecomeActiveNotification:(NSNotification *)notification
{
    [self applicationDidBecomeActive];
}

- (void)willResignActiveNotification:(NSNotification *)notification
{
    [self applicationWillResignActive];
}

- (void)applicationWillResignActive
{}

- (void)applicationDidBecomeActive
{}

@end
