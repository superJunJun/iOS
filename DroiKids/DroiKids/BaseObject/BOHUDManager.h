//
//  BOHUDManager.h
//

#import <Foundation/Foundation.h>

@interface BOHUDManager : NSObject

+ (instancetype)defaultManager;

- (void)progressHUDShowWithText:(NSString *)text;
- (void)progressHUDShowWithCompleteText:(NSString *)text isSucceed:(BOOL)isSucceed;
- (void)progressHUDMomentaryShowWithTarget:(id)target action:(SEL)action object:(id)object;
- (void)progressHUDMomentaryShowWithText:(NSString *)text target:(id)target action:(SEL)action object:(id)object;
- (void)progressHUDShowWithCompleteText:(NSString *)text isSucceed:(BOOL)isSucceed additionalTarget:(id)target action:(SEL)action object:(id)object;
- (void)progressHUDHideImmediately;

@end
