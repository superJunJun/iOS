//
//  TYDGenderBlock.h
//  DroiKids
//
//  Created by wangchao on 15/8/18.
//  Copyright (c) 2015年 superjunjun. All rights reserved.
//

@interface TYDGenderBlock : UIButton

@property (strong, nonatomic) NSString *gender;

- (instancetype)initWithGenderName:(NSString *)genderName
                    genderNameFont:(UIFont *)genderNameFont
                    genderIconSize:(CGSize)genderIconSize;

@end
