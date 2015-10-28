//
//  ZZUserDataProvider.m
//  Zazo
//
//  Created by ANODA on 8/10/15.
//  Copyright (c) 2015 ANODA. All rights reserved.
//

#import "ZZUserDataProvider.h"
#import "ZZUserModelsMapper.h"
#import "MagicalRecord.h"
#import "ZZContentDataAcessor.h"

@implementation ZZUserDataProvider

+ (ZZUserDomainModel*)authenticatedUser
{
    TBMUser* user = [self _authenticatedEntity];
    return [self modelFromEntity:user];
}

+ (TBMUser*)_authenticatedEntity
{
    NSArray* users = [TBMUser MR_findAllInContext:[self _context]];
    if (users.count > 1)
    {
        OB_ERROR(@"Model dupples founded %@ %@", NSStringFromSelector(_cmd), [users debugDescription]);
    }
    TBMUser* user = [users lastObject];
    return user;
}

+ (TBMUser*)entityFromModel:(ZZUserDomainModel*)model
{
    TBMUser* entity = [self _authenticatedEntity];
    if (!entity)
    {
        entity = [TBMUser MR_createEntityInContext:[self _context]];
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
    TBMUser* entity = [self _authenticatedEntity];
    if (!entity)
    {
        entity = [TBMUser MR_createEntityInContext:[self _context]];
    }
    [ZZUserModelsMapper fillEntity:entity fromModel:model];
    [entity.managedObjectContext MR_saveToPersistentStoreAndWait];
    return [self modelFromEntity:entity];
}

#pragma mark - Private

+ (NSManagedObjectContext*)_context
{
    return [ZZContentDataAcessor contextForCurrentThread];
}

@end
