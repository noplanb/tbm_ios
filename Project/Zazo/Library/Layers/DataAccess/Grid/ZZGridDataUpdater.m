//
//  ZZGridDataUpdater.m
//  Zazo
//
//  Created by ANODA on 9/30/15.
//  Copyright © 2015 No Plan B. All rights reserved.
//

#import "ZZGridDataUpdater.h"
#import "ZZGridDomainModel.h"
#import "ZZGridDataProvider+Entities.h"
#import "MagicalRecord.h"
#import "ZZGridModelsMapper.h"
#import "ZZFriendDataProvider+Entities.h"
#import "ZZContentDataAccessor.h"

@implementation ZZGridDataUpdater

+ (ZZGridDomainModel*)upsertModel:(ZZGridDomainModel *)gridModel
{
    return ZZDispatchOnMainThreadAndReturn(^id{
        
        TBMGridElement* gridEntity = nil;
        gridEntity =  [ZZGridDataProvider entityWithItemID:gridModel.itemID];
        if (!gridEntity)
        {
            gridEntity = [TBMGridElement MR_createEntityInContext:[self _context]];
        }
        [ZZGridModelsMapper fillEntity:gridEntity fromModel:gridModel];
        [gridEntity.managedObjectContext MR_saveToPersistentStoreAndWait];
        
        return [ZZGridDataProvider modelFromEntity:gridEntity];
    });
}

+ (ZZGridDomainModel*)updateRelatedUserOnItemID:(NSString *)itemID toValue:(ZZFriendDomainModel*)friendModel
{
    return ZZDispatchOnMainThreadAndReturn(^id{
        
        TBMGridElement* gridElementEntity = [ZZGridDataProvider entityWithItemID:itemID];
        gridElementEntity.friend = [ZZFriendDataProvider friendEntityWithItemID:friendModel.idTbm];
        [gridElementEntity.managedObjectContext MR_saveToPersistentStoreAndWait];
        return [ZZGridDataProvider modelFromEntity:gridElementEntity];
    });
}

#pragma mark - Update Grid models

+ (void)upsertGridModels:(NSArray*)models
{
    ANDispatchBlockToMainQueue(^{        
        [models enumerateObjectsUsingBlock:^(ZZGridDomainModel*  _Nonnull gridModel, NSUInteger idx, BOOL * _Nonnull stop) {
            [self upsertModel:gridModel];
        }];
    });
}


#pragma mark - Private

+ (NSManagedObjectContext*)_context
{
    return [ZZContentDataAccessor mainThreadContext];
}

@end
