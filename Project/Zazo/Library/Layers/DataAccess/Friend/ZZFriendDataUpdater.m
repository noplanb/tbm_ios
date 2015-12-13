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
#import "ZZContentDataAcessor.h"
#import "ZZVideoStatusHandler.h"

@implementation ZZFriendDataUpdater

+ (void)updateLastTimeActionFriendWithID:(NSString*)itemID
{
    ANDispatchBlockToMainQueue(^{
        TBMFriend* item = [self _userWithID:itemID];
        item.timeOfLastAction = [NSDate date];
        [item.managedObjectContext MR_saveToPersistentStoreAndWait];
    });
}

+ (ZZFriendDomainModel*)updateConnectionStatusForUserWithID:(NSString *)itemID toValue:(ZZFriendshipStatusType)value
{
    return ZZDispatchOnMainThreadAndReturn(^id{
        TBMFriend* item = [self _userWithID:itemID];
        item.friendshipStatus = ZZFriendshipStatusTypeStringFromValue(value);
        [item.managedObjectContext MR_saveToPersistentStoreAndWait];
        return [ZZFriendModelsMapper fillModel:[ZZFriendDomainModel new] fromEntity:item];
    });
}

+ (ZZFriendDomainModel*)upsertFriend:(ZZFriendDomainModel*)model
{
    return ZZDispatchOnMainThreadAndReturn(^id{
        TBMFriend* item = [self _userWithID:model.idTbm];
        
//        if (item)
//        {
//            if ([item.hasApp boolValue] ^ model.hasApp)
//            {
//                ZZLogInfo(@"createWithServerParams: Friend exists updating hasApp only since it is different.");
//                item.hasApp = @(model.hasApp);
//                [item.managedObjectContext MR_saveToPersistentStoreAndWait];
//                [[ZZVideoStatusHandler sharedInstance] notifyFriendChangedWithId:model.idTbm];
//            }
//        }
//        else
//        {
//            item = [TBMFriend MR_createEntityInContext:[self _context]];
//            item = [ZZFriendModelsMapper fillEntity:item fromModel:model];
//            [item.managedObjectContext MR_saveToPersistentStoreAndWait];
//            [[ZZVideoStatusHandler sharedInstance] notifyFriendChangedWithId:model.idTbm];
//        }
//        
//        if (![item.friendshipStatus isEqualToString:model.friendshipStatus])
//        {
//            item = [ZZFriendModelsMapper fillEntity:item fromModel:model];
//        }
//        
//        return [ZZFriendDataProvider modelFromEntity:item];
        
        if (!item) {
            item = [TBMFriend MR_createEntityInContext:[self _context]];
        }
        
        [ZZFriendModelsMapper fillEntity:item fromModel:model];
        [item.managedObjectContext MR_saveToPersistentStoreAndWait];
        
        [[ZZVideoStatusHandler sharedInstance] notifyFriendChangedWithId:model.idTbm];

        ZZFriendDomainModel *friend = [ZZFriendDataProvider modelFromEntity:item];

        return friend;

    });
}

+ (void)updateEverSentFreindsWithMkeys:(NSArray*)mKeys
{
    ANDispatchBlockToMainQueue(^{
        [mKeys enumerateObjectsUsingBlock:^(NSString*  _Nonnull mKey, NSUInteger idx, BOOL * _Nonnull stop) {
            TBMFriend* friend = [ZZFriendDataProvider friendEnityWithMkey:mKey];
            friend.everSent = @(YES);
            friend.isFriendshipCreator = @([friend.friendshipCreatorMKey isEqualToString:friend.mkey]);
        }];
        
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

+ (void)fillEntitiesAfterMigration
{
    ANDispatchBlockToMainQueue(^{
        for (TBMFriend *friend in [TBMFriend MR_findAllInContext:[self _context]])
        {
            friend.everSent = @([friend.outgoingVideoStatus integerValue] > ZZVideoOutgoingStatusNone);
        }
        [[self _context] MR_saveToPersistentStoreAndWait];
    });
}

+ (NSManagedObjectContext*)_context
{
    return [ZZContentDataAcessor mainThreadContext];
}

@end
