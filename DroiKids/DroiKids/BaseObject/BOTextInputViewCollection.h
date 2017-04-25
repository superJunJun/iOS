//
//  BOTextInputViewCollection.h
//
//  文本输入控件UITextField、UITextView的管理类
//

#import <Foundation/Foundation.h>

@interface BOTextInputViewCollection : NSObject

- (instancetype)init;
- (NSArray *)allTextInputViews;
- (void)appendTextInputViewsWithArray:(NSArray *)textInputViews;
- (void)appendOneTextInputView:(id)textInputView;
- (id)firstResponderTextInputView;
- (void)allTextInputViewsResignFirstResponder;
- (void)textInputViewBecomeFirstResponder:(id)textInputView;
- (void)allTextInputViewsTextClear;
- (NSUInteger)indexOfObject:(id)object;
- (id)objectInTextInputViewsAtIndex:(NSUInteger)index;
- (void)nextTextInputViewBecomeFirstResponder:(id)currentFirstResponderTextInputView;
- (BOOL)containObject:(id)object;
- (BOOL)isEmpty;
- (CGFloat)textInputViewBottomLine:(id)textInputView;

@end
