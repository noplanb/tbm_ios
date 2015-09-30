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
        NSManagedObjectContext* context = [NSManagedObjectContext MR_rootSavingContext];
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
    
    return [self modelFromEntity:entity];
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


#pragma mark - Mapping

+ (ZZGridDomainModel*)modelFromEntity:(TBMGridElement*)entity
{
    return [ZZGridModelsMapper fillModel:[ZZGridDomainModel new] fromEntity:entity];
}


#pragma mark - Private

+ (NSManagedObjectContext*)_context
{
    return [NSManagedObjectContext MR_rootSavingContext];
}

@end
