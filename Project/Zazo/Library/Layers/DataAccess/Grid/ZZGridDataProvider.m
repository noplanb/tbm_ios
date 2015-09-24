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
#import "NSManagedObject+ANAdditions.h"
#import "ZZUserDataProvider.h"
#import "ZZGridUIConstants.h"

@implementation ZZGridDataProvider

+ (ZZGridDomainModel*)upsertModel:(ZZGridDomainModel *)model
{
    TBMGridElement* entity;
    if (ANIsEmpty(model.itemID))
    {
//        model.itemID = [NSString stringWithFormat:@"CREATE_%@", [self _randomStringWithLength:32]];
        entity = [TBMGridElement MR_createEntityInContext:[self _context]];
    }
    else
    {
        entity =  [self entityWithItemID:model.itemID];
    }
    [ZZGridModelsMapper fillEntity:entity fromModel:model];
    [entity.managedObjectContext MR_saveToPersistentStoreAndWait];
    
    return [self modelFromEntity:entity];
}

+ (void)deleteModel:(ZZGridDomainModel*)model
{
    TBMGridElement* entity = [self entityWithItemID:model.itemID];
    NSManagedObjectContext* context = entity.managedObjectContext;
    [entity MR_deleteEntityInContext:context];
    [context MR_saveToPersistentStoreAndWait];
}


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

+ (ZZGridDomainModel*)modelWithRelatedUser:(ZZUserDomainModel*)user
{
    TBMUser* userEntity = [ZZUserDataProvider entityFromModel:user];
    
    NSPredicate* predicate = [NSPredicate predicateWithFormat:@"%K = %@", TBMGridElementRelationships.friend, userEntity];
    TBMGridElement* entity = [[TBMGridElement MR_findAllWithPredicate:predicate inContext:[self _context]] firstObject];
    
    return [self modelFromEntity:entity];
}

+ (BOOL)isRelatedUserOnGrid:(ZZUserDomainModel*)user
{
    ZZGridDomainModel* model = [self modelWithRelatedUser:user];
    return (model != nil);
}

+ (ZZGridDomainModel*)loadFirstEmptyGridElement
{
    NSPredicate* creatorWithNilId = [NSPredicate predicateWithFormat:@"%K = nil", TBMGridElementRelationships.friend];
    NSPredicate* creatorWithNullId = [NSPredicate predicateWithFormat:@"%K = NULL", TBMGridElementRelationships.friend];
    NSPredicate* creatorWithEmptyStringId = [NSPredicate predicateWithFormat:@"%K = ''", TBMGridElementRelationships.friend];
    NSPredicate* excludeCreator = [NSCompoundPredicate orPredicateWithSubpredicates:@[creatorWithNilId, creatorWithNullId, creatorWithEmptyStringId]];
    
    //    NSPredicate* predicate = [NSPredicate predicateWithFormat:@"%K = %@", TBMGridElementRelationships.friend, @"nil"];
    NSArray* result = [TBMGridElement MR_findAllSortedBy:TBMGridElementAttributes.index
                                               ascending:YES
                                           withPredicate:excludeCreator
                                               inContext:[self _context]];
    
    NSInteger index = kNextGridElementIndexFromCount(result.count);
    if (index != NSNotFound && result.count > index)
    {
        TBMGridElement* rightOrderEntity = result[index];
        return [self modelFromEntity:rightOrderEntity];
    }
    return nil;
}


#pragma mark - Mapping

+ (ZZGridDomainModel*)modelFromEntity:(TBMGridElement*)entity
{
    return [ZZGridModelsMapper fillModel:[ZZGridDomainModel new] fromEntity:entity];
}

+ (TBMGridElement*)entityFromModel:(ZZGridDomainModel*)model
{
    TBMGridElement* entity = [self entityFromModel:model];
    return [ZZGridModelsMapper fillEntity:entity fromModel:model];
}


#pragma mark - Private

+ (NSString*)_randomStringWithLength:(NSInteger)len
{
    NSString *letters = @"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";
    NSMutableString *randomString = [NSMutableString stringWithCapacity:len];
    for (int i = 0; i < len; i++)
    {
        [randomString appendFormat: @"%C", [letters characterAtIndex:arc4random_uniform((uint32_t)[letters length])]];
    }
    return randomString;
}

+ (NSManagedObjectContext*)_context
{
    return [NSManagedObjectContext MR_rootSavingContext];
}

@end
