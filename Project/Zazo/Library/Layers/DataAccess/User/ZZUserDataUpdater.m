//
//  ZZUserDataUpdater.m
//  Zazo
//
//  Created by Vitaly Cherevaty on 12/9/15.
//  Copyright © 2015 No Plan B. All rights reserved.
//

#import "ZZUserDataUpdater.h"
#import "ZZUserDataProvider.h"
#import "ZZUserDataProvider+Private.h"

#import "ZZUserModelsMapper.h"
#import "ZZContentDataAcessor.h"

#import "MagicalRecord.h"

@implementation ZZUserDataUpdater

+ (ZZUserDomainModel*)upsertUserWithModel:(ZZUserDomainModel*)model
{
    TBMUser* entity = [ZZUserDataProvider authenticatedEntity];
    if (!entity)
    {
        entity = [TBMUser MR_createEntityInContext:[self _context]];
    }
    [ZZUserModelsMapper fillEntity:entity fromModel:model];
    [entity.managedObjectContext MR_saveToPersistentStoreAndWait];
    return [ZZUserDataProvider modelFromEntity:entity];
}

#pragma mark - Private

+ (NSManagedObjectContext*)_context
{
    return [ZZContentDataAcessor contextForCurrentThread];
}

@end
