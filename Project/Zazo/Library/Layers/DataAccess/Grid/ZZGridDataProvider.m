//
//  ZZGridDataProvider.m
//  Zazo
//
//  Created by ANODA on 8/10/15.
//  Copyright (c) 2015 ANODA. All rights reserved.
//

#import "ZZGridDataProvider.h"
#import "ZZGridModelsMapper.h"
@import MagicalRecord;
#import "ZZFriendDataProvider+Entities.h"
#import "ZZGridDataUpdater.h"
#import "ZZContactDomainModel.h"
#import "ZZContentDataAccessor.h"

@implementation ZZGridDataProvider

#pragma mark - Fetches

+ (NSArray *)loadAllGridsSortByIndex:(BOOL)shouldSortByIndex
{
    return ZZDispatchOnMainThreadAndReturn(^id {

        NSString *sortKey = shouldSortByIndex ? TBMGridElementAttributes.index : nil;
        NSArray *result = [TBMGridElement MR_findAllSortedBy:sortKey ascending:YES inContext:[self _context]];

        return [[result.rac_sequence map:^id(id value) {
            return [self modelFromEntity:value];
        }] array];
    });

}

+ (TBMGridElement *)entityWithItemID:(NSString *)itemID
{
    return ZZDispatchOnMainThreadAndReturn(^id {

        NSManagedObject *object;
        if (!ANIsEmpty(itemID))
        {
            NSURL *objectURL = [NSURL URLWithString:[NSString stringWithString:itemID]];
            NSManagedObjectContext *context = [self _context];
            NSManagedObjectID *objectID = [context.persistentStoreCoordinator managedObjectIDForURIRepresentation:objectURL];
            NSError *error = nil;
            if (!ANIsEmpty(objectID))
            {
                object = [context existingObjectWithID:objectID error:&error];
            }
        }
        return (TBMGridElement *)object;
    });

}


+ (ZZGridDomainModel *)modelWithRelatedUserID:(NSString *)userID
{
    return ZZDispatchOnMainThreadAndReturn(^id {

        TBMFriend *userEntity = [ZZFriendDataProvider friendEntityWithItemID:userID];

        if (userEntity == nil)
        {
            ZZLogWarning(@"modelWithRelatedUserID: userEntity == nil")
            return nil;
        }
        
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"%K = %@", TBMGridElementRelationships.friend, userEntity];
        TBMGridElement *entity = [[TBMGridElement MR_findAllWithPredicate:predicate inContext:[self _context]] firstObject];

        if (entity)
        {
            return [self modelFromEntity:entity];
        }
        return nil;
    });
}

+ (ZZGridDomainModel *)modelWithFriend:(TBMFriend *)friendEntity
{
    return ZZDispatchOnMainThreadAndReturn(^id {

        ZZGridDomainModel *gridModel = nil;

        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"%K = %@", TBMGridElementRelationships.friend, friendEntity];
        TBMGridElement *gridElementEntity = [[TBMGridElement MR_findAllWithPredicate:predicate inContext:[self _context]] firstObject];

        if (gridElementEntity)
        {
            gridModel = [self modelFromEntity:gridElementEntity];
        }

        return gridModel;
    });

}

+ (BOOL)isRelatedUserOnGridWithID:(NSString *)userID
{
    ZZGridDomainModel *gridModel = [self modelWithRelatedUserID:userID];
    return (gridModel != nil);
}

+ (ZZGridDomainModel *)loadFirstEmptyGridElement
{
    return ZZDispatchOnMainThreadAndReturn(^id {
        NSPredicate *creatorWithNilId = [NSPredicate predicateWithFormat:@"%K = nil", TBMGridElementRelationships.friend];
        NSPredicate *creatorWithNullId = [NSPredicate predicateWithFormat:@"%K = NULL", TBMGridElementRelationships.friend];
        NSPredicate *creatorWithEmptyStringId = [NSPredicate predicateWithFormat:@"%K = ''", TBMGridElementRelationships.friend];

        NSPredicate *excludeCreator = [NSCompoundPredicate orPredicateWithSubpredicates:@[creatorWithNilId, creatorWithNullId, creatorWithEmptyStringId]];

        NSArray *result = [TBMGridElement MR_findAllSortedBy:TBMGridElementAttributes.index
                                                   ascending:YES
                                               withPredicate:excludeCreator
                                                   inContext:[self _context]];

        if (ANIsEmpty(result))
        {
            return nil;
        }

        return [self modelFromEntity:result.firstObject];
    });
}

+ (ZZGridDomainModel *)modelWithEarlierLastActionFriend
{
    return ZZDispatchOnMainThreadAndReturn(^id {

        NSString *keypath = [NSString stringWithFormat:@"%@.%@", TBMGridElementRelationships.friend, TBMFriendAttributes.timeOfLastAction];
        NSArray *items = [TBMGridElement MR_findAllSortedBy:keypath ascending:YES inContext:[self _context]];
        ZZGridDomainModel *gridModel = [self modelFromEntity:[items firstObject]];
        return gridModel;
    });
}

+ (ZZGridDomainModel *)modelWithContact:(ZZContactDomainModel *)contactModel
{
    return ZZDispatchOnMainThreadAndReturn(^id {

        TBMGridElement *gridElementEntity = nil;
        if (!ANIsEmpty(contactModel.primaryPhone.contact))
        {
            NSString *phone = [contactModel.primaryPhone.contact stringByReplacingOccurrencesOfString:@" " withString:@""];
            NSString *keypath = [NSString stringWithFormat:@"%@.%@", TBMGridElementRelationships.friend, TBMFriendAttributes.mobileNumber];
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"%K = %@", keypath, phone];
            NSArray *items = [TBMGridElement MR_findAllWithPredicate:predicate inContext:[self _context]];
            gridElementEntity = [items firstObject];
        }
        if (gridElementEntity)
        {
            return [self modelFromEntity:gridElementEntity];
        }
        return nil;
    });
}

+ (NSArray *)loadOrCreateGridModelsWithCount:(NSInteger)gridModelsCount
{
    return ZZDispatchOnMainThreadAndReturn(^id {


        NSArray *filteredFriends = [ZZFriendDataProvider allVisibleFriendModels];

        NSArray *gridStoredModels = [ZZGridDataProvider loadAllGridsSortByIndex:YES];
        NSMutableArray *gridModels = [NSMutableArray array];

        for (NSInteger count = 0; count < gridModelsCount; count++)
        {
            ZZGridDomainModel *gridModel;
            if (gridStoredModels.count > count)
            {
                gridModel = gridStoredModels[count];
            }
            else
            {
                gridModel = [ZZGridDomainModel new];
                gridModel.index = count;

            }

            if (filteredFriends.count > count)
            {
                if (ANIsEmpty(gridModel.relatedUser))
                {
                    gridModel.relatedUser = [ZZFriendDataProvider lastActionFriendWithoutGrid];
                }
            }
            gridModel = [ZZGridDataUpdater upsertModel:gridModel];
            [gridModels addObject:gridModel];
        }
        return gridModels;
    });
}


#pragma mark - Mapping

+ (ZZGridDomainModel *)modelFromEntity:(TBMGridElement *)gridElementEntity
{
    return ZZDispatchOnMainThreadAndReturn(^id {

        return [ZZGridModelsMapper fillModel:[ZZGridDomainModel new] fromEntity:gridElementEntity];
    });
}

#pragma mark - Private

+ (NSManagedObjectContext *)_context
{
    return [ZZContentDataAccessor mainThreadContext];
}

@end
