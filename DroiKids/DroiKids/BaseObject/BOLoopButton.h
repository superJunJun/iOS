//
//  BOLoopButton.h
//
//  循环按钮，每完成点击一次，按钮的图标都会发生改变
//

#import <UIKit/UIKit.h>

@interface BOLoopButton : UIButton

@property (nonatomic) NSUInteger currentIndex;
- (void)setLoopImages:(NSArray *)images;
- (void)resetButtomImage;

@end
