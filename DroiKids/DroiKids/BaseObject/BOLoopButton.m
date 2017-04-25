//
//  BOLoopButton.m
//
//  循环按钮，每完成点击一次，按钮的图标都会发生改变
//

#import "BOLoopButton.h"

@interface BOLoopButton ()
@property (strong, nonatomic) NSArray *buttomImages;
@end

@implementation BOLoopButton

- (id)initWithFrame:(CGRect)frame
{
    if(self = [super initWithFrame:frame])
    {
        [self initialize];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if(self = [super initWithCoder:aDecoder])
    {
        [self initialize];
    }
    return self;
}

- (void)initialize
{
    UITapGestureRecognizer *tapGR = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(switchState:)];
    [self addGestureRecognizer:tapGR];
}

#pragma mark - TouchEvent

- (void)switchState:(UIGestureRecognizer *)tapGestureRecognizer
{
    self.currentIndex = (self.currentIndex + 1) % self.buttomImages.count;
    [super sendActionsForControlEvents:UIControlEventTouchUpInside];
}

#pragma mark - OverrideSettingMethod

- (void)setCurrentIndex:(NSUInteger)currentIndex
{
    _currentIndex = currentIndex;
    [self setImage:self.buttomImages[currentIndex] forState:UIControlStateNormal];
}

- (void)setLoopImages:(NSArray *)images
{
    self.buttomImages = images;
    self.currentIndex = 0;
}

- (void)resetButtomImage
{
    self.currentIndex = 0;
}

@end
