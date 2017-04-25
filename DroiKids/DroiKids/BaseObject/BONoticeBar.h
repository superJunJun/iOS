//
//  BONoticeBar.h
//
//  单行文字弹出提示条
//
//  下次修正方向：只保留黑底白字风格，多行显示
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, BONoticeBarStyle)
{
    BONoticeBarStyleBlack = 0, //黑底白字，默认风格
    BONoticeBarStyleWhite = 1  //白底黑字
};

@interface BONoticeBar : NSObject

@property (strong, nonatomic) NSString *noticeText;
@property (nonatomic) CGPoint centerPoint;
@property (nonatomic) BONoticeBarStyle style;

+ (instancetype)defaultBar;

@end
