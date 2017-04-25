//
//  BOOnceTimer.m
//

#import "BOOnceTimer.h"

@interface BOOnceTimer ()

@property (strong, nonatomic) id target;
@property (assign, nonatomic) SEL selector;

@end

@implementation BOOnceTimer

- (instancetype)initWithTitle:(NSString *)title target:(id)target selector:(SEL)selector object:(id)object delay:(CGFloat)delay
{
    if(self = [super init])
    {
        _title = title;
        self.target = target;
        self.selector = selector;
        self.object = object;
        self.delay = delay;
        
        _didTimerStart = NO;
    }
    return self;
}

- (void)onceTimerStart
{
    [self onceTimerCancel];
    //NSLog(@"%@:onceTimerStart", self.title);
    _didTimerStart = YES;
    [self.target performSelector:self.selector withObject:self.object afterDelay:self.delay];
}

- (void)onceTimerCancel
{
    if(self.didTimerStart == YES)
    {
        [NSObject cancelPreviousPerformRequestsWithTarget:self.target selector:self.selector object:self.object];
        _didTimerStart = NO;
        //NSLog(@"%@:onceTimerCancel", self.title);
    }
}

@end
