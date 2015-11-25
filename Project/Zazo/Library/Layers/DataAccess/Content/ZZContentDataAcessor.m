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
#import "ZZAccountTransportService.h"
#import "ANCrashlyticsAdapter.h"


@implementation ZZContentDataAcessor

+ (void)start
{
    [MagicalRecord setShouldDeleteStoreOnModelMismatch:NO];
    
    ZZMigrationManager* migrationManager = [ZZMigrationManager new];
    if ([migrationManager isMigrationNecessary])
    {
        [migrationManager migrate];
        
        [MagicalRecord setupCoreDataStackWithStoreAtURL:[migrationManager destinationUrl]];
        
        __block ZZUserDomainModel* authUser = [ZZUserDataProvider authenticatedUser];
        
        [ZZStoredSettingsManager shared].userID = authUser.idTbm;
        [ZZStoredSettingsManager shared].authToken = authUser.auth;
        [ZZStoredSettingsManager shared].mobileNumber = authUser.mobileNumber;
        
        [[ZZAccountTransportService registerUserWithModel:authUser shouldForceCall:NO] subscribeNext:^(NSDictionary *authKeys) {
            
            NSString *auth = authKeys[@"auth"];
            NSString *mkey = authKeys[@"mkey"];
            [ZZStoredSettingsManager shared].userID = mkey;
            [ZZStoredSettingsManager shared].authToken = auth;
            
            authUser.mkey = mkey;
            authUser.auth = auth;
            authUser = [ZZUserDataProvider upsertUserWithModel:authUser];
            
            [ANCrashlyticsAdapter updateUserDataWithID:mkey username:authUser.fullName email:authUser.mobileNumber];
        }];
        
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








