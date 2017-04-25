//
//  BOAssistor.h
//
//  常用的辅助功能
//

#import <Foundation/Foundation.h>

@interface BOAssistor : NSObject

//区间随机数
+ (NSInteger)randomNumberBetweenNumber:(NSInteger)num1 andNumber:(NSInteger)num2;

//支持的字体信息
+ (void)supportedFontsInfoPrint;

//
+ (UIBarButtonItem *)barButtonItemCreateWithImage:(UIImage *)image
                                 highlightedImage:(UIImage *)imageH
                                           target:(id)target
                                           action:(SEL)action;
+ (UIBarButtonItem *)barButtonItemCreateWithImageName:(NSString *)imageName
                                 highlightedImageName:(NSString *)imageNameH
                                               target:(id)target
                                               action:(SEL)action;

//字符有效性验证
+ (BOOL)numberStringValid:(NSString *)string;
+ (BOOL)personNameIsValid:(NSString *)name;
+ (BOOL)usernameIsValid:(NSString *)username;
+ (BOOL)postCodeIsValid:(NSString *)postCode;
+ (BOOL)emailIsValid:(NSString *)email;
+ (BOOL)cellPhoneNumberIsValid:(NSString *)cellPhoneNumber;
+ (BOOL)phoneNumberIsValid:(NSString *)phoneNumber;
+ (BOOL)passwordLengthIsValid:(NSString *)password;//4~48
+ (BOOL)passwordIsValid:(NSString *)password;
+ (BOOL)emoveUserNickNameIsValid:(NSString *)nickName;
+ (BOOL)emoveUserSignatureIsValid:(NSString *)signature;
//清理字符串
+ (NSString *)stringTrim:(NSString *)resStr;

//字符串中汉字数量
+ (NSUInteger)chineseCharactersLengthInString:(NSString *)string;

//当前应用urlSchemes，例如
//(
//    wx208085f3b093ecbf,
//    tencent1102204477,
//    wb4148108674
//)
+ (NSArray *)appUrlSchemes;

//版本短号
+ (NSString *)appShortVersionString;

//版本号
+ (NSNumber *)appVersionNumber;

//BundleID
+ (NSString *)appBundleID;

//系统版本号
+ (CGFloat)systemVersion;

//调试辅助功能
+ (void)rangeShow:(NSRange)range withTitle:(NSString *)title;
+ (void)rectangleShow:(CGRect)rect withTitle:(NSString *)title;
+ (void)pointShow:(CGPoint)point withTitle:(NSString *)title;
+ (void)sizeShow:(CGSize)size withTitle:(NSString *)title;
+ (void)indexPathShow:(NSIndexPath *)indexPath withTitle:(NSString *)title;

//判定是否为图片地址
+ (BOOL)isImageFilePath:(NSString *)imagePath;

//获取规定font及width的空格字符串
+ (NSString *)replaceSpaceByBlankStringWidth:(CGFloat)width font:(UIFont *)font;
+ (CGSize)string:(NSString *)string sizeWithFont:(UIFont *)font;
+ (CGSize)string:(NSString *)string sizeWithFont:(UIFont *)font constrainedToWidth:(CGFloat)width lineBreakMode:(NSLineBreakMode)mode;

//uniqueDeviceIdentifier
+ (NSString *)deviceUDID;

+ (NSString *)languageEnvironment;

+ (int)textLength:(NSString *)text;

//distanceString 单位公里
+ (NSString *)distanceStringWithDistance:(CGFloat)distance;

+ (NSString *)charArrayToHexString:(char *)charArray length:(int)length;

+ (UIFont *)defaultTextStringFontWithSize:(CGFloat)fontSize;

@end
