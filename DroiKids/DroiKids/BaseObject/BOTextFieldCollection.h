//
//  BOTextFieldCollection.h
//
//  UITextField管理类
//

#import <Foundation/Foundation.h>

@interface BOTextFieldCollection : NSObject

- (instancetype)init;
- (NSArray *)allTextFields;
- (void)appendTextFieldsWithArray:(NSArray *)textFields;
- (void)appendOneTextField:(UITextField *)textField;
- (UITextField *)firstResponderTextField;
- (void)allTextFieldsResignFirstResponder;
- (void)textFieldBecomeFirstResponder:(UITextField *)textField;
- (void)allTextFieldsTextClear;
- (NSUInteger)indexOfObject:(id)object;
- (UITextField *)objectInTextFieldsAtIndex:(NSUInteger)index;
- (void)nextTextFieldBecomeFirstResponder:(id)currentFirstResponderTextField;
- (BOOL)containObject:(id)object;
- (BOOL)isEmpty;

@end
