//
//  TYDUserInfo.h
//

#import "TYDBaseModel.h"
#import "TYDKidInfo.h"

@interface TYDUserInfo : TYDBaseModel

@property (strong, nonatomic) NSString *openID;
@property (strong, nonatomic) NSString *userID;
@property (strong, nonatomic) NSString *phoneNumber;
@property (strong, nonatomic) NSString *username;
@property (strong, nonatomic) NSString *nickname;
@property (strong, nonatomic) NSNumber *userType;
@property (strong, nonatomic) NSString *userDescription;

+ (instancetype)sharedUserInfo;
- (void)logout;
- (BOOL)isUserAccountEnable;
//- (void)saveUserInfo;

@end
