//
//  ZZGridDataProvider.m
//  Zazo
//
//  Created by ANODA on 8/10/15.
//  Copyright (c) 2015 ANODA. All rights reserved.
//

#import "ZZGridDataProvider.h"
#import "ZZGridModelsMapper.h"
#import "MagicalRecord.h"
#import "ZZUserDataProvider.h"
#import "ZZGridUIConstants.h"
#import "ZZFriendDataProvider.h"
#import "ZZGridDataUpdater.h"
#import "ZZUserFriendshipStatusHandler.h"
#import "ZZContactDomainModel.h"
#import "ZZPhoneHelper.h"
#import "ZZContentDataAcessor.h"

@implementation ZZGridDataProvider

#pragma mark - Fetches

+ (NSArray*)loadAllGridsSortByIndex:(BOOL)shouldSortByIndex
{
    NSString* sortKey = shouldSortByIndex ? TBMGridElementAttributes.index : nil;
    NSArray* result = [TBMGridElement MR_findAllSortedBy:sortKey ascending:YES inContext:[self _context]];
    
    return [[result.rac_sequence map:^id(id value) {
        return [self modelFromEntity:value];
    }] array];
}

+ (TBMGridElement*)entityWithItemID:(NSString*)itemID
{
    NSManagedObject* object;
    if (!ANIsEmpty(itemID))
    {
        NSURL* objectURL = [NSURL URLWithString:[NSString stringWithString:itemID]];
        NSManagedObjectContext* context = [self _context];
        NSManagedObjectID* objectID = [context.persistentStoreCoordinator managedObjectIDForURIRepresentation:objectURL];
        NSError* error = nil;
        if (!ANIsEmpty(objectID))
        {
            object = [context existingObjectWithID:objectID error:&error];
        }
    }
    return (TBMGridElement*)object;
}

+ (ZZGridDomainModel*)modelWithIndex:(NSInteger)index
{
    NSPredicate* predicate = [NSPredicate predicateWithFormat:@"%K = %@", TBMGridElementAttributes.index, @(index)];
    TBMGridElement* entity = [[TBMGridElement MR_findAllWithPredicate:predicate inContext:[self _context]] firstObject];
    
    return [self modelFromEntity:entity];
}

+ (ZZGridDomainModel*)modelWithRelatedUserID:(NSString*)userID
{
    TBMFriend* userEntity = [ZZFriendDataProvider friendEntityWithItemID:userID];
    
    NSPredicate* predicate = [NSPredicate predicateWithFormat:@"%K = %@", TBMGridElementRelationships.friend, userEntity];
    TBMGridElement* entity = [[TBMGridElement MR_findAllWithPredicate:predicate inContext:[self _context]] firstObject];
    
    if (entity)
    {
        return [self modelFromEntity:entity];
    }
    return nil;
}

+ (BOOL)isRelatedUserOnGridWithID:(NSString*)userID
{
    ZZGridDomainModel* model = [self modelWithRelatedUserID:userID];
    return (model != nil);
}

+ (ZZGridDomainModel*)loadFirstEmptyGridElement
{
    NSPredicate* creatorWithNilId = [NSPredicate predicateWithFormat:@"%K = nil", TBMGridElementRelationships.friend];
    NSPredicate* creatorWithNullId = [NSPredicate predicateWithFormat:@"%K = NULL", TBMGridElementRelationships.friend];
    NSPredicate* creatorWithEmptyStringId = [NSPredicate predicateWithFormat:@"%K = ''", TBMGridElementRelationships.friend];
    
    NSPredicate* excludeCreator = [NSCompoundPredicate orPredicateWithSubpredicates:@[creatorWithNilId, creatorWithNullId, creatorWithEmptyStringId]];
    
    NSArray* result = [TBMGridElement MR_findAllSortedBy:TBMGridElementAttributes.index
                                               ascending:YES
                                           withPredicate:excludeCreator
                                               inContext:[self _context]];
    
    NSArray* models = [[result.rac_sequence map:^id(id value) {
        return [self modelFromEntity:value];
    }] array];
    
    return [models firstObject];
}

+ (ZZGridDomainModel*)modelWithEarlierLastActionFriend
{
    NSString* keypath = [NSString stringWithFormat:@"%@.%@", TBMGridElementRelationships.friend, TBMFriendAttributes.timeOfLastAction];
    NSArray* items = [TBMGridElement MR_findAllSortedBy:keypath ascending:YES inContext:[self _context]];
    ZZGridDomainModel* model = [self modelFromEntity:[items firstObject]];
    return model;
}

+ (ZZGridDomainModel*)modelWithContact:(ZZContactDomainModel*)contactModel
{
    TBMGridElement* entity = nil;
    if (!ANIsEmpty(contactModel.primaryPhone.contact))
    {
        NSString* phone = [contactModel.primaryPhone.contact stringByReplacingOccurrencesOfString:@" " withString:@""];
        NSString* keypath = [NSString stringWithFormat:@"%@.%@", TBMGridElementRelationships.friend, TBMFriendAttributes.mobileNumber];
        NSPredicate* predicate = [NSPredicate predicateWithFormat:@"%K = %@", keypath, phone];
        NSArray* items = [TBMGridElement MR_findAllWithPredicate:predicate inContext:[self _context]];
        entity = [items firstObject];
    }
    if (entity)
    {
        return [self modelFromEntity:entity];
    }
    return nil;
}

+ (NSArray*)loadOrCreateGridModelsWithCount:(NSInteger)gridModelsCount
{
    NSArray* allfriends = [ZZFriendDataProvider loadAllFriends];
    NSMutableArray* filteredFriends = [NSMutableArray new];
    
    [allfriends enumerateObjectsUsingBlock:^(ZZFriendDomainModel* friendModel, NSUInteger idx, BOOL * _Nonnull stop) {
    
        if ([ZZUserFriendshipStatusHandler shouldFriendBeVisible:friendModel])
        {
            [filteredFriends addObject:friendModel];
        }
    }];
    //TODO: sort descriptor
    [filteredFriends sortedArrayUsingComparator:^NSComparisonResult(ZZFriendDomainModel* obj1, ZZFriendDomainModel* obj2) {
        return [obj1.lastActionTimestamp compare:obj2.lastActionTimestamp];
    }];
    
    NSArray* gridStoredModels = [ZZGridDataProvider loadAllGridsSortByIndex:YES];
    NSMutableArray* gridModels = [NSMutableArray array];
    
    for (NSInteger count = 0; count < gridModelsCount; count++)
    {
        ZZGridDomainModel* model;
        if (gridStoredModels.count > count)
        {
            model = gridStoredModels[count];
        }
        else
        {
            model = [ZZGridDomainModel new];
            model.index = count;
        }
        
        if (filteredFriends.count > count)
        {
            if (ANIsEmpty(model.relatedUser))
            {
                model.relatedUser = [ZZFriendDataProvider lastActionFriendWihoutGrid];
            }
        }
        model = [ZZGridDataUpdater upsertModel:model];
        [gridModels addObject:model];
    }
    return gridModels;
}


#pragma mark - Mapping

+ (ZZGridDomainModel*)modelFromEntity:(TBMGridElement*)entity
{
    return [ZZGridModelsMapper fillModel:[ZZGridDomainModel new] fromEntity:entity];
}

+ (TBMGridElement *)findWithIntIndex:(NSInteger)i
{
    NSPredicate* predicate = [NSPredicate predicateWithFormat:@"%K = %@", TBMGridElementAttributes.index, @(i)];
    return [[TBMGridElement MR_findAllWithPredicate:predicate inContext:[self _context]] firstObject];
}

+ (TBMGridElement *)findWithFriend:(TBMFriend*)item
{
    NSPredicate* predicate = [NSPredicate predicateWithFormat:@"%K = %@", TBMGridElementRelationships.friend, item];
    return [[TBMGridElement MR_findAllWithPredicate:predicate inContext:[self _context]] firstObject];
}


#pragma mark - Entities

+ (BOOL)friendIsOnGrid:(TBMFriend *)friend
{
    return [self findWithFriend:friend] != nil;
}

+ (BOOL)hasSentVideos:(NSUInteger)index
{
    TBMFriend *friend = [self findWithIntIndex:index].friend;
    return [friend hasOutgoingVideo];
}


#pragma mark - Private

+ (NSManagedObjectContext*)_context
{
    return [ZZContentDataAcessor contextForCurrentThread];
}

@end
