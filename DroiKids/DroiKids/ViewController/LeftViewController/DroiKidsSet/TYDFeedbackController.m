//
//  TYDFeedbackController.m
//  DroiKids
//
//  Created by caiyajie on 15/8/14.
//  Copyright (c) 2015年 superjunjun. All rights reserved.
//

#import "TYDFeedbackController.h"
#import "TYDActionSheet.h"
#import "TYDDataCenter.h"
#import "GTMBase64.h"

#define  nTextfieldMaxLength         100

@interface TYDFeedbackController ()<UITextViewDelegate,UINavigationControllerDelegate,UIImagePickerControllerDelegate,TYDActionSheetDelegate>

@property (strong, nonatomic) UILabel               *placeholderLabel;
@property (strong, nonatomic) UILabel               *limitWordLabel;
@property (strong, nonatomic) UITextView            *opinionTextView;
@property (strong, nonatomic) UIView                *addPictureView;
@property (strong, nonatomic) UIButton              *addPictureButton;
@property (strong, nonatomic) UIButton              *sendOutButton;
@property (strong, nonatomic) NSMutableArray        *pictureArray;
@property (strong, nonatomic) NSMutableArray        *selectQuestionArray;
@property (nonatomic)         NSInteger             selectImageIndex;
@property (assign)            BOOL                  isModifyEvent;
@property (nonatomic)         NSInteger             questionBtnSelectIndex;

@end

@implementation TYDFeedbackController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self localDataInitialize];
    [self navigationBarItemsLoad];
    [self subviewsLoad];
}

- (void)localDataInitialize
{
    self.pictureArray = [NSMutableArray new];
    self.selectQuestionArray = [NSMutableArray new];
    self.selectImageIndex = -1;
    self.isModifyEvent = NO;
    self.selectImageIndex = -1;
}

- (void)navigationBarItemsLoad
{
    self.title = @"意见反馈";
}

- (void)subviewsLoad
{
    [self titleViewLoad];
    [self opinionTextFieldLoad];
    [self sendOutButtonLoad];
}

- (void)titleViewLoad
{
    CGRect frame = self.view.bounds;
    frame.size.height = 160;
    
    UIControl *baseView = [[UIControl alloc]initWithFrame:frame];
    baseView.backgroundColor = [UIColor clearColor];
    [self.baseView addSubview:baseView];
    [baseView addTarget:self action:@selector(tapOnSpace:) forControlEvents:UIControlEventTouchUpInside];
    self.baseViewBaseHeight = baseView.bottom;
    
    UILabel *questionTypeLabel = [UILabel new];
    questionTypeLabel.text = @"问题类型";
    questionTypeLabel.font = [BOAssistor defaultTextStringFontWithSize:12];
    questionTypeLabel.backgroundColor = [UIColor clearColor];
    questionTypeLabel.textColor = [UIColor colorWithHex:0xaaaaaa];
    [questionTypeLabel sizeToFit];
    questionTypeLabel.top = 8;
    questionTypeLabel.left = 17;
    [baseView addSubview:questionTypeLabel];
    
    NSArray *titleArray = @[@"功能建议", @"功能问题", @"界面问题", @"其他"];
    for(NSInteger i = 0; i < 4; i++)
    {
        UIButton *button = [[UIButton alloc] initWithImageName:@"appSet_selectquestion" highlightedImageName:@"appSet_selectquestionH" capInsets:UIEdgeInsetsMake(10, 10, 10, 10) givenButtonSize:CGSizeMake(103, 33) title:titleArray[i] titleFont:[BOAssistor defaultTextStringFontWithSize:18] titleColor:[UIColor blackColor]];
        button.left = i % 2 == 0 ?  17 : button.width + 52;
        button.top = i / 2 == 0 ? questionTypeLabel.bottom + 21 : questionTypeLabel.bottom + 18 + button.height + 21;
        [baseView addSubview:button];
        [button addTarget:self action:@selector(selectQuestionButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        UIImage *image = [UIImage imageNamed:@"appSet_selectquestionH"];
        image = [image resizableImageWithCapInsets:UIEdgeInsetsMake(10, 10, 10, 10) resizingMode:UIImageResizingModeStretch];
        [button setBackgroundImage:image forState:UIControlStateSelected];
        if(i == 0)
        {
            button.selected = YES;
        }
        [self.selectQuestionArray addObject:button];
    }
}

- (void)opinionTextFieldLoad
{
    UIView *baseView = [[UIView alloc]initWithFrame:CGRectMake(17, self.baseViewBaseHeight,self.view.width - 34, 10)];
    baseView.backgroundColor = [UIColor whiteColor];
    [self.baseView addSubview:baseView];
    
    UITextView *opinionTextView = [[UITextView alloc]initWithFrame:CGRectMake(5, 0, baseView.width - 10, 65)];
    opinionTextView.delegate = self;
    opinionTextView.backgroundColor = [UIColor clearColor];
    opinionTextView.textColor = [UIColor blackColor];
    opinionTextView.font = [UIFont fontWithName:@"Arial" size:12];
//    opinionTextView.autocorrectionType = UITextAutocorrectionTypeNo;
//    opinionTextView.autocapitalizationType = UITextAutocapitalizationTypeNone;
//    opinionTextView.keyboardType = UIKeyboardTypeDefault;
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(textViewEditChanged:) name:@"UITextViewTextDidChangeNotification" object:opinionTextView];
    
    UILabel *placeholderLabel = [UILabel new];
    placeholderLabel.backgroundColor = [UIColor clearColor];
    placeholderLabel.text = @"在此输入您的意见 ,我们会真诚聆听和反思.";
    placeholderLabel.textColor = [UIColor blackColor];
    placeholderLabel.font = [BOAssistor defaultTextStringFontWithSize:12];
    placeholderLabel.frame = CGRectMake(3, 1, 300, 30);
    placeholderLabel.enabled = NO;
    [opinionTextView addSubview:placeholderLabel];
    
    [baseView addSubview:opinionTextView];
    [self.textInputViews appendOneTextInputView:opinionTextView];
    
    self.placeholderLabel = placeholderLabel;
    self.opinionTextView = opinionTextView;
    
    UIView *addPictureView = [UIView new];
    addPictureView.size = CGSizeMake(baseView.width, 40);
    addPictureView.center = baseView.innerCenter;
    addPictureView.top = self.opinionTextView.bottom;
    
    UIButton *addPictureButton = [UIButton buttonWithType:UIButtonTypeCustom];
    addPictureButton.backgroundColor = [UIColor lightGrayColor];
    [addPictureButton setImage:[UIImage imageNamed:@"appSet_addPicture"] forState:UIControlStateNormal];
    [addPictureButton addTarget:self action:@selector(addPictureButtonEvent:) forControlEvents:UIControlEventTouchUpInside];
    addPictureButton.size = CGSizeMake(33, 33);
    addPictureButton.center = addPictureView.innerCenter;
    addPictureButton.left = 10;
    [baseView addSubview:addPictureView];
    [addPictureView addSubview:addPictureButton];
    
    UILabel *limitWordLabel = [UILabel new];
    limitWordLabel.backgroundColor = [UIColor clearColor];
    limitWordLabel.text = @"100";
    limitWordLabel.textColor = [UIColor colorWithHex:0xaaaaaa];
    limitWordLabel.font = [BOAssistor defaultTextStringFontWithSize:10];
    [limitWordLabel sizeToFit];
    limitWordLabel.right = addPictureView.width - 5;
    limitWordLabel.bottom = addPictureView.height;
    [addPictureView addSubview:limitWordLabel];
    self.limitWordLabel = limitWordLabel;
    
    self.addPictureView = addPictureView;
    self.addPictureButton = addPictureButton;
    baseView.height = addPictureView.bottom;
    [baseView.layer setCornerRadius:4];
    self.baseViewBaseHeight = baseView.bottom;
}

- (void)sendOutButtonLoad
{
    UIEdgeInsets capInsets = UIEdgeInsetsMake(10, 10, 10, 10);
    UIButton *sendOutButton = [[UIButton alloc] initWithImageName:@"appSet_sendEnable" highlightedImageName:@"appSet_sendBtnH" capInsets:capInsets givenButtonSize:CGSizeMake(self.view.width - 34, 40) title:@"提交" titleFont:[UIFont fontWithName:@"Arial" size:18] titleColor:[UIColor whiteColor]];
    [sendOutButton addTarget:self action:@selector(sendOutButtonEvent:) forControlEvents:UIControlEventTouchUpInside];
    sendOutButton.center = self.view.center;
    sendOutButton.bottom = self.view.bottom - 100;
    sendOutButton.enabled = NO;
    [self.baseView addSubview:sendOutButton];
    self.sendOutButton = sendOutButton;
    self.baseViewBaseHeight = sendOutButton.bottom;
}

#pragma mark - touchEvent

- (void)sendOutButtonEvent:(id)sender
{
    NSLog(@"发送反馈");
    UITextField *textField = [self.textInputViews objectInTextInputViewsAtIndex:0];
    NSString *feedText = textField.text;
    if(feedText.length == 0)
    {
        self.noticeText = @"请输入意见或建议";
        return;
    }
    
    NSMutableString *imageTotalString = [@"" mutableCopy];
    for(UIImage *image in self.pictureArray)
    {
        UIImage *imageMotifiy = [self resizeImage:image withQuality:kCGInterpolationDefault rate:0.1];
        NSData *imageData = UIImagePNGRepresentation(imageMotifiy);
        NSString *imageString = [GTMBase64 stringByEncodingData:imageData];
        [imageTotalString appendString:imageString];
        if([self.pictureArray indexOfObject:image] != (self.pictureArray.count - 1))
        {
            [imageTotalString appendString:@"|"];
        }
    }
    
    TYDKidInfo *kidInfo = [[TYDDataCenter defaultCenter] currentKidInfo];
    NSString *watchid = kidInfo.watchID;
    NSString *openID = [TYDUserInfo sharedUserInfo].openID;
    NSMutableDictionary *params = [NSMutableDictionary new];
    [params setValue:openID forKey:sPostUrlRequestUserOpenIDKey];
    [params setValue:feedText forKey:@"text"];
    [params setValue:watchid forKey:@"watchid"];
    [params setValue:imageTotalString forKey:@"imgs"];
    [self postURLRequestWithMessageCode:ServiceMsgCodeCommentCommit
                           HUDLabelText:nil
                                 params:params
                          completeBlock:^(id result) {
                              [self feedBackComplete:result];
                          }];
}

- (void)feedBackComplete:(id)result
{
    NSLog(@"feedBackComplete:%@",result);
    [self progressHUDHideImmediately];
    NSNumber *resultCode = result[@"result"];
    if(resultCode != nil
       && resultCode.intValue == 0)
    {
//         self.noticeText = @"提交成功";
         [self progressHUDShowWithCompleteText:@"提交成功" isSucceed:YES additionalTarget:self action:@selector(popBackEventWillHappen) object:nil];
    }
    else
    {
        self.noticeText = @"提交失败";
    }
}

- (UIImage *)resizeImage:(UIImage *)image
             withQuality:(CGInterpolationQuality)quality
                    rate:(CGFloat)rate
{
    UIImage *resized = nil;
    CGFloat width = image.size.width * rate;
    CGFloat height = image.size.height * rate;
    
    UIGraphicsBeginImageContext(CGSizeMake(width, height));
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetInterpolationQuality(context, quality);
    [image drawInRect:CGRectMake(0, 0, width, height)];
    resized = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return resized;
}

- (void)addPictureButtonEvent:(id)sender
{
    UIImagePickerController *imagePickerController = [UIImagePickerController new];
    imagePickerController.delegate = self;
    imagePickerController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    [self presentViewController:imagePickerController animated:YES completion:nil];
}

- (void)selectQuestionButtonAction:(id)sender
{
    [self.textInputViews allTextInputViewsResignFirstResponder];
    UIButton *selectButton = (UIButton *)sender;
    for(UIButton *button in self.selectQuestionArray)
    {
        button.selected  = NO;
    }
    selectButton.selected = YES;
    self.questionBtnSelectIndex = [self.selectQuestionArray indexOfObject:selectButton];
}

- (void)deleteButtonWithImageIndex:(NSInteger)index
{
    [self.addPictureView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    [self.pictureArray removeObjectAtIndex:index];
    
    self.addPictureButton.center = self.addPictureView.innerCenter;
    self.addPictureButton .left = 10;
    [self.addPictureView addSubview:self.addPictureButton];
    
    for(NSInteger i = 0; i < self.pictureArray.count; i++)
    {
        UIImage *pictureImage = self.pictureArray[i];
        UIImageView *pictureImageView = [UIImageView new];
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(pictureImageViewTap:)];
        pictureImageView.userInteractionEnabled = YES;
        [pictureImageView addGestureRecognizer:tap];
        pictureImageView.size = self.addPictureButton.size;
        pictureImageView.center = self.addPictureView.innerCenter;
        pictureImageView.left = self.addPictureButton.left;
        
        [pictureImageView setContentMode:UIViewContentModeScaleToFill];
        [pictureImageView setImage:pictureImage];
        [self.addPictureView addSubview:pictureImageView];
        self.addPictureButton.left = pictureImageView.right + 10;
    }
    self.addPictureButton.hidden = NO;
}

- (void)actionSheet:(TYDActionSheet *)sheet clickedButtonIndex:(NSInteger)buttonIndex
{
    NSString *buttonTitle = [sheet buttonTitleAtIndex:buttonIndex];
    if([buttonTitle isEqualToString:@"删除"])
    {
        [self deleteButtonWithImageIndex:self.selectImageIndex];
    }
    else if ([buttonTitle isEqualToString:@"更换图片"])
    {
        self.isModifyEvent = YES;
        [self addPictureButtonEvent:nil];
    }
}

- (void)pictureImageViewTap:(UITapGestureRecognizer *)sender
{
    UIImageView *pictureImageView = (UIImageView *)sender.view;
    UIImage *pictureImage = pictureImageView.image;
    NSInteger index = [self.pictureArray indexOfObject:pictureImage];
    self.selectImageIndex = index;
    NSArray *titleArray = @[@"更换图片", @"删除"];
    TYDActionSheet *actionSheet = [[TYDActionSheet alloc]initWithTitle:nil delegate:self cancelButtonTitle:@"取消" otherButtonTitles:titleArray];
    for(int i = 0; i < titleArray.count; i++)
    {
        [actionSheet setButtonTitleColor:[UIColor colorWithHex:0x686868] bgColor:nil fontSize:0 atIndex:i];
    }
    actionSheet.delegate = self;
    [actionSheet show];
}

#pragma mark - UIImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    UIImage *image = [info valueForKey:UIImagePickerControllerOriginalImage];
    if(picker.sourceType == UIImagePickerControllerSourceTypePhotoLibrary)
    {
    
    }
    if(self.isModifyEvent == YES)
    {
        self.isModifyEvent = NO;
        [self deleteButtonWithImageIndex:self.selectImageIndex];
    }
   
    //[BOAssistor sizeShow:image.size withTitle:@"image.size"];
    [picker dismissViewControllerAnimated:YES completion:nil];
    [self dismissPickerViewControllerEventWithImage:image];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    self.isModifyEvent = NO;
    [picker dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - SuspendEvent

- (void)dismissPickerViewControllerEventWithImage:(UIImage *)image
{
    [self.pictureArray addObject:image];
    [self localLayOut];
}

- (void)localLayOut
{
    UIImage *pictureImage = self.pictureArray[self.pictureArray.count - 1];
    UIImageView *pictureImageView = [UIImageView new];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(pictureImageViewTap:)];
    pictureImageView.userInteractionEnabled = YES;
    [pictureImageView addGestureRecognizer:tap];
    pictureImageView.size = self.addPictureButton.size;
    pictureImageView.center = self.addPictureView.innerCenter;
    pictureImageView.left = self.addPictureButton.left;

    [pictureImageView setContentMode:UIViewContentModeScaleToFill];
    [pictureImageView setImage:pictureImage];
    [self.addPictureView addSubview:pictureImageView];
    self.addPictureButton.left = pictureImageView.right + 10;
    if(self.pictureArray.count == 3)
    {
        self.addPictureButton.hidden = YES;
    }
}

#pragma mark - UITextViewDelegate

- (void)textViewDidEndEditing:(UITextView *)textView
{
    NSLog(@"textViewDidEndEditing");
    if (textView.text.length == 0)
    {
        self.placeholderLabel.hidden = NO;
    }
    else
    {
        self.placeholderLabel.hidden = YES;
    }
}

- (void)textViewDidChange:(UITextView *)textView
{
    NSLog(@"textViewDidChange");
    UIImage *imageNomal = [UIImage imageNamed:@"appSet_sendEnable"];
    imageNomal = [imageNomal resizableImageWithCapInsets:UIEdgeInsetsMake(10, 10, 10, 10) resizingMode:UIImageResizingModeStretch];
    UIImage *imageVisible = [UIImage imageNamed:@"appSet_sendBtn"];
    imageVisible = [imageVisible resizableImageWithCapInsets:UIEdgeInsetsMake(10, 10, 10, 10) resizingMode:UIImageResizingModeStretch];
   
    if (textView.text.length != 0 && self.questionBtnSelectIndex != -1)
    {
        self.placeholderLabel.hidden = YES;
        [self.sendOutButton setBackgroundImage:imageVisible forState:UIControlStateNormal];
        self.sendOutButton.enabled = YES;
    }
    else
    {
        self.placeholderLabel.hidden = NO;
        [self.sendOutButton setBackgroundImage:imageNomal forState:UIControlStateNormal];
        self.sendOutButton.enabled = NO;
    }
}

//- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
//{
//    NSString * toBeString = [textView.text stringByReplacingCharactersInRange:range withString:text];
//    NSLog(@"--------");
//    
//    if (toBeString.length > nTextfieldMaxLength && range.length != 1)
//    {
//        textView.text = [toBeString substringToIndex:nTextfieldMaxLength];
//        return NO;
//    }
//    return YES;
//}

-(void)textViewEditChanged:(NSNotification *)obj
{
    UITextView *textView = (UITextView *)obj.object;
    NSString *toBeString = textView.text;
    self.limitWordLabel.text = [NSString stringWithFormat:@"%u",(100 - toBeString.length)];
    if(toBeString.length > nTextfieldMaxLength)
    {
        textView.text = [toBeString substringToIndex:nTextfieldMaxLength];
        self.limitWordLabel.text = @"0";
    }
    self.limitWordLabel.right = self.addPictureView.width - 5;
    [self.limitWordLabel sizeToFit];
    
//    NSString *lang = [[UITextInputMode currentInputMode] primaryLanguage]; // 键盘输入模式
//    if ([lang isEqualToString:@"zh-Hans"])
//    { // 简体中文输入，包括简体拼音，健体五笔，简体手写
//        UITextRange *selectedRange = [textView markedTextRange];
//        //获取高亮部分
//        UITextPosition *position = [textView positionFromPosition:selectedRange.start offset:0];
//        // 没有高亮选择的字，则对已输入的文字进行字数统计和限制
//        if (!position)
//        {
//            if (toBeString.length > nTextfieldMaxLength)
//            {
//                textView.text = [toBeString substringToIndex:nTextfieldMaxLength];
//            }
//        }
//        // 有高亮选择的字符串，则暂不对文字进行统计和限制
//        else
//        {
//            
//        }
//    }
//    // 中文输入法以外的直接对其统计限制即可，不考虑其他语种情况
//    else
//    {
//        if (toBeString.length > nTextfieldMaxLength)
//        {
//            textView.text = [toBeString substringToIndex:nTextfieldMaxLength];
//        }
//    }
}

@end
