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

+ (TBMUser*)entityFromModel:(ZZUserDomainModel*)model
{
    TBMUser* entity = [TBMUser an_objectWithItemID:model.idTbm context:[self _context]];
    return [ZZUserModelsMapper fillEntity:entity fromModel:model];
}

+ (ZZUserDomainModel*)modelFromEntity:(TBMUser*)entity
{
    return [ZZUserModelsMapper fillModel:[ZZUserDomainModel new] fromEntity:entity];
}

+ (void)upsertUserWithModel:(ZZUserDomainModel*)model
{
    TBMUser* entity = [TBMUser an_objectWithItemID:model.idTbm context:[self _context]];
    [ZZUserModelsMapper fillEntity:entity fromModel:model];
    [[self _context] MR_saveToPersistentStoreAndWait];
}

#pragma mark - Private

+ (NSManagedObjectContext*)_context
{
    return [NSManagedObjectContext MR_context];
}

@end
