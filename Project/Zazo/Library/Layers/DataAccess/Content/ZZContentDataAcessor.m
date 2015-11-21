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
#import "ZZMigrationManager.h"
#import "ZZStoredSettingsManager.h"

@implementation ZZContentDataAcessor

+ (void)start
{
    ZZMigrationManager* migrationManager = [ZZMigrationManager new];
    if ([migrationManager isMigrationNecessary])
    {
        [migrationManager migrate];
        
        [MagicalRecord setupCoreDataStackWithStoreAtURL:[migrationManager destinationUrl]];
        
        ZZUserDomainModel* authUser = [ZZUserDataProvider authenticatedUser];
        [ZZStoredSettingsManager shared].userID = authUser.idTbm;
        [ZZStoredSettingsManager shared].authToken = authUser.auth;
        
        if ([NSManagedObjectContext MR_rootSavingContext])
        {
            ZZLogInfo(@"Successfull Core Data migration. Trying to fill new fields"); // TODO: cleanup
            ANDispatchBlockToBackgroundQueue(^{
                [ZZFriendDataUpdater fillEntitiesAfterMigration];
            });
        }
    }
    else
    {
        [MagicalRecord setupCoreDataStackWithStoreAtURL:[migrationManager destinationUrl]];
    }
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








