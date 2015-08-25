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
    NSPredicate* predicate = [NSPredicate predicateWithFormat:@"%K = %@", TBMGridElementRelationships.friend, nil];
     NSArray* result = [TBMGridElement MR_findAllSortedBy:TBMGridElementAttributes.index
                                                ascending:YES
                                            withPredicate:predicate
                                                inContext:[self _context]];
    
    TBMGridElement* entity = [result firstObject];
    return [self modelFromEntity:entity];
}


#pragma mark - Mapping

+ (ZZGridDomainModel*)modelFromEntity:(TBMGridElement*)entity
{
    return [ZZGridModelsMapper fillModel:[ZZGridDomainModel new] fromEntity:entity];
}

+ (TBMGridElement*)entityFromModel:(ZZGridDomainModel*)model
{
    TBMGridElement* entity = [TBMGridElement an_objectWithItemID:model.idTbm context:[self _context] shouldCreate:YES];
    return [ZZGridModelsMapper fillEntity:entity fromModel:model];
}


#pragma mark - Private

+ (NSManagedObjectContext*)_context
{
    return [NSManagedObjectContext MR_context];
}

@end
