//
//  TYDBackgroundColorBlock.h
//  DroiKids
//
//  Created by wangchao on 15/8/18.
//  Copyright (c) 2015年 superjunjun. All rights reserved.
//

@interface TYDBackgroundColorBlock : UIControl

@property (assign, nonatomic) BOOL checkIconVisible;
@property (assign, nonatomic) NSNumber *colorType;

- (instancetype)initWithSizeLength:(CGFloat)sizeLength andBackgroundColor:(NSNumber *)colorType;

@end
