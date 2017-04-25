//
//  UILabel+TYDNumberAnimationLabel.m
//  TYDNumberAnimationLabel
//
//  Created by wangchao on 14-5-25.
//

#import "UILabel+TYDNumberAnimationLabel.h"
#import <objc/runtime.h>

@implementation UILabel (TYDNumberAnimationLabel)

-(void)autochangeFontsize:(double) number{
    if (self.numberSizeBlock == NULL)
    {
        if (number < 100000)
        {
            [self setFont:[UIFont fontWithName:self.font.fontName size:60.0]];
        }
        else if (number < 1000000)
        {
            [self setFont:[UIFont fontWithName:self.font.fontName size:50.0]];
        }
        else if (number < 10000000)
        {
            [self setFont:[UIFont fontWithName:self.font.fontName size:40.0]];
        }
        else if (number < 100000000)
        {
            [self setFont:[UIFont fontWithName:self.font.fontName size:30.0]];
        }
    }
    else
    {
        self.numberSizeBlock(number);
    }
}
-(void)changeFromNumber:(float) originalnumber toNumber:(float) newnumber withAnimationTime:(NSTimeInterval)timeSpan{
    
    [UIView animateWithDuration:timeSpan delay:0 options:UIViewAnimationOptionTransitionNone animations:^{
        NSString *currencyStr = [NSString stringWithFormat:@"%d",(int)originalnumber];
        self.text = currencyStr;
        [self sizeToFit];
        self.center = CGPointMake(self.superview.width / 2, 70);
        
    } completion:^(BOOL finished) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(timeSpan * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            if(originalnumber == newnumber)
            {
                return;
            }
            else if(newnumber < originalnumber)
            {
                [self changeFromNumber:newnumber toNumber:newnumber withAnimationTime:timeSpan];
            }
            else if (fabs((newnumber - originalnumber) / self.animationSpeed) < 1)
            {
                [self changeFromNumber:originalnumber + 1 toNumber:newnumber withAnimationTime:timeSpan];
            }
            else if(fabs((newnumber - originalnumber) / self.animationSpeed) < fabs(newnumber - originalnumber))
            {
                [self changeFromNumber:originalnumber + (newnumber-originalnumber) / self.animationSpeed toNumber:newnumber withAnimationTime:timeSpan];
            }
        });
    }];
}

-(double)animationSpeed{
    double speed = ((NSNumber *)objc_getAssociatedObject(self, @selector(animationSpeed))).doubleValue;
    if (!speed) {
        speed = 15;
    }
    return speed;
}

-(void)setAnimationSpeed:(double)speed{
    objc_setAssociatedObject(self, @selector(animationSpeed), [NSNumber numberWithDouble:speed], OBJC_ASSOCIATION_COPY_NONATOMIC);
}

-(NumberSizeBlock)numberSizeBlock{
    return objc_getAssociatedObject(self, @selector(numberSizeBlock));
}

-(void)setNumberSizeBlock:(NumberSizeBlock) numberSizeBlock{
    objc_setAssociatedObject(self, @selector(numberSizeBlock), numberSizeBlock, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

@end
