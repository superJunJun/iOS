//
//  TYDUserInfo.m
//

#import "TYDUserInfo.h"
#import "SBJson.h"

#define sUserIDKey                      @"userIDKey"
#define sUserOpenIDKey                  @"userOpenIDKey"
#define sUserNameKey                    @"usernameKey"
#define sUserPhoneNumberKey             @"phoneNumberKey"
#define sUserNicknameKey                @"nicknameKey"
#define sUserTypeKey                    @"userTypeKey"
#define sUserDescriptionKey             @"userDescriptionKey"

@interface TYDUserInfo ()

@end

@implementation TYDUserInfo

- (NSDictionary *)attributeMapDictionary
{
    NSDictionary *mapDic =
    @{
        @"userid"               :@"userID",
        @"openid"               :@"openID",
        @"phone"                :@"phoneNumber",
        @"username"             :@"username",
        @"nickname"             :@"nickname",
        @"type"                 :@"userType",
        @"description"          :@"userDescription",
    };
    return mapDic;
}

- (void)setAttributes:(NSDictionary *)dataDic
{
    [super setAttributes:dataDic];
    [self attributeFix];
}

- (void)attributeFix
{
    self.userID = [self stringValueFix:self.userID];
    self.openID = [self stringValueFix:self.openID];
    self.phoneNumber = [self stringValueFix:self.phoneNumber];
    self.username = [self stringValueFix:self.username];
    self.nickname = [self stringValueFix:self.nickname];
    self.userType = [self integerNumberValueFix:self.userType];
    self.userDescription = [self stringValueFix:self.userDescription];
}

- (void)logout
{
    [self userAttributeSetDefaultValue];
    //[self saveUserInfo];
}

- (BOOL)isUserAccountEnable
{
    return self.userID.length > 0;
}

- (void)userAttributeSetDefaultValue
{
    self.userID = nil;
    self.openID = nil;
    self.phoneNumber = @"";
    self.username = @"";
    self.nickname = @"";
    self.userType = @0;
    self.userDescription = @"";
}

//- (void)saveUserInfo
//{
//    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
//    NSMutableDictionary *userInfoDic = [NSMutableDictionary new];
//    
//    [userInfoDic setValue:self.userID forKey:sUserIDKey];
//    [userInfoDic setValue:self.openID forKey:sUserOpenIDKey];
//    [userInfoDic setValue:self.phoneNumber forKey:sUserPhoneNumberKey];
//    [userInfoDic setValue:self.username forKey:sUserNameKey];
//    [userInfoDic setValue:self.nickname forKey:sUserNicknameKey];
//    [userInfoDic setValue:self.userType forKey:sUserTypeKey];
//    [userInfoDic setValue:self.userDescription forKey:sUserDescriptionKey];
//    
//    [userDefaults setObject:userInfoDic forKey:sUserInfoDicKey];
//    [userDefaults synchronize];
//}
//
//- (void)readUserInfo
//{
//    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
//    NSDictionary *userInfoDic = [userDefaults objectForKey:sUserInfoDicKey];
//    if(userInfoDic[sUserIDKey] != nil)
//    {
//        self.userID = userInfoDic[sUserIDKey];
//        self.openID = userInfoDic[sUserOpenIDKey];
//        self.phoneNumber = userInfoDic[sUserPhoneNumberKey];
//        self.username = userInfoDic[sUserNameKey];
//        self.nickname = userInfoDic[sUserNicknameKey];
//        self.userType = userInfoDic[sUserTypeKey];
//        self.userDescription = userInfoDic[sUserDescriptionKey];
//    }
//    else
//    {
//        [self userAttributeSetDefaultValue];
//        [self saveUserInfo];
//    }
//}

#pragma mark - SingleTon

- (instancetype)init
{
    if(self = [super init])
    {
        //[self readUserInfo];
        [self userAttributeSetDefaultValue];
    }
    return self;
}

+ (instancetype)sharedUserInfo
{
    static TYDUserInfo *sharedUserInfoInstance = nil;
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
        sharedUserInfoInstance = [[self alloc] init];
    });
    return sharedUserInfoInstance;
}

@end
