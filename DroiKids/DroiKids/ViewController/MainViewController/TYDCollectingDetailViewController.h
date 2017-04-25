//
//  TYDCollectingDetailViewController.h
//  DroiKids
//
//  Created by superjunjun on 15/9/10.
//  Copyright (c) 2015年 TYDTech. All rights reserved.
//

#import "BaseViewController.h"
#import "TYDEnshrineLocationInfo.h"

@interface TYDCollectingDetailViewController : BaseViewController

@property (strong, nonatomic) NSMutableArray        *userCollectionPointArray;//服务器请求来的收藏点数组
@property (strong, nonatomic) TYDEnshrineLocationInfo *kidcollectionInfo;

@end
