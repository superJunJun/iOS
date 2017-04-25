//
//  TYDAMPostUrlRequest.m
//
//  用户账号注册、登录、修改密码、第三方登录
//

#import "TYDAMPostUrlRequest.h"
#import "ASIFormDataRequest.h"
#import "NSString+MD5Addition.h"
#import "GTMBase64.h"

#define sAMServerUrlBasic           @"http://211.151.209.104:7890/"//手机号正式服务器
#define sAMServerUrlEmail           @"http://lapi.tt286.com:7892/"//邮箱正式服务器
//#define sAMServerEmailUrlBasic      @"http://192.168.0.254:7892/"//邮箱测试服务器

#define sCharCodeSourceString       @"charCodeSourceString"
#define sCharCodeDestinationString  @"charCodeDestinationString"

@implementation TYDAMPostUrlRequest

+ (void)amRequestWithURL:(NSString *)url
                  params:(NSMutableDictionary *)params
           completeBlock:(AMPostHttpRequestCompletionBlock)completionBlock
             failedBlock:(AMPostHttpRequestFailedBlock)failedBlock
{
    NSString *wholeURL = nil;
    if([url isEqualToString:sAMServiceUrlEmailEnroll]
       || [params[sAMUserLoginStyle] isEqualToString:sAMEmailAccountLogin])
    {
        wholeURL = [sAMServerUrlEmail stringByAppendingFormat:@"%@", url];
    }
    else
    {
        wholeURL = [sAMServerUrlBasic stringByAppendingFormat:@"%@", url];
    }
    NSLog(@"wholeURL:%@", wholeURL);
    
    if(!params)
    {
        params = [NSMutableDictionary new];
    }
    
    __block ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:wholeURL]];
    //请求超时时间
    [request setTimeOutSeconds:30];
    [request setRequestMethod:sPostHttpMethodName];
    
    //POST请求
    for(NSString *key in params)
    {
        id value = [params objectForKey:key];
        if([value isKindOfClass:NSData.class])
        {
            [request addData:value forKey:key];
        }
        else
        {
            [request addPostValue:value forKey:key];
        }
    }
    
    //设置请求完成的block
    __weak ASIFormDataRequest *requestTemp = request;
    [request setCompletionBlock:^{
        NSData *data = requestTemp.responseData;
        
        NSString *str = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        NSLog(@"str:%@", str);
//        id result = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
//        NSError *error;
//        id result = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&error];
        id result = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
        
        if(completionBlock != nil)
        {
            completionBlock(result);
        }
    }];
    
    //设置请求失败的block
    __block NSString *bUrl = url;
    [request setFailedBlock:^{
        NSError *error = requestTemp.error;
        if(failedBlock != nil)
        {
            failedBlock(bUrl, error);
        }
    }];
    
    [request startAsynchronous];
}

+ (NSDictionary *)deviceInfoCheckList
{
    //@"['a']='o',['2']='D',['c']='U',['b']='W',['e']='B',['d']='j',['g']='h',['f']='3',['i']='7',['h']='Y',['k']='z',['j']='y',['m']='u',['l']='t',['/']='c',['n']='J',['1']='F',['0']='s',['3']='E',['r']='e',['5']='f',['t']='l',['7']='g',['v']='q',['9']='2',['8']='i',['+']='Q',['z']='b',['4']='P',['o']='O',['u']='V',['s']='T',['A']='L',['p']='N',['C']='S',['B']='w',['E']='K',['D']='+',['G']='p',['F']='0',['I']='4',['H']='M',['K']='Z',['J']='d',['M']='k',['L']='1',['O']='6',['N']='X',['Q']='C',['P']='R',['S']='H',['R']='m',['U']='9',['T']='/',['W']='8',['V']='n',['Y']='5',['X']='r',['q']='G',['Z']='I',['x']='A',['w']='x',['6']='v',['y']='a',[' ‘]=‘Q'";
    //设备信息（devinfo）base64编码后按照对照表改成新的字符串作为参数传过来
    //注：上面是解码的对照表，编码时请反过来
    
    NSString *sourceString =
    @"a2cbedgf_ihkjml/n_103r5t7v_98+z4ous_ApCBEDGF_IHKJMLON_QPSRUTWV_YXqZxw6y ";
    NSString *destinationString =
    @"oDUWBjh3_7YzyutcJ_FsEeflgq_2iQbPOVT_LNSwK+p0_4MZdk16X_CRHm9/8n_5rGIAxvaQ";
    NSDictionary *checkListDic = @{sCharCodeSourceString:sourceString, sCharCodeDestinationString:destinationString};
    
    return checkListDic;
}

//解码
+ (NSString *)deviceInfoDecode:(NSString *)deviceInfo
{
    if(deviceInfo.length == 0)
    {
        return @"";
    }
    NSDictionary *checkListDic = [self deviceInfoCheckList];
    NSString *sourceListString = checkListDic[sCharCodeSourceString];
    NSString *destinationListString = checkListDic[sCharCodeDestinationString];
    
    NSMutableString *resultString = [NSMutableString new];
    for(NSUInteger index = 0; index < deviceInfo.length; index++)
    {
        NSString *srcChar = [deviceInfo substringWithRange:NSMakeRange(index, 1)];
        NSRange srcCharRange = [sourceListString rangeOfString:srcChar];
        if(srcCharRange.length > 0)
        {
            [resultString appendString:[destinationListString substringWithRange:srcCharRange]];
        }
    }
    return resultString;
}

//编码
+ (NSString *)deviceInfoEncode:(NSString *)deviceInfo
{
    if(deviceInfo.length == 0)
    {
        return @"";
    }
    
    //Base64处理
    deviceInfo = [GTMBase64 stringByEncodingData:[deviceInfo dataUsingEncoding:NSUTF8StringEncoding]];
    
    NSDictionary *checkListDic = [self deviceInfoCheckList];
    NSString *sourceListString = checkListDic[sCharCodeSourceString];
    NSString *destinationListString = checkListDic[sCharCodeDestinationString];
    
    NSMutableString *resultString = [NSMutableString new];
    for(NSUInteger index = 0; index < deviceInfo.length; index++)
    {
        NSString *destChar = [deviceInfo substringWithRange:NSMakeRange(index, 1)];
        NSRange destCharRange = [destinationListString rangeOfString:destChar];
        if(destCharRange.length > 0)
        {
            [resultString appendString:[sourceListString substringWithRange:destCharRange]];
        }
    }
    return resultString;
}

+ (NSString *)signInfoCreateWithInfos:(NSArray *)stringArray
{
    NSMutableString *signInfo = [NSMutableString new];
    for(id obj in stringArray)
    {
        [signInfo appendFormat:@"%@", obj];
    }
    
    [signInfo appendString:@"ZYK_ac17c4b0bb1d5130bf8e0646ae2b4eb4"];
    return [signInfo MD5String];
}

@end
