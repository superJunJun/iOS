//
//  UIColor+Hex.m
//

#import "UIColor+Hex.h"

@implementation UIColor (Hex)

+ (UIColor *)colorWithHex:(long)hex
{
    return [UIColor colorWithHex:hex andAlpha:1.0];
}

+ (UIColor *)colorWithHex:(long)hex andAlpha:(float)alpha
{
    float red   = ((float)((hex & 0xFF0000) >> 16)) / 255.0;
    float green = ((float)((hex & 0xFF00) >> 8)) / 255.0;
    float blue  = ((float)((hex & 0xFF))) / 255.0;
    return [UIColor colorWithRed:red green:green blue:blue alpha:alpha];
}

@end
