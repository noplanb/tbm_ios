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
#import "ZZContentDataAcessor.h"

@implementation ZZGridDataUpdater

+ (ZZGridDomainModel*)upsertModel:(ZZGridDomainModel *)model
{
    return ZZDispatchOnMainThreadAndReturn(^id{
        
        TBMGridElement* entity = nil;
        entity =  [ZZGridDataProvider entityWithItemID:model.itemID];
        if (!entity)
        {
            entity = [TBMGridElement MR_createEntityInContext:[self _context]];
        }
        [ZZGridModelsMapper fillEntity:entity fromModel:model];
        [entity.managedObjectContext MR_saveToPersistentStoreAndWait];
        
        return [ZZGridDataProvider modelFromEntity:entity];
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
        [models enumerateObjectsUsingBlock:^(ZZGridDomainModel*  _Nonnull domainModel, NSUInteger idx, BOOL * _Nonnull stop) {
            [self upsertModel:domainModel];
        }];
    });
}


#pragma mark - Private

+ (NSManagedObjectContext*)_context
{
    return [ZZContentDataAcessor mainThreadContext];
}

@end
