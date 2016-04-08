//
//  ZZUserDataProvider.m
//  Zazo
//
//  Created by ANODA on 8/10/15.
//  Copyright (c) 2015 ANODA. All rights reserved.
//

#import "ZZUserDataProvider+Entities.h"
#import "ZZUserModelsMapper.h"
@import MagicalRecord;
#import "ZZContentDataAccessor.h"

@implementation ZZUserDataProvider

+ (ZZUserDomainModel*)authenticatedUser
{
    return ZZDispatchOnMainThreadAndReturn(^id{
        TBMUser* user = [self _authenticatedEntity];
        return [self modelFromEntity:user];
    });
}

+ (TBMUser*)_authenticatedEntity
{
    NSArray* users = [TBMUser MR_findAllInContext:[self _context]];
    if (users.count > 1)
    {
        ZZLogError(@"Model dupples founded %@ %@", NSStringFromSelector(_cmd), [users debugDescription]);
    }
    TBMUser* user = [users lastObject];
    return user;
}

//+ (TBMUser*)entityFromModel:(ZZUserDomainModel*)model
//{
//    TBMUser* entity = [self _authenticatedEntity];
//    if (!entity)
//    {
//        entity = [TBMUser MR_createEntityInContext:[self _context]];
//        [entity.managedObjectContext MR_saveToPersistentStoreAndWait];
//    }
//    return [ZZUserModelsMapper fillEntity:entity fromModel:model];
//}

+ (ZZUserDomainModel*)modelFromEntity:(TBMUser*)userEntity
{
    return ZZDispatchOnMainThreadAndReturn(^id{
        return [ZZUserModelsMapper fillModel:[ZZUserDomainModel new] fromEntity:userEntity];
    });
}

+ (ZZUserDomainModel*)upsertUserWithModel:(ZZUserDomainModel*)userModel
{
    return ZZDispatchOnMainThreadAndReturn(^id{
        TBMUser* userEntity = [self _authenticatedEntity];
        if (!userEntity)
        {
            userEntity = [TBMUser MR_createEntityInContext:[self _context]];
        }
        [ZZUserModelsMapper fillEntity:userEntity fromModel:userModel];
        [userEntity.managedObjectContext MR_saveToPersistentStoreAndWait];
        return [self modelFromEntity:userEntity];

    });
}


#pragma mark - Private

+ (NSManagedObjectContext*)_context
{
    return [ZZContentDataAccessor mainThreadContext];

}

@end
