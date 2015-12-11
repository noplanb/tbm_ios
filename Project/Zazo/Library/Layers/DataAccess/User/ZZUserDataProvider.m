//
//  ZZUserDataProvider.m
//  Zazo
//
//  Created by ANODA on 8/10/15.
//  Copyright (c) 2015 ANODA. All rights reserved.
//

#import "ZZUserDataProvider.h"
#import "ZZUserModelsMapper.h"
#import "ZZContentDataAcessor.h"

#import "MagicalRecord.h"

@implementation ZZUserDataProvider

+ (ZZUserDomainModel*)authenticatedUser
{
    TBMUser* user = [self authenticatedEntity];
    return [self modelFromEntity:user];
}

+ (TBMUser*)authenticatedEntity
{
    NSArray* users = [TBMUser MR_findAllInContext:[self _context]];
    if (users.count > 1)
    {
        ZZLogError(@"Model dupples founded %@ %@", NSStringFromSelector(_cmd), [users debugDescription]);
    }
    TBMUser* user = [users lastObject];
    return user;
}

+ (ZZUserDomainModel*)modelFromEntity:(TBMUser*)entity
{
    return [ZZUserModelsMapper fillModel:[ZZUserDomainModel new] fromEntity:entity];
}

#pragma mark - Private

+ (NSManagedObjectContext*)_context
{
    return [ZZContentDataAcessor contextForCurrentThread];
}

@end