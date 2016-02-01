//
//  ZZFriendDataUpdater.m
//  Zazo
//
//  Created by Oksana Kovalchuk on 9/30/15.
//  Copyright © 2015 No Plan B. All rights reserved.
//

#import "ZZFriendDataUpdater.h"
#import "MagicalRecord.h"
#import "TBMFriend.h"
#import "ZZFriendModelsMapper.h"
#import "ZZFriendDataProvider+Entities.h"
#import "ZZContentDataAccessor.h"
#import "ZZVideoStatusHandler.h"

@implementation ZZFriendDataUpdater

#pragma mark Update methods

+ (void)updateLastTimeActionFriendWithID:(NSString*)itemID
{
    [self _updateFriendWithID:itemID usingBlock:^(TBMFriend *friendEntity) {
        friendEntity.timeOfLastAction = [NSDate date];
    }];
}

+ (void)updateFriendWithID:(NSString *)friendID setConnectionStatus:(ZZFriendshipStatusType)status
{
    [self _updateFriendWithID:friendID usingBlock:^(TBMFriend *friendEntity) {
        friendEntity.friendshipStatus = ZZFriendshipStatusTypeStringFromValue(status);
    }];
}

+ (void)updateFriendWithID:(NSString *)friendID setLastIncomingVideoStatus:(ZZVideoIncomingStatus)status
{
    [self _updateFriendWithID:friendID usingBlock:^(TBMFriend *friendEntity) {
        friendEntity.lastIncomingVideoStatus = @(status);
    }];
}

+ (void)updateFriendWithID:(NSString *)friendID setOutgoingVideoStatus:(ZZVideoOutgoingStatus)status
{
    [self _updateFriendWithID:friendID usingBlock:^(TBMFriend *friendEntity) {
        friendEntity.outgoingVideoStatus = @(status);
    }];
}

+ (void)updateFriendWithID:(NSString *)friendID setUploadRetryCount:(NSUInteger)count
{
    [self _updateFriendWithID:friendID usingBlock:^(TBMFriend *friendEntity) {
        friendEntity.uploadRetryCount = @(count);
    }];
}

+ (void)updateFriendWithID:(NSString *)friendID setLastVideoStatusEventType:(ZZVideoStatusEventType)eventType
{
    [self _updateFriendWithID:friendID usingBlock:^(TBMFriend *friendEntity) {
        friendEntity.lastVideoStatusEventType = @(eventType);
    }];
}

+ (void)updateFriendWithID:(NSString *)friendID setOutgoingVideoItemID:(NSString *)videoID
{
    [self _updateFriendWithID:friendID usingBlock:^(TBMFriend *friendEntity) {
        friendEntity.outgoingVideoId = videoID;
    }];
}

+ (void)_updateFriendWithID:(NSString *)friendID usingBlock:(void (^)(TBMFriend *friendEntity))updateBlock
{
    ANDispatchBlockToMainQueue(^{
        TBMFriend* friendEntity = [self _userWithID:friendID];
        updateBlock(friendEntity);
        [friendEntity.managedObjectContext MR_saveToPersistentStoreAndWait];
    });
}

#pragma mark Batch updation

+ (void)updateEverSentFriendsWithMkeys:(NSArray*)mKeys
{
    ANDispatchBlockToMainQueue(^{
        [mKeys enumerateObjectsUsingBlock:^(NSString*  _Nonnull mKey, NSUInteger idx, BOOL * _Nonnull stop) {
            TBMFriend* friendEntity = [ZZFriendDataProvider friendEntityWithMkey:mKey];
            friendEntity.everSent = @(YES);
            friendEntity.isFriendshipCreator = @([friendEntity.friendshipCreatorMKey isEqualToString:friendEntity.mkey]);
        }];
        
        [[self _context] MR_saveToPersistentStoreAndWait];
    });
}

#pragma mark Upsert

+ (ZZFriendDomainModel*)upsertFriend:(ZZFriendDomainModel*)friendModel
{
    return ZZDispatchOnMainThreadAndReturn(^id{
        
        TBMFriend* friendEntity = [self _userWithID:friendModel.idTbm];
        
        if (friendEntity)
        {
            if ([friendEntity.hasApp boolValue] ^ friendModel.hasApp)
            {
                ZZLogInfo(@"createWithServerParams: Friend exists updating hasApp only since it is different.");
                friendEntity.hasApp = @(friendModel.hasApp);
                [friendEntity.managedObjectContext MR_saveToPersistentStoreAndWait];
                [[ZZVideoStatusHandler sharedInstance] notifyFriendChangedWithId:friendModel.idTbm];
            }
        }
        else
        {
            friendEntity = [TBMFriend MR_createEntityInContext:[self _context]];
            friendEntity = [ZZFriendModelsMapper fillEntity:friendEntity fromModel:friendModel];
            [friendEntity.managedObjectContext MR_saveToPersistentStoreAndWait];
            [[ZZVideoStatusHandler sharedInstance] notifyFriendChangedWithId:friendModel.idTbm];
        }
        
        if (![friendEntity.friendshipStatus isEqualToString:friendModel.friendshipStatus])
        {
            friendEntity = [ZZFriendModelsMapper fillEntity:friendEntity fromModel:friendModel];
        }
        
        return [ZZFriendDataProvider modelFromEntity:friendEntity];

    });
}

#pragma mark Deletion

+ (void)deleteAllFriends
{
    ANDispatchBlockToMainQueue(^{
        [TBMFriend MR_truncateAllInContext:[self _context]];
        [[self _context] MR_saveToPersistentStoreAndWait];
    });
}


#pragma mark Migration

+ (void)fillEntitiesAfterMigration
{
    ANDispatchBlockToMainQueue(^{
        for (TBMFriend *friendEntity in [TBMFriend MR_findAllInContext:[self _context]])
        {
            friendEntity.everSent = @([friendEntity.outgoingVideoStatus integerValue] > ZZVideoOutgoingStatusNone);
        }
        [[self _context] MR_saveToPersistentStoreAndWait];
    });
}


#pragma mark - Private

+ (TBMFriend*)_userWithID:(NSString*)itemID
{
    TBMFriend* item = nil;
    if (!ANIsEmpty(itemID))
    {
        NSPredicate* predicate = [NSPredicate predicateWithFormat:@"%K == %@", TBMFriendAttributes.idTbm,itemID];
        NSArray* items = [TBMFriend MR_findAllWithPredicate:predicate inContext:[self _context]];
        if (items.count > 1)
        {
            ANLogWarning(@"TBMFriend contains dupples for tbmID = %@", itemID);
        }
        item = [items firstObject];
    }
    return item;
}

+ (NSManagedObjectContext*)_context
{
    return [ZZContentDataAccessor mainThreadContext];
}

@end
