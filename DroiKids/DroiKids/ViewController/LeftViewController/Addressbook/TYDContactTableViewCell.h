//
//  TYDContactTableViewCell.h
//  DroiKids
//
//  Created by superjunjun on 15/8/21.
//  Copyright (c) 2015年 superjunjun. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TYDKidContactInfo.h"

@interface TYDContactTableViewCell : UITableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier;

@property (strong, nonatomic) TYDKidContactInfo *kidContactInfo;

@property (assign, nonatomic) TYDKidContactQuickNumber quicklyNumberType;
@property (assign, nonatomic) TYDKidContactType contactType;

+ (CGFloat)cellHeight;

@end
