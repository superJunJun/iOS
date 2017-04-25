//
//  TYDQRCodePhotoHandleController.h
//  DroiKids
//
//  Created by wangchao on 15/9/24.
//  Copyright © 2015年 TYDTech. All rights reserved.
//

#import "BaseScrollController.h"

@interface TYDQRCodePhotoHandleController : BaseScrollController

@property (strong, nonatomic) UIImage *QrCodeImage;
@property (assign, nonatomic) BOOL isFirstLoginSituation;

@end
