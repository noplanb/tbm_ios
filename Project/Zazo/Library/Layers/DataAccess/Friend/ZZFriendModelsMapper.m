//
//  ZZFriendModelsMapper.m
//  Zazo
//
//  Created by ANODA on 8/10/15.
//  Copyright (c) 2015 ANODA. All rights reserved.
//

#import "ZZFriendModelsMapper.h"
#import "TBMFriend.h"
#import "ZZFriendDomainModel.h"
#import "TBMVideo.h"
#import "ZZVideoDataProvider.h"

@implementation ZZFriendModelsMapper

+ (TBMFriend*)fillEntity:(TBMFriend*)entity fromModel:(ZZFriendDomainModel*)model
{
    entity.idTbm = model.idTbm;
    entity.firstName = model.firstName;
    entity.lastName = model.lastName;
    entity.hasApp = @(model.isHasApp);
    entity.mobileNumber = model.mobileNumber;
    
    entity.ckey = model.cKey;
    entity.mkey = model.mKey;
    
    entity.lastIncomingVideoStatus = @(model.lastIncomingVideoStatus);
    entity.lastVideoStatusEventType = @(model.lastVideoStatusEventType);

    entity.outgoingVideoId = model.outgoingVideoItemID;
    entity.outgoingVideoStatus = @(model.outgoingVideoStatus);
    
    entity.timeOfLastAction = model.lastActionTimestamp;
    entity.uploadRetryCount = @(model.uploadRetryCount);
    
    return entity;
}

+ (ZZFriendDomainModel*)fillModel:(ZZFriendDomainModel*)model fromEntity:(TBMFriend*)entity
{
    @try
    {
        model.idTbm = entity.idTbm;
        model.firstName = entity.firstName;
        model.lastName = entity.lastName;
        model.hasApp = [entity.hasApp boolValue];
        model.mobileNumber = entity.mobileNumber;
        
        model.cKey = entity.ckey;
        model.mKey = entity.mkey;
        
        model.lastIncomingVideoStatus = [entity.lastIncomingVideoStatus integerValue];
        model.lastVideoStatusEventType = [entity.lastVideoStatusEventType integerValue];
        
        model.outgoingVideoItemID = entity.outgoingVideoId;
        model.outgoingVideoStatus = [entity.outgoingVideoStatus integerValue];
        
        model.lastActionTimestamp = entity.timeOfLastAction;
        model.uploadRetryCount = [entity.uploadRetryCount integerValue];
        model.videos = [[entity.videos.allObjects.rac_sequence map:^id(TBMVideo* value) {
            return [ZZVideoDataProvider modelFromEntity:value];
        }] array];
    }
    @catch (NSException *exception)
    {
        ANLogWarning(@"Exception: %@", exception);
    }
    @finally
    {
        return model;
    }
}

@end
