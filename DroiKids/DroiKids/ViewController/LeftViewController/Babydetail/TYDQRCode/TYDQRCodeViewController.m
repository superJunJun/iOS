//
//  TYDQRCodeViewController.m
//  DroiKids
//
//  Created by wangchao on 15/8/20.
//  Copyright (c) 2015年 superjunjun. All rights reserved.
//

#import "TYDQRCodeViewController.h"
#import "ZBarSDK.h"
#import "ScanAnimationView.h"
#import "TYDBindWatchIDController.h"
#import "TYDQRCodePhotoHandleController.h"
#import "TYDWatchInfo.h"
#import "TYDKidContactInfo.h"
#import "TYDBindAuthorizeController.h"
#import "TYDDataCenter.h"

#define SCREEN_WIDTH  [UIScreen mainScreen].bounds.size.width
#define SCREEN_HEIGHT [UIScreen mainScreen].bounds.size.height

@interface TYDQRCodeViewController () <UIAlertViewDelegate, AVCaptureMetadataOutputObjectsDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, ZBarReaderDelegate, BindingButtonTapDelegate>

@property (nonatomic, strong) AVCaptureMetadataOutput *captureMetadataOutput;
@property (nonatomic, strong) AVCaptureSession *captureSession;
@property (nonatomic, strong) AVCaptureVideoPreviewLayer *videoPreviewLayer;
@property (nonatomic, strong) ScanAnimationView *scanAnimationView;
@property (nonatomic, strong) NSString* content;

@end

@implementation TYDQRCodeViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self localDataInitialize];
    [self navigationBarItemsLoad];
    [self subviewsLoad];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self captureInitialize];
    [self.scanAnimationView startScanAnimation];
    [self.captureSession startRunning];
    
    [self addObserver];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [self.scanAnimationView stopScanAnimation];
    [self.captureSession stopRunning];
    
    [self removeObserver];
}

- (void)localDataInitialize
{
    
}

- (void)navigationBarItemsLoad
{
    self.title = @"二维码扫描";
    
    UIButton *photoLibraryButton = [UIButton new];
    [photoLibraryButton setTitle:@"相册" forState:UIControlStateNormal];
    [photoLibraryButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [photoLibraryButton setTitleColor:[UIColor grayColor] forState:UIControlStateHighlighted];
    [photoLibraryButton sizeToFit];
    [photoLibraryButton addTarget:self action:@selector(photoLibraryButtonTap:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *photoLibraryButtonItem = [[UIBarButtonItem alloc] initWithCustomView:photoLibraryButton];
    self.navigationItem.rightBarButtonItem = photoLibraryButtonItem;
}

- (void)subviewsLoad
{
    if (self.scanAnimationView == nil)
    {
        self.scanAnimationView = [[ScanAnimationView alloc] initWithFrame:self.view.bounds];
        self.scanAnimationView.delegate = self;
        [self.view addSubview:self.scanAnimationView];
    }
}

- (void)captureInitialize
{
    NSError *error;
    AVCaptureDevice *captureDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    if ([captureDevice isFocusModeSupported:AVCaptureFocusModeContinuousAutoFocus])
    {// 判断是否支持自动对焦
        // [captureDevice isFlashAvailable];// 判断是否支持闪光灯
    }
    
    AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:captureDevice error:&error];
    
    if (!input)
    {
        NSLog(@"%@", [error localizedDescription]);
    }
    
    
    self.captureSession = [[AVCaptureSession alloc] init];
    [self.captureSession addInput:input];
    
    AVCaptureMetadataOutput *captureMetadataOutput = [[AVCaptureMetadataOutput alloc] init];
    [self.captureSession addOutput:captureMetadataOutput];
    
    self.captureMetadataOutput = captureMetadataOutput;
    
    dispatch_queue_t dispatchQueue;
    dispatchQueue = dispatch_queue_create("myQueue", NULL);
    [captureMetadataOutput setMetadataObjectsDelegate:self queue:dispatchQueue];
    if ( [captureMetadataOutput.availableMetadataObjectTypes containsObject:AVMetadataObjectTypeQRCode])
    {
        [captureMetadataOutput setMetadataObjectTypes: @[AVMetadataObjectTypeQRCode,
                                                         AVMetadataObjectTypeCode128Code,
                                                         AVMetadataObjectTypeEAN8Code,
                                                         AVMetadataObjectTypeUPCECode,
                                                         AVMetadataObjectTypeCode39Code,
                                                         AVMetadataObjectTypePDF417Code,
                                                         AVMetadataObjectTypeAztecCode,
                                                         AVMetadataObjectTypeCode93Code,
                                                         AVMetadataObjectTypeEAN13Code,
                                                         AVMetadataObjectTypeCode39Mod43Code]];
    }
    else
    {
        self.noticeText = @"此设备不支持识别";
        return;
    }
    
    [self.videoPreviewLayer removeFromSuperlayer];
    self.videoPreviewLayer = nil;
    
    self.videoPreviewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:self.captureSession];
    [self.videoPreviewLayer setVideoGravity:AVLayerVideoGravityResizeAspectFill];
    [self.videoPreviewLayer setFrame:self.view.layer.bounds];
    
    CGRect frame = self.view.frame;
    float scanFrameWidth  = SCREEN_WIDTH  * 2.0f / 3.0f;
    float scanFrameheight = SCREEN_WIDTH  * 2.0f / 3.0f;
    
    CGRect cropRect = CGRectMake((frame.size.width - scanFrameWidth) / 2.0f, (frame.size.height * 4 / 5 - scanFrameheight) / 2.0f, scanFrameWidth, scanFrameheight);
    CGSize size = frame.size;
    CGFloat p1 = size.height / size.width;
    CGFloat p2 = 1920 / 1080;  //使用了1080p的图像输出
    if (p1 < p2)
    {
        CGFloat fixHeight = frame.size.width * 1920 / 1080;
        CGFloat fixPadding = (fixHeight - size.height) / 2;
        self.captureMetadataOutput.rectOfInterest = CGRectMake((cropRect.origin.y + fixPadding) / fixHeight,
                                                               cropRect.origin.x / size.width,
                                                               cropRect.size.height / fixHeight,
                                                               cropRect.size.width / size.width);
    }
    else
    {
        CGFloat fixWidth = frame.size.height * 1080 / 1920;
        CGFloat fixPadding = (fixWidth - size.width) / 2;
        self.captureMetadataOutput.rectOfInterest = CGRectMake(cropRect.origin.y / size.height,
                                                               (cropRect.origin.x + fixPadding) / fixWidth,
                                                               cropRect.size.height / size.height,
                                                               cropRect.size.width / fixWidth);
    }
    
    [self.view.layer addSublayer:self.videoPreviewLayer];
    [self.view bringSubviewToFront:self.scanAnimationView];
}

#pragma mark - AVCaptureMetadataOutputObjectsDelegate

-(void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection
{
    if(metadataObjects != nil && metadataObjects.count > 0)
    {
        [_captureSession stopRunning];
        
        AVMetadataMachineReadableCodeObject *metadataObj = [metadataObjects objectAtIndex:0];
        self.content = metadataObj.stringValue;
        
        if([BOAssistor numberStringValid:self.content]
           && [BOAssistor textLength:self.content] == 8)
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                
                [self.scanAnimationView stopScanAnimation];
                
                NSString *message = [NSString stringWithFormat:@"是否绑定：%@", self.content];
                
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"绑定联系人"
                                                                    message:message
                                                                   delegate:self
                                                          cancelButtonTitle:@"取消"
                                                          otherButtonTitles:@"确定", nil];
                
                [alertView show];
            });
        }
        else
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                
                [self.scanAnimationView stopScanAnimation];
                
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"扫描错误" message:@"请扫描正确的二维码" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
                [alertView show];
            });
        }
    }
}

#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if([alertView.title isEqualToString:@"扫描错误"])
    {
        [_captureSession startRunning];
        [self.scanAnimationView startScanAnimation];
    }
    else
    {
        if(alertView.cancelButtonIndex == buttonIndex)
        {
            [_captureSession startRunning];
            [self.scanAnimationView startScanAnimation];
        }
        else
        {
            NSString *buttonTitle = [alertView buttonTitleAtIndex:buttonIndex];
            
            if([buttonTitle isEqualToString:@"确定"])
            {
                [self bindingChild];
            }
        }
    }
}

#pragma mark - ConnectServer

- (void)bindingChild
{
    NSMutableDictionary *params = [NSMutableDictionary new];
    [params setValue:[TYDUserInfo sharedUserInfo].openID forKey:sPostUrlRequestUserOpenIDKey];
    [params setValue:@"其他" forKey:@"relationship"];
    [params setValue:self.content forKey:@"watchid"];
    [params setValue:@(TYDKidContactOther) forKey:@"imgid"];
    
    [self postURLRequestWithMessageCode:ServiceMsgCodeBindWatchNormal
                           HUDLabelText:nil
                                 params:params
                          completeBlock:^(id result) {
                              [self bindWatchNormalComplete:result];
                          }];
    
}

- (void)bindWatchNormalComplete:(id)result
{
    NSLog(@"bindWatchNormalComplete:%@", result);
    
    NSNumber *value = result[@"result"];
    NSDictionary *childInfo = result[@"watchChild"];
    
    if(value.intValue == 0)
    {
        self.noticeText = @"绑定成功";
        
        [self bindingSucceedWithChildInfo:childInfo];
    }
    else if(value.intValue == 4)
    {
        if([TYDDataCenter defaultCenter].currentKidInfo)
        {
            [self.navigationController popToRootViewControllerAnimated:YES];
        }
        else
        {
            TYDBindAuthorizeController *vc = [TYDBindAuthorizeController new];
            [self.navigationController pushViewController:vc animated:YES];
        }
        
        self.noticeText = @"等待管理员审核";
    }
    else
    {
        self.noticeText = @"绑定失败";
        
        [_captureSession startRunning];
        [self.scanAnimationView startScanAnimation];
    }
    
    [self progressHUDHideImmediately];
}

- (void)bindingSucceedWithChildInfo:(NSDictionary *)childInfo
{
    TYDDataCenter *dataCenter = [TYDDataCenter defaultCenter];
    NSMutableArray *kidInfoList = dataCenter.kidInfoList.mutableCopy;
    
    TYDKidInfo *kidInfo = [TYDKidInfo new];
    [kidInfo setAttributes:childInfo];
    
    [kidInfoList addObject:kidInfo];
    [dataCenter saveKidInfoList:kidInfoList];
    dataCenter.currentKidInfo = kidInfo;
    
    if(self.isFirstLoginSituation)
    {
        UINavigationController *mainNavigationController = [self.storyboard instantiateViewControllerWithIdentifier:@"mainNavigationController"];
        [self presentViewController:mainNavigationController animated:YES completion:^{
            [self.navigationController popViewControllerAnimated:NO];
        }];
    }
    else
    {
        [self.navigationController popToRootViewControllerAnimated:YES];
    }
}

#pragma mark - BindingButtonTapDelegate

- (void)bindingButtonTap
{
    TYDBindWatchIDController *vc = [TYDBindWatchIDController new];
    vc.isFirstLoginSituation = self.isFirstLoginSituation;
    [self.navigationController pushViewController:vc animated:YES];
}

-(void)stopReading
{
    [self.captureSession stopRunning];
    self.captureSession = nil;
    [self.videoPreviewLayer removeFromSuperlayer];
}

#pragma mark - TouchEvent

- (void)photoLibraryButtonTap:(UIButton *)button
{
    NSLog(@"photoLibraryButtonTap");
    [self stopReading];
    
    UIImagePickerController *imagePickerController = [UIImagePickerController new];
    imagePickerController.delegate = self;
    imagePickerController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
   
    [self.captureSession stopRunning];
        [self presentViewController:imagePickerController animated:YES completion:nil];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{//相册扫描二维码
    
    UIImage *image = info[UIImagePickerControllerOriginalImage];
    
    TYDQRCodePhotoHandleController *vc = [TYDQRCodePhotoHandleController new];
    vc.isFirstLoginSituation = self.isFirstLoginSituation;
    vc.QrCodeImage = image;
    [self.navigationController pushViewController:vc animated:YES];
    
    [picker.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - OverrideMethod

- (void)popBackEventWillHappen
{
    [super popBackEventWillHappen];
}

#pragma mark - SuspendEvent

- (void)addObserver
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didBecomeActiveNotification:) name:UIApplicationDidBecomeActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(willResignActiveNotification:) name:UIApplicationWillResignActiveNotification object:nil];
}

- (void)removeObserver
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidBecomeActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationWillResignActiveNotification object:nil];
}

- (void)didBecomeActiveNotification:(NSNotification *)notification
{
    [self.scanAnimationView startScanAnimation];
    [self.captureSession startRunning];
}

- (void)willResignActiveNotification:(NSNotification *)notification
{
    [self.scanAnimationView stopScanAnimation];
    [self.captureSession stopRunning];
}

@end
