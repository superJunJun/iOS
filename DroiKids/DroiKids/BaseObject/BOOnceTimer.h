//
//  BOOnceTimer.h
//
//  一次性定时器
//

#import <Foundation/Foundation.h>

@interface BOOnceTimer : NSObject

@property (strong, nonatomic, readonly) NSString *title;
@property (assign, nonatomic, readonly) BOOL didTimerStart;
@property (strong, nonatomic) id object;
@property (assign, nonatomic) CGFloat delay;

- (instancetype)initWithTitle:(NSString *)title target:(id)target selector:(SEL)selector object:(id)object delay:(CGFloat)delay;
- (void)onceTimerStart;
- (void)onceTimerCancel;

@end
