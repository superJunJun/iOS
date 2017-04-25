//
//  UIColor+Hex.h
//

#import <UIKit/UIKit.h>

#define UIColorWithHex(hex) [UIColor colorWithRed:((float)((hex & 0xFF0000) >> 16))/255.0 green:((float)((hex & 0xFF00) >> 8))/255.0 blue:((float)(hex & 0xFF))/255.0 alpha:1.0]
#define UIColorWithHexAndAlpha(hex, alphaValue) [UIColor colorWithRed:((float)((hex & 0xFF0000) >> 16))/255.0 green:((float)((hex & 0xFF00) >> 8))/255.0 blue:((float)(hex & 0xFF))/255.0 alpha:alphaValue]

@interface UIColor (Hex)

+ (UIColor *)colorWithHex:(long)hex;
+ (UIColor *)colorWithHex:(long)hex andAlpha:(float)alpha;

@end
