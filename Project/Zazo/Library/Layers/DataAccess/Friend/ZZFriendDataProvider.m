
//
//  ZZFriendDataProvider.m
//  Zazo
//
//  Created by ANODA on 8/10/15.
//  Copyright (c) 2015 ANODA. All rights reserved.
//

#import "ZZFriendDataProvider.h"
#import "TBMFriend.h"
#import "MagicalRecord.h"
#import "ZZFriendDomainModel.h"
#import "ZZFriendModelsMapper.h"
#import "ZZGridDataProvider.h"
#import "ZZGridDomainModel.h"
#import "ZZContentDataAcessor.h"
#import "ZZUserFriendshipStatusHandler.h"

@implementation ZZFriendDataProvider


#pragma mark - Load

+ (NSArray*)loadAllFriends
{
    [ZZContentDataAcessor refreshContext:[self _context]];
    
    NSArray* result = [TBMFriend MR_findAllInContext:[self _context]];
    return [[result.rac_sequence map:^id(id value) {
        return [self modelFromEntity:value];
    }] array];
}

+ (ZZFriendDomainModel*)friendWithOutgoingVideoItemID:(NSString*)videoItemID
{
    return [self _findFirstWithAttribute:TBMFriendAttributes.outgoingVideoId value:videoItemID];
}

+ (ZZFriendDomainModel*)friendWithItemID:(NSString*)itemID
{
    return [self _findFirstWithAttribute:TBMFriendAttributes.idTbm value:itemID];
}

+ (ZZFriendDomainModel*)friendWithMKeyValue:(NSString*)mKeyValue
{
    return [self _findFirstWithAttribute:TBMFriendAttributes.mkey value:mKeyValue];
}

+ (ZZFriendDomainModel*)lastActionFriendWihoutGrid
{
    NSArray* friendsOnGrid = [self friendsOnGrid];
    NSArray* friendsIDs = [friendsOnGrid valueForKeyPath:ZZFriendDomainModelAttributes.idTbm];
    NSPredicate* predicate = [NSPredicate predicateWithFormat:@"NOT (%K IN %@)", TBMFriendAttributes.idTbm, friendsIDs ? : @[]];
    
    NSArray* items = [TBMFriend MR_findAllSortedBy:TBMFriendAttributes.timeOfLastAction
                                         ascending:YES
                                     withPredicate:predicate
                                         inContext:[self _context]];
    
    __block ZZFriendDomainModel* nextFriend = nil;
    
    [items enumerateObjectsUsingBlock:^(TBMFriend*  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        
        ZZFriendDomainModel* model = [ZZFriendDataProvider modelFromEntity:obj];
        if ([ZZUserFriendshipStatusHandler shouldFriendBeVisible:model])
        {
            nextFriend = model;
            *stop = YES;
        }
    }];

    return nextFriend;
}

+ (BOOL)isFriendExistsWithItemID:(NSString*)itemID
{
    NSInteger count = 0;
    if (itemID)
    {
        NSPredicate* predicate = [NSPredicate predicateWithFormat:@"%K = %@", TBMFriendAttributes.idTbm, itemID];
        count = [TBMFriend MR_countOfEntitiesWithPredicate:predicate inContext:[self _context]];
    }
    return (count != 0);
}


#pragma mark - Entities

+ (TBMFriend*)friendEntityWithItemID:(NSString*)itemID
{
    NSArray* result = [TBMFriend MR_findByAttribute:TBMFriendAttributes.idTbm withValue:itemID inContext:[self _context]];
    TBMFriend* entity = [result firstObject];
    return entity;
}


#pragma mark - Count

+ (NSInteger)friendsCount
{
    return [TBMFriend MR_countOfEntitiesWithContext:[self _context]];
}


#pragma mark - Mapping

+ (TBMFriend*)entityFromModel:(ZZFriendDomainModel*)model
{
    if (!ANIsEmpty(model))
    {
        TBMFriend* entity = [self friendEntityWithItemID:model.idTbm];
        if (!entity)
        {
            entity = [TBMFriend MR_createEntityInContext:[self _context]];
        }
        return [ZZFriendModelsMapper fillEntity:entity fromModel:model];
    }
    return nil;
}

+ (ZZFriendDomainModel*)modelFromEntity:(TBMFriend*)entity
{
    if (!ANIsEmpty(entity))
    {
        return [ZZFriendModelsMapper fillModel:[ZZFriendDomainModel new] fromEntity:entity];
    }
    return nil;
}

+ (NSArray*)friendsOnGrid
{
    NSArray* gridModels = [ZZGridDataProvider loadAllGridsSortByIndex:NO];
    return [[gridModels.rac_sequence map:^id(ZZGridDomainModel* value) {
        return value.relatedUser;
    }] array];
}


#pragma mark - CRUD

+ (void)upsertFriendWithModel:(ZZFriendDomainModel*)model
{
    TBMFriend* entity = [self entityFromModel:model];
    [ZZFriendModelsMapper fillEntity:entity fromModel:model];
    [entity.managedObjectContext MR_saveToPersistentStoreAndWait];
}

+ (void)deleteFriendWithID:(NSString*)itemID
{
    TBMFriend* entity = [[TBMFriend MR_findByAttribute:TBMFriendAttributes.idTbm withValue:itemID inContext:[self _context]] firstObject];
    [entity MR_deleteEntityInContext:[self _context]];
    [[self _context] MR_saveToPersistentStoreAndWait];
}

+ (void)deleteAllFriendsModels
{
    [TBMFriend MR_truncateAllInContext:[self _context]];
    [[self _context] MR_saveToPersistentStoreAndWait];
}


#pragma mark - Private

+ (ZZFriendDomainModel*)_findFirstWithAttribute:(NSString*)attribute value:(NSString*)value
{
    NSArray* result = [TBMFriend MR_findByAttribute:attribute withValue:value inContext:[self _context]];
    TBMFriend* entity = [result firstObject];
    return [self modelFromEntity:entity];
}

+ (NSManagedObjectContext*)_context
{
    return [ZZContentDataAcessor contextForCurrentThread];
}


@end
