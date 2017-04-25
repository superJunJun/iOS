//
//  BOSwitchableIcon.h
//
//  能响应点击事件，点击切换image和highlightedImage，不需要按钮的点击闪动效果
//  不使用UIImageView，避免UITableViewCell中点击出现意外高亮图闪动的情形
//  通过selected属性进行图片显示切换

#import <UIKit/UIKit.h>

@class BOSwitchableIcon;
@protocol BOSwitchableIconDelegate <NSObject>
@optional
- (void)switchableIconStateChanged:(BOSwitchableIcon *)switchableIcon;
@end

@interface BOSwitchableIcon : UIControl

@property (assign, nonatomic) id<BOSwitchableIconDelegate> delegate;
- (instancetype)initWithImage:(UIImage *)image
                       imageH:(UIImage *)imageH
         keepHighlightedState:(BOOL)shouldKeepHighlightedState;

@end
