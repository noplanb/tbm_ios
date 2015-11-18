//
//  ZZContentDataAcessor.m
//  Zazo
//
//  Created by Oksana Kovalchuk on 9/1/15.
//  Copyright (c) 2015 No Plan B. All rights reserved.
//

#import "ZZContentDataAcessor.h"
#import "TBMFriend.h"
#import "ZZFriendDataUpdater.h"
#import "ZZUserDataProvider.h"
#import "TBMUser.h"


@implementation ZZContentDataAcessor

+ (void)start
{
    [MagicalRecord setupCoreDataStackWithAutoMigratingSqliteStoreAtURL:[self sourceUrl]];
    
    if ([NSManagedObjectContext MR_rootSavingContext])
    {
        ZZLogInfo(@"Successfull Core Data migration. Trying to fill new fields"); // TODO: cleanup
        ANDispatchBlockToBackgroundQueue(^{
            [ZZFriendDataUpdater fillEntitiesAfterMigration];
        });
    }
}

+ (NSURL*)sourceUrl
{
    return [NSURL fileURLWithPath:[[self applicationDocumentsDirectory].path
                                   stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.sqlite", kContentDBName]]];
}

+ (NSURL*)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}


#pragma mark - Data Base part

+ (void)saveDataBase
{
    [[self contextForCurrentThread] MR_saveToPersistentStoreAndWait];
}

#pragma GCC diagnostic push
#pragma GCC diagnostic ignored "-Wdeprecated-declarations"
+ (NSManagedObjectContext *)contextForCurrentThread
{
    return [NSManagedObjectContext MR_contextForCurrentThread];
}
#pragma GCC diagnostic pop

+ (void)refreshContext:(NSManagedObjectContext*)context
{
    if ([context respondsToSelector:@selector(refreshAllObjects)])
    {
        [context refreshAllObjects];
    }
    else
    {
        [context.insertedObjects enumerateObjectsUsingBlock:^(__kindof NSManagedObject * _Nonnull obj, BOOL * _Nonnull stop) {
            [context refreshObject:obj mergeChanges:YES];
        }];
        
        [context.updatedObjects enumerateObjectsUsingBlock:^(__kindof NSManagedObject * _Nonnull obj, BOOL * _Nonnull stop) {
            [context refreshObject:obj mergeChanges:YES];
        }];
        
        [context.deletedObjects enumerateObjectsUsingBlock:^(__kindof NSManagedObject * _Nonnull obj, BOOL * _Nonnull stop) {
            [context refreshObject:obj mergeChanges:YES];
        }];
    }
}

@end








