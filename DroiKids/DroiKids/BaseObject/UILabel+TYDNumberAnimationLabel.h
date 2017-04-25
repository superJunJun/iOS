//
//  UILabel+TYDNumberAnimationLabel.h
//  TYDNumberAnimationLabel
//
//  Created by wangchao on 14-5-25.
//

#import <UIKit/UIKit.h>
typedef void(^NumberSizeBlock)(double number);

@interface UILabel (TYDNumberAnimationLabel)

-(void)changeFromNumber:(float) originalnumber toNumber:(float) newnumber withAnimationTime:(NSTimeInterval)timeSpan;
-(double)animationSpeed;
-(void)setAnimationSpeed:(double)speed;
-(NumberSizeBlock)numberSizeBlock;
-(void)setNumberSizeBlock:(NumberSizeBlock) numberSizeBlock;

@end
