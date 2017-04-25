//
//  CoreDataManager.m
//  DroiKids
//
//  Created by macMini_Dev on 15/8/31.
//  Copyright (c) 2015年 TYDTech. All rights reserved.
//

#import "CoreDataManager.h"
#import "CoreDataCommonInfo.h"

@interface CoreDataManager ()

//@property (strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

@end

@implementation CoreDataManager

@synthesize managedObjectModel = _managedObjectModel;

#pragma mark - CoreDataStack

- (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

- (NSManagedObjectModel *)managedObjectModel
{
    if(_managedObjectModel != nil)
    {
        return _managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:sCoreDataModeName withExtension:sCoreDataModeExtension];
    NSLog(@"CoreDataModelUrl:%@", modelURL);
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    if(_persistentStoreCoordinator != nil)
    {
        return _persistentStoreCoordinator;
    }
    
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:sCoreDataSqliteFileName];
    NSLog(@"CoreDataStoreURL:%@", storeURL);
    NSError *error = nil;
    NSString *failureReason = @"There was an error creating or loading the application's saved data.";
    if(![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error])
    {
        // Report any error we got.
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        dict[NSLocalizedDescriptionKey] = @"Failed to initialize the application's saved data";
        dict[NSLocalizedFailureReasonErrorKey] = failureReason;
        dict[NSUnderlyingErrorKey] = error;
        error = [NSError errorWithDomain:@"YOUR_ERROR_DOMAIN" code:9999 userInfo:dict];
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    return _persistentStoreCoordinator;
}


- (NSManagedObjectContext *)managedObjectContext
{
    if(_managedObjectContext != nil)
    {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if(!coordinator)
    {
        return nil;
    }
    _managedObjectContext = [[NSManagedObjectContext alloc] init];
    [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    return _managedObjectContext;
}

#pragma mark - CoreDataSavingSupport

- (void)saveContext
{
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if(managedObjectContext != nil)
    {
        NSError *error = nil;
        if ([managedObjectContext hasChanges]
            && ![managedObjectContext save:&error])
        {
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
}

#pragma mark - Manage

//查找
- (NSArray *)fetchObjectsWithEntityName:(NSString *)entityName sortDescriptors:(NSArray *)sortDescriptors predicate:(NSPredicate *)predicate
{
    NSManagedObjectContext *context = self.managedObjectContext;
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:entityName];
    request.sortDescriptors = sortDescriptors;
    request.predicate = predicate;
    return [context executeFetchRequest:request error:nil];
}

- (NSArray *)fetchObjectsWithRequest:(NSFetchRequest *)request
{
    NSManagedObjectContext *context = self.managedObjectContext;
    return [context executeFetchRequest:request error:nil];
}

//新建一个实例，未保存
- (NSManagedObject *)createObjectWithEntityName:(NSString *)entityName
{
    NSManagedObjectContext *context = self.managedObjectContext;
    return [NSEntityDescription insertNewObjectForEntityForName:entityName inManagedObjectContext:context];;
}

//删除一项
- (void)deleteOneObject:(NSManagedObject *)object
{
    if(object != nil)
    {
        NSManagedObjectContext *context = self.managedObjectContext;
        NSError *error = nil;
        [context deleteObject:object];
        if(![context save:&error])
        {
            NSLog(@"CoreData Save Error:%@", error.localizedDescription);
        }
    }
}

//删除多项
- (void)deleteObjects:(NSArray *)objects
{
    if(objects.count > 0)
    {
        NSManagedObjectContext *context = self.managedObjectContext;
        NSError *error = nil;
        for(id obj in objects)
        {
            if([obj isKindOfClass:NSManagedObject.class])
            {
                [context deleteObject:(NSManagedObject *)obj];
            }
        }
        if(![context save:&error])
        {
            NSLog(@"CoreData Save Error:%@", error.localizedDescription);
        }
    }
}

- (void)deleteAllObjectsWithEntityName:(NSString *)entityName
{
    NSManagedObjectContext *context = self.managedObjectContext;
    NSEntityDescription *entity = [NSEntityDescription entityForName:entityName inManagedObjectContext:context];
    
    NSFetchRequest *request = [NSFetchRequest new];
    request.includesPropertyValues = NO;
    request.entity = entity;
    
    NSError *error = nil;
    NSArray *datas = [context executeFetchRequest:request error:&error];
    if(!error && datas.count)
    {
        for(NSManagedObject *obj in datas)
        {
            [context deleteObject:obj];
        }
        if(![context save:&error])
        {
            NSLog(@"CoreData Save Error:%@", error.localizedDescription);
        }
    }
}

@end
