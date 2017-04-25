//
//  BOTextInputViewCollection.m
//
//  文本输入控件UITextField、UITextView的管理类
//

#import "BOTextInputViewCollection.h"

@interface BOTextInputViewCollection ()

@property (strong, nonatomic) NSMutableArray *textInputViews;

@end

@implementation BOTextInputViewCollection

- (instancetype)init
{
    if(self = [super init])
    {
        self.textInputViews = [NSMutableArray new];
    }
    return self;
}

- (NSArray *)allTextInputViews
{
    return [self.textInputViews copy];
}

- (void)appendTextInputViewsWithArray:(NSArray *)textInputViews
{
    for(id obj in textInputViews)
    {
        [self appendOneTextInputView:obj];
    }
}

- (void)appendOneTextInputView:(id)textInputView
{
    if([self.textInputViews containsObject:textInputView]
       || !([textInputView isKindOfClass:UITextField.class]
            || [textInputView isKindOfClass:UITextView.class]))
    {
        return;
    }
    [self.textInputViews addObject:textInputView];
}

- (id)firstResponderTextInputView
{
    for(id textInputView in self.textInputViews)
    {
        if([textInputView isFirstResponder])
        {
            return textInputView;
        }
    }
    return nil;
}

- (void)allTextInputViewsResignFirstResponder
{
    [self.firstResponderTextInputView resignFirstResponder];
}

- (void)textInputViewBecomeFirstResponder:(id)textInputView
{
    id firstResponderTextInputView = self.firstResponderTextInputView;
    if(textInputView != firstResponderTextInputView)
    {
        [firstResponderTextInputView resignFirstResponder];
        [textInputView becomeFirstResponder];
    }
}

- (void)allTextInputViewsTextClear
{
    for(id textInputView in self.textInputViews)
    {
        if([textInputView isKindOfClass:UITextField.class])
        {
            UITextField *textField = textInputView;
            textField.text = @"";
        }
        else if([textInputView isKindOfClass:UITextView.class])
        {
            UITextView *textView = textInputView;
            textView.text = @"";
        }
    }
}

- (NSUInteger)indexOfObject:(id)object
{
    return [self.textInputViews indexOfObject:object];
}

- (id)objectInTextInputViewsAtIndex:(NSUInteger)index
{
    id object = nil;
    if(index < self.textInputViews.count)
    {
        object = self.textInputViews[index];
    }
    return object;
}

- (void)nextTextInputViewBecomeFirstResponder:(id)object
{
    if([self containObject:object])
    {
        [self textInputViewBecomeFirstResponder:[self objectInTextInputViewsAtIndex:[self indexOfObject:object] + 1]];
    }
}

- (BOOL)containObject:(id)object
{
    return [self.textInputViews containsObject:object];
}

- (BOOL)isEmpty
{
    return (self.textInputViews.count == 0);
}

- (CGFloat)textInputViewBottomLine:(id)textInputView
{
    CGRect frame = CGRectZero;
    if([textInputView isKindOfClass:UITextView.class])
    {
        UITextView *textView = textInputView;
        frame = [textView caretRectForPosition:textView.selectedTextRange.end];
    }
    else if([textInputView isKindOfClass:UIView.class])
    {
        UIView *view = textInputView;
        frame = view.bounds;
    }
    return frame.origin.y + frame.size.height;
}

@end
