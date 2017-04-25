//
//  CoreDataManager.h
//  DroiKids
//
//  Created by macMini_Dev on 15/8/31.
//  Copyright (c) 2015年 TYDTech. All rights reserved.
//

#import <CoreData/CoreData.h>

@interface CoreDataManager : NSObject

@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;

- (void)saveContext;
- (NSManagedObject *)createObjectWithEntityName:(NSString *)entityName;
- (void)deleteOneObject:(NSManagedObject *)object;
- (void)deleteObjects:(NSArray *)objects;
- (void)deleteAllObjectsWithEntityName:(NSString *)entityName;
- (NSArray *)fetchObjectsWithEntityName:(NSString *)entityName sortDescriptors:(NSArray *)sortDescriptors predicate:(NSPredicate *)predicate;
- (NSArray *)fetchObjectsWithRequest:(NSFetchRequest *)request;

@end
