//
//  ServerUrlInfoDefines.h
//

#ifndef __ServerUrlInfoDefines_H__
#define __ServerUrlInfoDefines_H__

/*
 -------------------------------------
 公用常量
 -------------------------------------
 */

#define sNetworkError               @"网络连接错误"
#define sNetworkFailed              @"网络掉线，请在确认网络链接状态后重试"
#define sNetworkTimeout             @"网络连接超时"
#define sVCodeRequestComplete       @"请求已发送，请注意查收验证码信息"


#define sPostHttpMethodName         @"POST"
#define sGetHttpMethodName          @"GET"

/*
 -------------------------------------
 DroiKids项目服务器相关
 -------------------------------------
 */

#define sPostUrlRequestUserAcountKey            @"userid"
#define sPostUrlRequestUserOpenIDKey            @"openid"

typedef void(^PostUrlRequestCompleteBlock)(id result);
typedef void(^PostUrlRequestFailedBlock)(NSUInteger msgCode, id result);

typedef NS_ENUM(NSUInteger, ServiceMsgCode)
{
    ServiceMsgCodeNone = 0,
    ServiceMsgCodeGuardianInfoUpdate        =  102011,//监护人信息保存
    ServiceMsgCodeGuardianInfoRequest       =  102012,//监护人信息获取
    ServiceMsgCodeKidListInfoDownload       =  102013,//儿童列表信息获取
    ServiceMsgCodeKidContactAdd             =  102014,//儿童通讯录号码添加
    ServiceMsgCodeKidContactDelete          =  102032,//管理员删除通讯录联系人
    ServiceMsgCodeKidContactRequest         =  102015,//儿童通讯录获取
    ServiceMsgCodeBindWatchNormal           =  102016,//普通用户绑定手表
    ServiceMsgCodeUnbindWatchNormal         =  102018,//普通用户解绑手表
    ServiceMsgCodeBindWatchAdmin            =  102017,//管理员绑定手表
    ServiceMsgCodeUnbindWatchAdmin          =  102019,//管理员解绑手表
    ServiceMsgCodeAdminPriorityChange       =  102028,//管理员权限变更
    ServiceMsgCodeKidInfoUpdate             =  102020,//儿童信息保存
    ServiceMsgCodeKidInfoRequest            =  102021,//儿童信息获取
    ServiceMsgCodeCommentCommit             =  102022,//意见反馈
    //ServiceMsgCodeCommentRequest            =  102023,//意见反馈信息获取，无用
    ServiceMsgCodeEnshrineLocation          =  102024,//用户收藏位置
    ServiceMsgCodeRemoveEnshrineLocation    =  102029,//用户取消收藏位置
    ServiceMsgCodeEnshrineLocationRequest   =  102025,//用户收藏位置获取
    //ServiceMsgCodeKidTrackUpload            =  102026,//儿童历史轨迹上传，手表端接口
    ServiceMsgCodeKidTrackRequest           =  102027,//儿童历史轨迹获取
    ServiceMsgCodeWatchInfoUpdate           =  102034,//用户设置手表信息
    ServiceMsgCodeWatchInfoDownload         =  102035,//用户获取手表信息
    ServiceMsgCodeSetWatchOperate           =  102036,//用户设置手表操作（打电话，发电量，上传位置）
    
    ServiceMsgCodePushInfoDownload          =  102039,//用户获取推送消息
};

/*
 -------------------------------------
 卓易账号管理相关 AccountManage
 -------------------------------------
 */

typedef void(^AMPostHttpRequestCompletionBlock)(id result);
typedef void(^AMPostHttpRequestFailedBlock)(NSString *url, id result);

#define sAMServiceUrlLogin          @"lapi/login"       //登录
#define sAMServiceUrlEnroll         @"lapi/signup"      //注册
#define sAMServiceUrlEmailEnroll    @"lapi/getmail"     //邮箱注册及找回、修改、绑定密码
#define sAMServiceUrlVcode          @"lapi/getrandcode" //验证码
#define sAMServiceUrlResetPwd       @"lapi/resetpass"   //重置密码(验证码)
#define sAMServiceUrlResetOldPwd    @"lapi/changepass"   //重置密码(旧密码)
#define sAMServiceUrlAuthorize      @"lapi/auth"        //授权第三方

//codetype:验证码类型 [userreg,resetpasswd,bindmobile]
#define sAMVCodeTypeEnroll          @"userreg"
#define sAMVCodeTypeResetPwd        @"resetpasswd"
#define sAMVCodeTypeBindPhone       @"bindmobile"

//utype:第三方用户类型[openqq,openweibo]
#define sAMAuthUserTypeQQ           @"openqq"
#define sAMAuthUserTypeWeibo        @"openweibo"

//utype:登录账号类型[zhuoyou]?
#define sAMLoginUserTypeZhuoyou     @"zhuoyou" //卓悠账号登录
#define sAMLoginUserTypeEmail       @"mail"    //邮箱登录

//regtype:注册步骤[smsreg,randreg]?
#define sAMEnrollTypeSms            @"smsreg"   //短信注册
#define sAMEnrollTypeVCode          @"randreg"  //验证码注册


#define sAMUserLoginStyle           @"loginStyle"         //用户登录方式
#define sAMPhoneNumberLogin         @"phoneNumberLogin"   //手机号码登录
#define sAMEmailAccountLogin        @"emailAccountLogin"  //邮箱账号登录

#endif//__ServerUrlInfoDefines_H__
