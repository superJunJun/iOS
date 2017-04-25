//
//  TYDEnrollViewController.h
//  
//   Dorikids
//
//  Created by macMini_Dev on 15-8-20.
//
//  用户注册
//

#import "BaseScrollController.h"

@protocol TYDEnrollViewControllerDelegate <NSObject>
@optional
- (void)enrollSucceed:(NSString *)account password:(NSString *)password;
@end

@interface TYDEnrollViewController : BaseScrollController

@property (assign, nonatomic) id<TYDEnrollViewControllerDelegate> delegate;

@end
