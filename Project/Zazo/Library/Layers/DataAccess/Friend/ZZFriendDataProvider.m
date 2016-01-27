
//
//  ZZFriendDataProvider.m
//  Zazo
//
//  Created by ANODA on 8/10/15.
//  Copyright (c) 2015 ANODA. All rights reserved.
//

#import "ZZFriendDataProvider+Entities.h"
#import "ZZGridModelsMapper.h"
#import "ZZFriendDataProvider.h"
#import "TBMFriend.h"
#import "MagicalRecord.h"
#import "ZZFriendDomainModel.h"
#import "ZZFriendModelsMapper.h"
#import "ZZGridDataProvider.h"
#import "ZZGridDomainModel.h"
#import "ZZContentDataAccessor.h"
#import "ZZUserFriendshipStatusHandler.h"
#import "TBMVideo.h"

@implementation ZZFriendDataProvider

#pragma mark - Model fetching

+ (NSArray*)allFriendsModels
{
    return ZZDispatchOnMainThreadAndReturn(^id{

        [ZZContentDataAccessor refreshContext:[self _context]];

        NSArray* result = [TBMFriend MR_findAllInContext:[self _context]];
        return [[result.rac_sequence map:^id(id value) {
            return [self modelFromEntity:value];
        }] array];

    });
}

+ (NSArray *)allEverSentFriends
{
    return ZZDispatchOnMainThreadAndReturn(^id(){
        NSPredicate *everSent = [NSPredicate predicateWithFormat:@"%K = %@", TBMFriendAttributes.everSent, @(YES)];
        NSPredicate *creator = [NSPredicate predicateWithFormat:@"%K = %@", TBMFriendAttributes.isFriendshipCreator, @(NO)];
        NSPredicate *filter = [NSCompoundPredicate andPredicateWithSubpredicates:@[everSent, creator]];
        NSArray *entities = [TBMFriend MR_findAllWithPredicate:filter inContext:[ZZContentDataAccessor mainThreadContext]];

        return [entities.rac_sequence map:^id(id value) {
            return [self modelFromEntity:value];
        }];
    });
}

+ (NSArray *)allVisibleFriendModels
{
    NSArray* allFriendsModels = [ZZFriendDataProvider allFriendsModels];
    NSMutableArray* filteredFriends = [NSMutableArray new];

    [allFriendsModels enumerateObjectsUsingBlock:^(ZZFriendDomainModel *friendModel, NSUInteger idx, BOOL *_Nonnull stop) {
        if ([ZZUserFriendshipStatusHandler shouldFriendBeVisible:friendModel]) {
            [filteredFriends addObject:friendModel];
        }
    }];

    [filteredFriends sortUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"lastActionTimestamp" ascending:YES]]];
    
    return [filteredFriends copy];
}

+ (NSArray*)friendsOnGrid
{
    NSArray* gridModels = [ZZGridDataProvider loadAllGridsSortByIndex:NO];
    return [[gridModels.rac_sequence map:^id(ZZGridDomainModel* value) {
        return value.relatedUser;
    }] array];
}

+ (ZZFriendDomainModel*)friendWithItemID:(NSString*)itemID
{
    return [self _findFirstWithAttribute:TBMFriendAttributes.idTbm value:itemID];
}

+ (ZZFriendDomainModel*)friendWithMKeyValue:(NSString*)mKeyValue
{
    return [self _findFirstWithAttribute:TBMFriendAttributes.mkey value:mKeyValue];
}

+ (ZZFriendDomainModel*)friendWithMobileNumber:(NSString*)mobileNumber
{
    return [self _findFirstWithAttribute:TBMFriendAttributes.mobileNumber value:mobileNumber];
}

+ (ZZFriendDomainModel*)_findFirstWithAttribute:(NSString*)attribute value:(NSString*)value
{
    return ZZDispatchOnMainThreadAndReturn(^id {
        NSArray* result = [TBMFriend MR_findByAttribute:attribute withValue:value inContext:[self _context]];
        TBMFriend* friendEntity = [result firstObject];
        return [self modelFromEntity:friendEntity];
    });
}

#pragma mark - Other

+ (ZZFriendDomainModel*)lastActionFriendWithoutGrid
{
    return ZZDispatchOnMainThreadAndReturn(^id{

        NSArray* friendsOnGrid = [self friendsOnGrid];
        NSArray* friendsIDs = [friendsOnGrid valueForKeyPath:ZZFriendDomainModelAttributes.idTbm];
        NSPredicate* predicate = [NSPredicate predicateWithFormat:@"NOT (%K IN %@)", TBMFriendAttributes.idTbm, friendsIDs ? : @[]];

        NSArray* items = [TBMFriend MR_findAllSortedBy:TBMFriendAttributes.timeOfLastAction
                                             ascending:YES
                                         withPredicate:predicate
                                             inContext:[self _context]];

        __block ZZFriendDomainModel* nextFriendModel = nil;

        [items enumerateObjectsUsingBlock:^(TBMFriend*  _Nonnull friendEntity, NSUInteger idx, BOOL * _Nonnull stop) {

            ZZFriendDomainModel* friendModel = [ZZFriendDataProvider modelFromEntity:friendEntity];
            if ([ZZUserFriendshipStatusHandler shouldFriendBeVisible:friendModel])
            {
                nextFriendModel = friendModel;
                *stop = YES;
            }
        }];

        return nextFriendModel;
    });
}

+ (BOOL)isFriendExistsWithItemID:(NSString*)itemID
{
    NSNumber *result = ZZDispatchOnMainThreadAndReturn(^id{

        NSInteger count = 0;
        if (itemID)
        {
            NSPredicate* predicate = [NSPredicate predicateWithFormat:@"%K = %@", TBMFriendAttributes.idTbm, itemID];
            count = [TBMFriend MR_countOfEntitiesWithPredicate:predicate inContext:[self _context]];
        }

        return @(count != 0);
    });
    
    return result.boolValue;
}

#pragma mark - Entities

+ (TBMFriend*)friendEntityWithItemID:(NSString*)itemID
{
    return ZZDispatchOnMainThreadAndReturn(^id{
        NSArray* result = [TBMFriend MR_findByAttribute:TBMFriendAttributes.idTbm withValue:itemID inContext:[self _context]];
        TBMFriend* entity = [result firstObject];
        return entity;
    });
}

+ (TBMFriend*)friendEntityWithMkey:(NSString*)mKey
{
    return ZZDispatchOnMainThreadAndReturn(^id{
        NSArray* result = [TBMFriend MR_findByAttribute:TBMFriendAttributes.mkey withValue:mKey];
        TBMFriend* friendEntity = [result firstObject];

        return friendEntity;

    });
}

#pragma mark - Mapping

+ (TBMFriend*)entityFromModel:(ZZFriendDomainModel*)friendModel
{
    return ZZDispatchOnMainThreadAndReturn(^id{
        if (!ANIsEmpty(friendModel))
        {
            TBMFriend* friendEntity = [self friendEntityWithItemID:friendModel.idTbm];

            if (!friendEntity)
            {
                friendEntity = [TBMFriend MR_createEntityInContext:[self _context]];
            }
            return [ZZFriendModelsMapper fillEntity:friendEntity fromModel:friendModel];
        }
        return nil;

    });
}

+ (ZZFriendDomainModel*)modelFromEntity:(TBMFriend*)friendEntity
{
    return ZZDispatchOnMainThreadAndReturn(^id{
        if (!ANIsEmpty(friendEntity))
        {
            return [ZZFriendModelsMapper fillModel:[ZZFriendDomainModel new] fromEntity:friendEntity];
        }
        return nil;

    });
}

#pragma mark - Private

+ (NSManagedObjectContext*)_context
{
    return [ZZContentDataAccessor mainThreadContext];
}

@end
