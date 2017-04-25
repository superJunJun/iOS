//
//  TYDDataCenter.m
//  DroiKids
//
//  Created by macMini_Dev on 15/8/31.
//  Copyright (c) 2015年 TYDTech. All rights reserved.
//

#import "TYDDataCenter.h"
#import "CoreDataCommonInfo.h"
#import "CoreDataManager.h"
#import "TYDKidInfo.h"

#import "TYDKidMessageInfo.h"
#import "KidMessageEntity.h"
#import "TYDPostUrlRequest.h"

@interface TYDDataCenter ()

@property (strong, nonatomic) CoreDataManager *coreDataManager;
@property (strong, nonatomic) NSNumber *messageMarkedIndex;
@property (strong, nonatomic) NSMutableArray *kidInfoArray;
@property (strong, nonatomic) NSMutableArray *watchInfoArray;
@property (strong, nonatomic) NSArray *kidIDArray;

@end

@implementation TYDDataCenter

@synthesize currentKidInfo = _currentKidInfo;

#pragma mark - KidInfo

- (void)setCurrentKidInfo:(TYDKidInfo *)info
{
    if(self.kidInfoArray.count == 0
       || info == nil
       || info == self.currentKidInfo
       || [self.kidInfoList containsObject:info] == NO)
    {}
    else
    {
        _currentKidInfo = info;
    }
}

- (NSArray *)kidInfoList
{
    return [self.kidInfoArray copy];
}

- (void)saveKidInfoList:(NSArray *)kidInfos
{
    NSMutableArray *localInfoList = self.kidInfoArray;
    for(TYDKidInfo *info in kidInfos)
    {
        if(localInfoList.count < nKidCountForUserMax
           && [info isKindOfClass:TYDKidInfo.class]
           && [localInfoList containsObject:info] == NO)
        {
            [localInfoList addObject:info];
        }
    }
    if(self.currentKidInfo == nil
       && localInfoList.count > 0)
    {
        self.currentKidInfo = localInfoList.firstObject;
    }
    self.kidIDArray = nil;
}

- (void)removeOneKidInfo:(TYDKidInfo *)kidInfo
{
    NSMutableArray *localInfoList = self.kidInfoArray;
    if([localInfoList containsObject:kidInfo])
    {
        [localInfoList removeObject:kidInfo];
        [self removeMessageInfoListWithKidID:kidInfo.kidID];
        if(self.currentKidInfo == kidInfo)
        {
            self.currentKidInfo = (localInfoList.count > 0 ? localInfoList.firstObject : nil);
        }
    }
    self.kidIDArray = nil;
}

- (void)clearKidInfoList
{
    [self.kidInfoArray removeAllObjects];
    self.kidIDArray = nil;
    _currentKidInfo = nil;
}

- (void)amPostHttpRequestFailed:(id)result msgCode:(NSUInteger)msgCode
{
    NSError *error = result;
    NSLog(@"amPostHttpRequestFailed:%d! Error - %@ %@", (int)msgCode, [error localizedDescription], [[error userInfo] objectForKey:NSURLErrorFailingURLStringErrorKey]);
}

#pragma mark - Filter

- (NSArray *)kidIDArray
{
    if(_kidIDArray == nil)
    {
        NSMutableArray *list = [NSMutableArray new];
        for(TYDKidInfo *info in self.kidInfoArray)
        {
            [list addObject:info.kidID];
        }
        _kidIDArray = list;
    }
    return _kidIDArray;
}

- (TYDKidInfo *)kidInfoWithKidID:(NSString *)kidID
{
    TYDKidInfo *kidInfo = nil;
    if(kidID.length > 0)
    {
        for(TYDKidInfo *info in self.kidInfoArray)
        {
            if([info.kidID isEqualToString:kidID])
            {
                kidInfo = info;
                break;
            }
        }
    }
    return kidInfo;
}

- (void)filterMessageInfoList
{
    NSArray *kidIDArray = self.kidIDArray;
    if(kidIDArray.count == 0)
    {
        return;
    }
    
    NSString *entityName = sKidMessageEntityName;
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:entityName];
    request.predicate = [NSPredicate predicateWithFormat:@"NOT (%K IN %@)", sKidDataInfoKidIDKey, kidIDArray];
    NSArray *savedInfos = [self.coreDataManager fetchObjectsWithRequest:request];
    if(savedInfos.count > 0)
    {
        [self.coreDataManager deleteObjects:savedInfos];
    }
}

#pragma mark - MessageInfo

- (NSArray *)messageInfoList
{
    NSMutableArray *messageInfoList = [NSMutableArray new];
    NSArray *kidIDArray = self.kidIDArray;
    if(kidIDArray.count > 0)
    {
        NSString *entityName = sKidMessageEntityName;
        NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:entityName];
//        request.predicate = [NSPredicate predicateWithFormat:@"NOT (%K IN %@)", sKidDataInfoKidIDKey, kidIDArray];
        request.predicate = [NSPredicate predicateWithFormat:@"(%K IN %@)", sKidDataInfoKidIDKey, kidIDArray];

        request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:sKidDataInfoTimeKey ascending:NO]];
        
        NSArray *savedInfos = [self.coreDataManager fetchObjectsWithRequest:request];
        for(KidMessageEntity *entity in savedInfos)
        {
            TYDKidMessageInfo *messageInfo = [TYDKidMessageInfo new];
            messageInfo.kidID = entity.kidID;
            messageInfo.messageID = entity.messageID;
            messageInfo.messageContent = entity.messageContent;
            messageInfo.messageUnreadFlag = entity.messageUnreadFlag;
            messageInfo.infoType = entity.infoType;
            messageInfo.infoCreateTime = entity.infoCreateTime;
            [messageInfoList addObject:messageInfo];
        }
    }
    return messageInfoList;
}

- (NSArray *)messageInfoListWithKidID:(NSString *)kidID
{
    NSMutableArray *messageInfoList = [NSMutableArray new];
    if(kidID.length > 0)
    {
        NSString *entityName = sKidMessageEntityName;
        NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:entityName];
        request.predicate = [NSPredicate predicateWithFormat:@"(%K == %@)", sKidDataInfoKidIDKey, kidID];
        request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:sKidDataInfoTimeKey ascending:NO]];
        
        NSArray *savedInfos = [self.coreDataManager fetchObjectsWithRequest:request];
        for(KidMessageEntity *entity in savedInfos)
        {
            TYDKidMessageInfo *messageInfo = [TYDKidMessageInfo new];
            messageInfo.kidID = entity.kidID;
            messageInfo.messageID = entity.messageID;
            messageInfo.messageContent = entity.messageContent;
            messageInfo.messageUnreadFlag = entity.messageUnreadFlag;
            messageInfo.infoType = entity.infoType;
            messageInfo.infoCreateTime = entity.infoCreateTime;
            [messageInfoList addObject:messageInfo];
        }
    }
    return messageInfoList;
}

//有新的消息推送过来，保存时触发“有新消息”
- (void)saveMessageInfo:(TYDKidMessageInfo *)messageInfo
{
    if(messageInfo == nil
       || messageInfo.kidID.length == 0
       || messageInfo.messageContent.length == 0
       || ![self.kidIDArray containsObject:messageInfo.kidID]
       )
    {
        return;
    }
    
    NSString *entityName = sKidMessageEntityName;
    if(messageInfo.messageID.length > 0)
    {//已有条目信息修改保存
        NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:entityName];
        request.predicate = [NSPredicate predicateWithFormat:@"(%K == %@)", sKidDataInfoMessageIDKey, messageInfo.messageID];
        NSArray *savedInfos = [self.coreDataManager fetchObjectsWithRequest:request];
        if(savedInfos.count > 0)
        {
            KidMessageEntity *entity = savedInfos.firstObject;
            entity.kidID = messageInfo.kidID;
            entity.messageID = messageInfo.messageID;
            entity.messageContent = messageInfo.messageContent;
            entity.messageUnreadFlag = messageInfo.messageUnreadFlag;
            entity.infoType = messageInfo.infoType;
            entity.infoCreateTime = messageInfo.infoCreateTime;
            [self.coreDataManager saveContext];
        }
    }
    else
    {//新条目保存
        messageInfo.messageID = [self messageAutoIncreaseIdentifier];
        KidMessageEntity *entity = (KidMessageEntity *)[self.coreDataManager createObjectWithEntityName:entityName];
        entity.kidID = messageInfo.kidID;
        entity.messageID = messageInfo.messageID;
        entity.messageContent = messageInfo.messageContent;
        entity.messageUnreadFlag = messageInfo.messageUnreadFlag;
        entity.infoType = messageInfo.infoType;
        entity.infoCreateTime = messageInfo.infoCreateTime;
        [self.coreDataManager saveContext];
        
        [self reportOneNewMessageDidSave:messageInfo];
    }
}

- (void)removeOneMessageInfo:(TYDKidMessageInfo *)messageInfo
{
    if(messageInfo == nil
       || messageInfo.kidID.length == 0)
    {
        return;
    }
    
    NSString *entityName = sKidMessageEntityName;
    if(messageInfo.messageID.length > 0)
    {//已有条目信息修改保存
        NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:entityName];
        request.predicate = [NSPredicate predicateWithFormat:@"(%K == %@)", sKidDataInfoMessageIDKey, messageInfo.messageID];
        NSArray *savedInfos = [self.coreDataManager fetchObjectsWithRequest:request];
        if(savedInfos.count > 0)
        {
            KidMessageEntity *entity = savedInfos.firstObject;
            [self.coreDataManager deleteOneObject:entity];
        }
        else
        {
            NSLog(@"EntityNotFound:%@", messageInfo.messageID);
        }
    }
}

- (void)removeMessageInfoListWithKidID:(NSString *)kidID
{
    if(kidID.length == 0)
    {
        return;
    }
    NSString *entityName = sKidMessageEntityName;
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:entityName];
    request.predicate = [NSPredicate predicateWithFormat:@"(%K == %@)", sKidDataInfoKidIDKey, kidID];
    
    NSArray *savedInfos = [self.coreDataManager fetchObjectsWithRequest:request];
    if(savedInfos.count > 0)
    {
        [self.coreDataManager deleteObjects:savedInfos];
    }
}

- (void)reportOneNewMessageDidSave:(TYDKidMessageInfo *)messageInfo
{
    TYDKidInfo *kidInfo = [self kidInfoWithKidID:messageInfo.kidID];
    if(kidInfo != nil)
    {
        if([self.messageDelegate respondsToSelector:@selector(dataCenterReceivedNewMessage:)])
        {
            [self.messageDelegate dataCenterReceivedNewMessage:kidInfo];
        }
    }
}

#pragma mark - SingleTon

+ (instancetype)defaultCenter
{
    static TYDDataCenter *dataCenterInstance = nil;
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
        dataCenterInstance = [[self alloc] init];
    });
    return dataCenterInstance;
}

- (instancetype)init
{
    if(self = [super init])
    {
        [self messageMarkedIndexInit];
        self.coreDataManager = [CoreDataManager new];
        self.kidInfoArray = [NSMutableArray new];
        self.watchInfoArray = [NSMutableArray new];
        self.kidIDArray = nil;
        self.isContactInfoListModified = NO;
    }
    return self;
}

#pragma mark - messageMarkedIndex

- (NSString *)messageAutoIncreaseIdentifier
{
    //整体长度为16位，时间戳占10位，标记序列占6位
    NSInteger time = [BOTimeStampAssistor getCurrentTime];
    time = MAX(1, time);//1970年以前不管
    NSString *timeString = [NSString stringWithFormat:@"%ld", (long)time];
    if(timeString.length > 10)
    {
        timeString = [timeString substringToIndex:10];
    }
    
    long markIndex = self.messageMarkedIndex.longValue;
    self.messageMarkedIndex = @((markIndex + 1) % 1000000);
    return [timeString stringByAppendingFormat:@"%06ld", markIndex];
}

- (void)messageMarkedIndexInit
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSNumber *markIndexNumber = [userDefaults objectForKey:sMessageIndexMarkedKey];
    if(!markIndexNumber)
    {//首次使用，随机6位数
        markIndexNumber = @([BOAssistor randomNumberBetweenNumber:0 andNumber:1000000]);
        [userDefaults setObject:markIndexNumber forKey:sMessageIndexMarkedKey];
        [userDefaults synchronize];
    }
    _messageMarkedIndex = markIndexNumber;
}

- (void)setMessageMarkedIndex:(NSNumber *)index
{
    if(![_messageMarkedIndex isEqualToNumber:index])
    {
        _messageMarkedIndex = index;
        [[NSUserDefaults standardUserDefaults] setObject:index forKey:sMessageIndexMarkedKey];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

@end
