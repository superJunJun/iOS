//
//  TYDBabyDetailView.m
//  DroiKids
//
//  Created by superjunjun on 15/9/11.
//  Copyright (c) 2015年 TYDTech. All rights reserved.
//

#import "TYDBabyDetailView.h"
#import "TYDDataCenter.h"
#import <AVFoundation/AVFoundation.h>

#define RADIUS              5.
#define ACEHEIGHT           8.
#define CELLHEIGHT          60
#define VIEWWIDTH           200 * [UIScreen mainScreen].bounds.size.width / 320

@interface TYDBabyDetailCell : UITableViewCell

//+ (CGFloat)cellHeight;

@end

@implementation TYDBabyDetailCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if(self = [super initWithStyle:style reuseIdentifier:reuseIdentifier])
    {
        self.selectionStyle = UITableViewCellSelectionStyleGray;
        self.separatorInset = UIEdgeInsetsMake(0, -40, 0, 0);
        self.textLabel.font = [BOAssistor defaultTextStringFontWithSize:14];
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    self.imageView.size = CGSizeMake(40, 40);
    self.imageView.center = CGPointMake(30, 30);
    self.imageView.layer.cornerRadius = 20;
    self.imageView.layer.masksToBounds = YES;
    self.textLabel.left = self.imageView.right + 10;
    [self insertSubview:self.accessoryView atIndex:0];
}

@end



@implementation TYDBabyDetailView

- (id)initWithkidInfoArray:(NSArray *)array
{
    self = [super init];
    if(self)
    {
        self.backgroundColor = [UIColor clearColor];
        self.kidInfoArray = array;
        self.width = VIEWWIDTH;
        self.height = array.count >= 5?(CELLHEIGHT *array.count):(CELLHEIGHT * (array.count + 1));
        UITableView *tableView = [UITableView new];
        tableView.top = ACEHEIGHT;
        tableView.width = VIEWWIDTH;
        tableView.height = array.count * CELLHEIGHT;
        tableView.delegate = self;
        tableView.dataSource = self;
        tableView.layer.cornerRadius = RADIUS;
        [tableView.layer masksToBounds];
        [self addSubview:tableView];
        if(array.count < 5)
        {
            UIButton *addButton = [UIButton new];
            addButton.top = tableView.bottom;
            addButton.height = CELLHEIGHT;
            addButton.width = VIEWWIDTH;
            addButton.layer.cornerRadius = RADIUS;
            [addButton.layer masksToBounds];
            addButton.backgroundColor = [UIColor whiteColor];
            [addButton setTitle:@"添加宝贝" forState:UIControlStateNormal];
            [addButton setImage:[UIImage imageNamed:@"main_addButton_icon"] forState:UIControlStateNormal];
            [addButton setTitleEdgeInsets:UIEdgeInsetsMake(0, 10, 0, 0)];
            [addButton setImageEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 0)];
            [addButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
            [addButton addTarget:self action:@selector(addBabyButtonClick:) forControlEvents:UIControlEventTouchUpInside];
            [self addSubview:addButton];
        }
    }
    return self;
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
#pragma mark - DrawDrawDraw
- (void)drawRect:(CGRect)rect
{
    float width = rect.size.width;
    float height = rect.size.height;
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetStrokeColorWithColor(context, [UIColor whiteColor].CGColor);
    CGContextBeginPath(context);
    CGContextMoveToPoint(context, RADIUS, ACEHEIGHT);
    CGContextAddLineToPoint(context, VIEWWIDTH / 2 - ACEHEIGHT, ACEHEIGHT);
    CGContextAddLineToPoint(context, VIEWWIDTH / 2, 0);
    CGContextAddLineToPoint(context, VIEWWIDTH / 2 + ACEHEIGHT, ACEHEIGHT);
    CGContextAddArcToPoint(context, width, ACEHEIGHT, width, ACEHEIGHT + RADIUS, RADIUS);
    CGContextAddArcToPoint(context, width, height, width - RADIUS, height, RADIUS);
    CGContextAddArcToPoint(context, 0, height, 0, height - RADIUS - ACEHEIGHT, RADIUS);
    CGContextAddArcToPoint(context, 0, ACEHEIGHT, RADIUS, ACEHEIGHT, RADIUS);
    [[UIColor whiteColor] setFill];
    CGContextClosePath(context);
    CGContextDrawPath(context, kCGPathFillStroke);
}

- (void)setIsNoticeOn:(BOOL)isNoticeOn
{
    if(isNoticeOn)
    {
        // 添加图片
    }
    //    if(self.isNoticeOn != isNoticeOn)
    //    {
    //        _checkIconVisible = checkIconVisible;
    //        self.checkIcon.hidden = !checkIconVisible;
    //    }
}

- (void)setIsSlected:(BOOL)isSlected
{
    if(isSlected)
    {
        //选中的话，视图变大
    }
}

#pragma mark - Touch Event

- (void)addBabyButtonClick:(UIButton *)sender
{
    dispatch_semaphore_t sema = dispatch_semaphore_create(0);
    [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
        dispatch_semaphore_signal(sema);
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if(granted)
            {
                if([self.delegate respondsToSelector:@selector(addBaby)])
                {
                    [self.delegate addBaby];
                }
            }
            else
            {
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"相机设置" message:@"请在设置中允许应用使用相机选项" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
                
                [alertView show];
            }
        });
    }];
    
    dispatch_semaphore_wait(sema, DISPATCH_TIME_FOREVER);
}

#pragma mark - UITableViewDelegate

- (NSInteger )tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.kidInfoArray.count;
}

//- (NSInteger )tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index
//{
//    return 1;
//}
//
//- (CGFloat )tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
//{
//    return 60;
//}

- (CGFloat )tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return CELLHEIGHT;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    TYDBabyDetailCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if(!cell)
    {
        cell = [[TYDBabyDetailCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
    }
    TYDKidInfo *kidInfo = self.kidInfoArray[indexPath.row];
    if(kidInfo.kidAvatarPath.length > 0)
    {
        if(kidInfo.kidGender.integerValue == TYDKidGenderTypeBoy)
        {
            NSURL *avatarUrl = [[NSURL alloc]initWithString:kidInfo.kidAvatarPath];
            [cell.imageView setImageWithURL:avatarUrl placeholderImage:[UIImage imageNamed:@"main_left_babyMale"]];
        }
        else
        {
            NSURL *avatarUrl = [[NSURL alloc]initWithString:kidInfo.kidAvatarPath];
            [cell.imageView setImageWithURL:avatarUrl placeholderImage:[UIImage imageNamed:@"main_left_babyFemale"]];
        }
    }
    else if(kidInfo.kidGender.integerValue == TYDKidGenderTypeBoy)
    {
        cell.imageView.image = [UIImage imageNamed:@"main_left_babyMale"];
    }
    else if(kidInfo.kidGender.integerValue == TYDKidGenderTypeGirl)
    {
        cell.imageView.image = [UIImage imageNamed:@"main_left_babyFemale"];
    }
    cell.textLabel.text = kidInfo.kidName;
    NSString *kidID = [[TYDDataCenter defaultCenter]currentKidInfo].kidID;
    if([[self.kidInfoArray[indexPath.row] kidID] isEqualToString:kidID])
    {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"didSelectRowAtIndexPath");
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    [TYDDataCenter defaultCenter].currentKidInfo = self.kidInfoArray[indexPath.row];
    if([self.delegate respondsToSelector:@selector(switchBaby:)])
    {
        [self.delegate switchBaby:[self.kidInfoArray[indexPath.row] kidName]];
    }
}

@end
