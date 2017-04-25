//
//  BOSegmentedView.m
//

#import "BOSegmentedView.h"

@interface BOSegmentedView ()

@property (strong, nonatomic) NSMutableArray *titleLabels;
@property (strong, nonatomic) UIView *indicatorBar;

@end

@implementation BOSegmentedView

- (instancetype)initWithFrame:(CGRect)frame
                       titles:(NSArray *)titles
                    titleFont:(UIFont *)titleFont
             titleNormalColor:(UIColor *)titleNormalColor
           titleSelectedColor:(UIColor *)titleSelectedColor
          titleLabelVerOffset:(CGFloat)titleLabelVerOffset
            indicatorBarColor:(UIColor *)indicatorBarColor
              backgroundColor:(UIColor *)backgroundColor
        segmentSeparatorImage:(UIImage *)segmentSeparatorImage
                 cornerRadius:(CGFloat)cornerRadius
{
    if(self = [super initWithFrame:frame])
    {
        self.backgroundColor = backgroundColor;
        self.layer.cornerRadius = cornerRadius;
        self.titleLabels = [NSMutableArray new];
        
        frame.size.width /= titles.count;
        for(int i = 0; i < titles.count; i++)
        {
            UIControl *item = [[UIControl alloc] initWithFrame:frame];
            item.backgroundColor = [UIColor clearColor];
            item.tag = i;
            [self addSubview:item];
            
            UILabel *titleLabel = [[UILabel alloc] initWithFrame:frame];
            titleLabel.backgroundColor = [UIColor clearColor];
            titleLabel.font = titleFont;
            titleLabel.textColor = titleNormalColor;
            titleLabel.highlightedTextColor = titleSelectedColor;
            titleLabel.text = titles[i];
            [titleLabel sizeToFit];
            titleLabel.center = item.innerCenter;
            titleLabel.yCenter += titleLabelVerOffset;//vertical Offset
            [item addSubview:titleLabel];
            [self.titleLabels addObject:titleLabel];
            
            if(i != 0)
            {
                UIImageView *separatorLine = [[UIImageView alloc] initWithImage:segmentSeparatorImage];
                separatorLine.center = CGPointMake(item.left, item.yCenter);
                [self addSubview:separatorLine];
            }
            
            [item addTarget:self action:@selector(itemTap:) forControlEvents:UIControlEventTouchDown];
            frame.origin.x += item.width;
        }
        
        UIView *indicatorBar = [UIView new];
        indicatorBar.width = frame.size.width;
        indicatorBar.size = CGSizeMake(frame.size.width, 3);
        indicatorBar.backgroundColor = indicatorBarColor;
        indicatorBar.bottomLeft = CGPointMake(0, self.height);
        [self addSubview:indicatorBar];
        self.indicatorBar = indicatorBar;
        
        _selectedSegmentIndex = 1;
        self.selectedSegmentIndex = 0;
    }
    return self;
}

- (void)setSelectedSegmentIndex:(NSUInteger)index
{
    if(_selectedSegmentIndex != index
       && index < self.titleLabels.count)
    {
        UILabel *lastSelectedTitleLabel = self.titleLabels[self.selectedSegmentIndex];
        lastSelectedTitleLabel.highlighted = NO;
        
        UILabel *currentSelectedTitleLabel = self.titleLabels[index];
        currentSelectedTitleLabel.highlighted = YES;
        
        _selectedSegmentIndex = index;
        
        [self indicatorBarMoveAnimation];
    }
}

- (void)indicatorBarMoveAnimation
{
    UILabel *titleLabel = self.titleLabels[self.selectedSegmentIndex];
    CGPoint titleLabelCenter = titleLabel.center;
    titleLabelCenter = [self convertPoint:titleLabelCenter fromView:titleLabel.superview];
    [UIView animateWithDuration:0.25 animations:^{
        self.indicatorBar.xCenter = titleLabelCenter.x;
    }];
}

#pragma mark - TouchEvent

- (void)itemTap:(UIControl *)sender
{
    NSUInteger itemIndex = sender.tag;
    if(self.selectedSegmentIndex != itemIndex)
    {
        self.selectedSegmentIndex = itemIndex;
        if([self.delegate respondsToSelector:@selector(segmentedView:valueChanged:)])
        {
            [self.delegate segmentedView:self valueChanged:itemIndex];
        }
    }
}

@end
