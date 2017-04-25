//
//  BOTextFieldCollection.m
//
//  UITextField管理类
//
//textInputViews
#import "BOTextFieldCollection.h"

@interface BOTextFieldCollection ()

@property (strong, nonatomic) NSMutableArray *textFields;

@end

@implementation BOTextFieldCollection

- (instancetype)init
{
    if(self = [super init])
    {
        self.textFields = [NSMutableArray new];
    }
    return self;
}

- (NSArray *)allTextFields
{
    return [self.textFields copy];
}

- (void)appendTextFieldsWithArray:(NSArray *)textFields
{
    for(id obj in textFields)
    {
        if([obj isKindOfClass:UITextField.class])
        {
            [self appendOneTextField:obj];
        }
    }
}

- (void)appendOneTextField:(UITextField *)textField
{
    if(![self.textFields containsObject:textField])
    {
        [self.textFields addObject:textField];
    }
}

- (UITextField *)firstResponderTextField
{
    for(UITextField *textField in self.textFields)
    {
        if([textField isFirstResponder])
        {
            return textField;
        }
    }
    return nil;
}

- (void)allTextFieldsResignFirstResponder
{
    [self.firstResponderTextField resignFirstResponder];
}

- (void)textFieldBecomeFirstResponder:(UITextField *)textField
{
    UITextField *firstResponderTextField = self.firstResponderTextField;
    if(textField != firstResponderTextField)
    {
        [firstResponderTextField resignFirstResponder];
        [textField becomeFirstResponder];
    }
}

- (void)allTextFieldsTextClear
{
    for(UITextField *textField in self.textFields)
    {
        textField.text = @"";
    }
}

- (NSUInteger)indexOfObject:(id)object
{
    return [self.textFields indexOfObject:object];
}

- (UITextField *)objectInTextFieldsAtIndex:(NSUInteger)index
{
    id object = nil;
    if(index < self.textFields.count)
    {
        object = self.textFields[index];
    }
    return object;
}

- (void)nextTextFieldBecomeFirstResponder:(id)object
{
    if([self containObject:object])
    {
        [[self objectInTextFieldsAtIndex:[self indexOfObject:object] + 1] becomeFirstResponder];
    }
}

- (BOOL)containObject:(id)object
{
    return [self.textFields containsObject:object];
}

- (BOOL)isEmpty
{
    return (self.textFields.count == 0);
}

@end
