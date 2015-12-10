//
//  ZZVideoModelsMapper.m
//  Zazo
//
//  Created by ANODA on 8/10/15.
//  Copyright (c) 2015 ANODA. All rights reserved.
//

#import "ZZVideoModelsMapper.h"
#import "ZZVideoDomainModel.h"
#import "ZZVideoDataProvider.h"
#import "ZZFriendDataProvider.h"
#import "ZZFriendDataProvider+Private.h"

#import "TBMVideo.h"
#import "TBMFriend.h"

@implementation ZZVideoModelsMapper

+ (TBMVideo*)fillEntity:(TBMVideo*)entity fromModel:(ZZVideoDomainModel*)model
{
    entity.videoId = model.videoID;
    entity.downloadRetryCount = @(model.downloadRetryCount);
    entity.status = @(model.incomingStatusValue);
    
    return entity;
}

+ (ZZVideoDomainModel*)fillModel:(ZZVideoDomainModel*)model fromEntity:(TBMVideo*)entity
{
    @try
    {
        model.videoID = entity.videoId;
        model.downloadRetryCount = [entity.downloadRetryCount integerValue];
        model.incomingStatusValue = [entity.status integerValue];
        model.relatedUserID = entity.friend.idTbm;
        model.videoURL = [ZZVideoDataProvider videoUrlWithVideo:model];
        
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
