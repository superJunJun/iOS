//
//  TYDActionSheet.m
//  DroiKids
//
//  Created by wangchao on 15/8/27.
//  Copyright (c) 2015年 TYDTech. All rights reserved.
//

#import "TYDActionSheet.h"

#define MARGIN_LEFT       20
#define MARGIN_RIGHT      20
#define SPACE_SMALL       5
#define TITLE_FONT_SIZE   15
#define BUTTON_FONT_SIZE  14

static CGFloat contentViewWidth;
static CGFloat contentViewHeight;

@interface TYDActionSheet ()

@property (strong, nonatomic) UIView *backgroundView;
@property (strong, nonatomic) UIView *contentView;
@property (strong, nonatomic) UIView *buttonView;
@property (strong, nonatomic) UILabel *titleLabel;
@property (strong, nonatomic) NSMutableArray *buttonArray;
@property (strong, nonatomic) UIButton *cancelButton;

@property (strong, nonatomic) NSMutableArray *buttonTitleArray;

@end

@implementation TYDActionSheet

- (id)initWithTitle:(NSString *)title delegate:(id)delegate cancelButtonTitle:(NSString *)cancelButtonTitle othersButtonTitle:(NSString *)othersButtonTitle, ...
{
    if(self = [super initWithFrame:[UIScreen mainScreen].bounds])
    {
        _title = title;
        _delegate = delegate;
        _cancelButtonTitle = cancelButtonTitle;
        _buttonArray = [NSMutableArray array];
        _buttonTitleArray = [NSMutableArray array];
        
        va_list args;
        va_start(args, othersButtonTitle);
        if(othersButtonTitle)
        {
            [_buttonTitleArray addObject:othersButtonTitle];
            while(1)
            {
                NSString *otherButtonTitle = va_arg(args, NSString *);
                if(otherButtonTitle == nil)
                {
                    break;
                }
                else
                {
                    [_buttonTitleArray addObject:otherButtonTitle];
                }
            }
        }
        va_end(args);
        
        self.backgroundColor = [UIColor clearColor];
        
        UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hide)];
        _backgroundView = [[UIView alloc] initWithFrame:self.frame];
        _backgroundView.alpha = 0;
        _backgroundView.backgroundColor = [UIColor blackColor];
        [_backgroundView addGestureRecognizer:tapGestureRecognizer];
        [self addSubview:_backgroundView];
        
        [self initContentView];
    }
    return self;
}

- (id)initWithTitle:(NSString *)title delegate:(id)delegate cancelButtonTitle:(NSString *)cancelButtonTitle otherButtonTitles:(NSArray *)otherButtonTitles
{
    if(self = [super initWithFrame:[UIScreen mainScreen].bounds])
    {
        self.title = title;
        self.delegate = delegate;
        self.cancelButtonTitle = cancelButtonTitle;
        self.buttonArray = [NSMutableArray array];
        self.buttonTitleArray = [NSMutableArray arrayWithArray:otherButtonTitles];
        
        self.backgroundColor = [UIColor clearColor];
        
        UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hide)];
        self.backgroundView = [[UIView alloc] initWithFrame:self.frame];
        self.backgroundView.alpha = 0;
        self.backgroundView.backgroundColor = [UIColor blackColor];
        [self.backgroundView addGestureRecognizer:tapGestureRecognizer];
        [self addSubview:self.backgroundView];
        
        [self initContentView];
    }
    
    return self;
}

- (void)initContentView
{
    contentViewWidth = 290 * self.frame.size.width / 320;
    contentViewHeight = 0;
    
    self.contentView = [[UIView alloc] init];
    self.contentView.backgroundColor = [UIColor clearColor];
    
    self.buttonView = [[UIView alloc] init];
    self.buttonView.backgroundColor = [UIColor whiteColor];
    
    [self initTitle];
    [self initButtons];
    [self initCancelButton];
    
    self.contentView.frame = CGRectMake((self.frame.size.width - contentViewWidth ) / 2, self.frame.size.height, contentViewWidth, contentViewHeight);
    [self addSubview:self.contentView];
}

- (void)initTitle
{
    if(self.title != nil && ![self.title isEqualToString:@""])
    {
        self.titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, contentViewWidth, 50)];
        self.titleLabel.backgroundColor = [UIColor whiteColor];
        self.titleLabel.textAlignment = NSTextAlignmentCenter;
        self.titleLabel.textColor = [UIColor blackColor];
        self.titleLabel.font = [UIFont systemFontOfSize:TITLE_FONT_SIZE];
        self.titleLabel.text = _title;
        
        [self.buttonView addSubview:self.titleLabel];
        contentViewHeight += self.titleLabel.frame.size.height;
    }
}

- (void)initButtons
{
    if(self.buttonTitleArray.count > 0)
    {
        UIImage *buttonBgImageH = [UIImage imageNamed:@"common_buttonBackgroundH"];
        buttonBgImageH = [buttonBgImageH resizableImageWithCapInsets:UIEdgeInsetsMake(1, 1, 1, 1) resizingMode:UIImageResizingModeStretch];
        UIImage *buttonBgImage = [UIImage imageNamed:@"common_buttonBackground"];
        buttonBgImage = [buttonBgImage resizableImageWithCapInsets:UIEdgeInsetsMake(1, 1, 1, 1) resizingMode:UIImageResizingModeStretch];
        
        for(int i = 0; i < self.buttonTitleArray.count; i++)
        {
            UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(0, contentViewHeight, contentViewWidth, 1)];
            lineView.backgroundColor = [UIColor colorWithHex:0xe7e7e7];
            
            [self.buttonView addSubview:lineView];
            
            UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(0, contentViewHeight + 1, contentViewWidth, 44)];
            [button setBackgroundImage:buttonBgImageH forState:UIControlStateHighlighted];
            [button setBackgroundImage:buttonBgImage forState:UIControlStateNormal];
            button.titleLabel.font = [UIFont systemFontOfSize:18];
            [button setTitle:_buttonTitleArray[i] forState:UIControlStateNormal];
            [button setTitleColor:[UIColor colorWithHex:0xdfdfdf] forState:UIControlStateNormal];
            
            [button addTarget:self action:@selector(buttonPressed:) forControlEvents:UIControlEventTouchUpInside];
            
            [self.buttonArray addObject:button];
            [self.buttonView addSubview:button];
            
            contentViewHeight += lineView.frame.size.height + button.frame.size.height;
        }
        
        self.buttonView.frame = CGRectMake(0, 0, contentViewWidth, contentViewHeight);
        self.buttonView.layer.cornerRadius = 3.0;
        self.buttonView.layer.masksToBounds = YES;
        
        [self.contentView addSubview:self.buttonView];
    }
}

- (void)initCancelButton
{
    if(self.cancelButtonTitle != nil)
    {
        UIImage *buttonBgImageH = [UIImage imageNamed:@"common_buttonBackgroundH"];
        buttonBgImageH = [buttonBgImageH resizableImageWithCapInsets:UIEdgeInsetsMake(1, 1, 1, 1) resizingMode:UIImageResizingModeStretch];
        UIImage *buttonBgImage = [UIImage imageNamed:@"common_buttonBackground"];
        buttonBgImage = [buttonBgImage resizableImageWithCapInsets:UIEdgeInsetsMake(1, 1, 1, 1) resizingMode:UIImageResizingModeStretch];
        
        self.cancelButton = [[UIButton alloc] initWithFrame:CGRectMake(0, contentViewHeight + SPACE_SMALL, contentViewWidth, 44)];
        [self.cancelButton setBackgroundImage:buttonBgImageH forState:UIControlStateHighlighted];
        [self.cancelButton setBackgroundImage:buttonBgImage forState:UIControlStateNormal];
        self.cancelButton.titleLabel.font = [UIFont systemFontOfSize:18];
        self.cancelButton.layer.cornerRadius = 5.0;
        self.cancelButton.layer.masksToBounds = YES;
        [self.cancelButton setTitle:self.cancelButtonTitle forState:UIControlStateNormal];
        [self.cancelButton setTitleColor:[UIColor colorWithHex:0xf82222] forState:UIControlStateNormal];
        [self.cancelButton addTarget:self action:@selector(cancelButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:self.cancelButton];
        contentViewHeight += SPACE_SMALL + self.cancelButton.frame.size.height + SPACE_SMALL;
    }
}

- (void)setTitle:(NSString *)title
{
    _title = title;
    [self initContentView];
}

- (void)setCancelButtonTitle:(NSString *)cancelButtonTitle
{
    _cancelButtonTitle = cancelButtonTitle;
    [_cancelButton setTitle:cancelButtonTitle forState:UIControlStateNormal];
}

- (void)show
{
    UIWindow *window = [[UIApplication sharedApplication].windows objectAtIndex:0];
    [window addSubview:self];
    [self addAnimation];
}

- (void)hide
{
    [self removeAnimation];
}

- (void)setTitleColor:(UIColor *)color fontSize:(CGFloat)size
{
    if(color != nil)
    {
        _titleLabel.textColor = color;
    }
    
    if(size > 0)
    {
        _titleLabel.font = [UIFont systemFontOfSize:size];
    }
}

- (void)setButtonTitleColor:(UIColor *)color bgColor:(UIColor *)bgcolor fontSize:(CGFloat)size atIndex:(int)index
{
    UIButton *button = _buttonArray[index];
    if(color != nil)
    {
        [button setTitleColor:color forState:UIControlStateNormal];
    }
    
    if(bgcolor != nil)
    {
        [button setBackgroundColor:bgcolor];
    }
    
    if(size > 0)
    {
        button.titleLabel.font = [UIFont systemFontOfSize:size];
    }
}

- (void)setCancelButtonTitleColor:(UIColor *)color bgColor:(UIColor *)bgcolor fontSize:(CGFloat)size
{
    if(color != nil)
    {
        [_cancelButton setTitleColor:color forState:UIControlStateNormal];
    }
    
    if(bgcolor != nil)
    {
        [_cancelButton setBackgroundColor:bgcolor];
    }
    
    if(size > 0)
    {
        _cancelButton.titleLabel.font = [UIFont systemFontOfSize:size];
    }
}

- (void)addAnimation
{
    [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        self.contentView.frame = CGRectMake(self.contentView.frame.origin.x, self.frame.size.height - self.contentView.frame.size.height, self.contentView.frame.size.width, self.contentView.frame.size.height);
        self.backgroundView.alpha = 0.4;
    } completion:^(BOOL finished) {
    }];
}

- (void)removeAnimation
{
    [UIView animateWithDuration:0.3 delay:0 options: UIViewAnimationOptionCurveEaseOut animations:^{
        self.contentView.frame = CGRectMake(self.contentView.frame.origin.x, self.frame.size.height, self.contentView.frame.size.width, self.contentView.frame.size.height);
        self.backgroundView.alpha = 0;
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
}

- (void)buttonPressed:(UIButton *)button
{
    if(self.delegate && [self.delegate respondsToSelector:@selector(actionSheet:clickedButtonIndex:)])
    {
        for(int i = 0; i < self.buttonArray.count; i++)
        {
            if(button == self.buttonArray[i])
            {
                [self.delegate actionSheet:self clickedButtonIndex:i];
                break;
            }
        }
    }
    [self hide];
}

- (void)cancelButtonPressed:(UIButton *)button
{
    if(self.delegate && [self.delegate respondsToSelector:@selector(actionSheetCancel:)])
    {
        [self.delegate actionSheetCancel:self];
    }
    
    [self hide];
}

- (NSString *)buttonTitleAtIndex:(NSInteger)buttonIndex
{
    if(buttonIndex < 0
       || buttonIndex >= self.buttonArray.count)
    {
        return nil;
    }

    if(self.buttonArray.count <= 0)
    {
        return nil;
    }
    
    UIButton *button = [self.buttonArray objectAtIndex:buttonIndex];
    NSString *buttonTitle = button.titleLabel.text;
    
    return buttonTitle;
}

@end
