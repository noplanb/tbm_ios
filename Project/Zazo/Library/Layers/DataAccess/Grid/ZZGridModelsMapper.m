//
//  ZZGridModelsMapper.m
//  Zazo
//
//  Created by ANODA on 8/10/15.
//  Copyright (c) 2015 ANODA. All rights reserved.
//

#import "ZZGridModelsMapper.h"
#import "ZZUserDataProvider.h"
#import "ZZFriendDataProvider+Entities.h"
#import "TBMGridElement.h"
#import "ZZGridDomainModel.h"


@implementation ZZGridModelsMapper

+ (TBMGridElement*)fillEntity:(TBMGridElement*)entity fromModel:(ZZGridDomainModel*)model
{
    entity.index = @(model.index);
    entity.friend = [ZZFriendDataProvider entityFromModel:model.relatedUser];
    
    return entity;
}

+ (ZZGridDomainModel*)fillModel:(ZZGridDomainModel*)model fromEntity:(TBMGridElement*)entity
{
    if (!entity)
    {
        return nil;
    }
    
    @try
    {
        model.index = [entity.index integerValue];
        model.itemID = entity.objectID.URIRepresentation.absoluteString;
        model.relatedUser = [ZZFriendDataProvider modelFromEntity:entity.friend];
    }
    @catch (NSException *exception)
    {
        model = nil;
        ZZLogError(@"Exception: %@", exception);
    }
    @finally
    {
        return model;
    }
}

@end
