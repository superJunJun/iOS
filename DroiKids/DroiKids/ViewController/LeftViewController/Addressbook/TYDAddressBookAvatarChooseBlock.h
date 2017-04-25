//
//  TYDAddressBookAvatarChooseBlock.h
//  DroiKids
//
//  Created by wangchao on 15/8/26.
//  Copyright (c) 2015年 TYDTech. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TYDAddressBookAvatarChooseBlock : UIControl

@property (assign, nonatomic) BOOL checkIconVisible;
@property (strong, nonatomic) UIImage *avatarImage;
@property (strong, nonatomic) NSNumber *avatarID;

- (instancetype)initWithAvatarSizeLength:(CGFloat)sizeLength relationShipName:(NSNumber *)avatarID;

@end
