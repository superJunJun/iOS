//
//  BOSwitchableIcon.m
//

#import "BOSwitchableIcon.h"

@interface BOSwitchableIcon ()
@property (strong, nonatomic) UIImageView *imageView;
@property (strong, nonatomic) UIImageView *imageViewH;
@property (nonatomic) BOOL shouldKeepHighlightedState;

@end

@implementation BOSwitchableIcon

- (instancetype)initWithImage:(UIImage *)image
                       imageH:(UIImage *)imageH
         keepHighlightedState:(BOOL)shouldKeepHighlightedState
{
    if(self = [super init])
    {
        self.backgroundColor = [UIColor clearColor];
        
        UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
        UIImageView *imageViewH = [[UIImageView alloc] initWithImage:imageH];
        self.size = CGSizeMake(MAX(imageView.width, imageViewH.width), MAX(imageView.height, imageViewH.height));
        imageView.center = self.innerCenter;
        imageViewH.center = self.innerCenter;
        [self addSubview:imageView];
        [self addSubview:imageViewH];
        
        [self addTarget:self action:@selector(switchableIconTap:) forControlEvents:UIControlEventTouchUpInside];
        
        self.imageView = imageView;
        self.imageViewH = imageViewH;
        self.shouldKeepHighlightedState = shouldKeepHighlightedState;
        self.selected = NO;
    }
    return self;
}

#pragma mark - OverrideSettingMethod

- (void)setSelected:(BOOL)selected
{
    [super setSelected:selected];
    if(selected)
    {
        self.imageView.hidden = YES;
        self.imageViewH.hidden = NO;
    }
    else
    {
        self.imageView.hidden = NO;
        self.imageViewH.hidden = YES;
    }
}

#pragma mark - TouchEvent

- (void)switchableIconTap:(id)sender
{
    NSLog(@"switchableIconTap");
    if((self.shouldKeepHighlightedState && !self.isSelected)
       || !self.shouldKeepHighlightedState)
    {
        self.selected = !self.selected;
        if([self.delegate respondsToSelector:@selector(switchableIconStateChanged:)])
        {
            [self.delegate switchableIconStateChanged:self];
        }
    }
}

@end
