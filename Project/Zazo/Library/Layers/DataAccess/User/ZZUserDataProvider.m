//
//  ZZUserDataProvider.m
//  Zazo
//
//  Created by ANODA on 8/10/15.
//  Copyright (c) 2015 ANODA. All rights reserved.
//

#import "ZZUserDataProvider.h"
#import "ZZUserModelsMapper.h"
#import "NSManagedObject+ANAdditions.h"
#import "MagicalRecord.h"

@implementation ZZUserDataProvider

+ (ZZUserDomainModel*)authenticatedUser
{
    NSArray* users = [TBMUser MR_findAllInContext:[self _context]];
    if (users.count > 1)
    {
        // TODO: dispatch message with dupples
    }
    TBMUser* user = [users firstObject];
    return [self modelFromEntity:user];
}

+ (TBMUser*)entityFromModel:(ZZUserDomainModel*)model
{
    TBMUser* entity = [[TBMUser MR_findByAttribute:TBMUserAttributes.mkey withValue:model.mkey] firstObject];
    if (!entity)
    {
        entity = [TBMUser MR_createEntityInContext:[self _context]];
        entity.idTbm = @"temporary";
        [entity.managedObjectContext MR_saveToPersistentStoreAndWait];
    }
    
    return [ZZUserModelsMapper fillEntity:entity fromModel:model];
}

+ (ZZUserDomainModel*)modelFromEntity:(TBMUser*)entity
{
    return [ZZUserModelsMapper fillModel:[ZZUserDomainModel new] fromEntity:entity];
}

+ (ZZUserDomainModel*)upsertUserWithModel:(ZZUserDomainModel*)model
{
    TBMUser* entity = [[TBMUser MR_findByAttribute:TBMUserAttributes.mkey withValue:model.mkey] firstObject];
    if (!entity)
    {
        entity = [TBMUser MR_createEntityInContext:[self _context]];
        entity.idTbm = @"temporary";
        [entity.managedObjectContext MR_saveToPersistentStoreAndWait];
    }
    [ZZUserModelsMapper fillEntity:entity fromModel:model];
    [[self _context] MR_saveToPersistentStoreAndWait];
    return [self modelFromEntity:entity];
}

#pragma mark - Private

+ (NSManagedObjectContext*)_context
{
    return [NSManagedObjectContext MR_context];
}

@end
