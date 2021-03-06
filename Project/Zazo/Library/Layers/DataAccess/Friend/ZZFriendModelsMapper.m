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
#import "ZZVideoDataProvider+Entities.h"
#import "ZZVideoDomainModel.h"
#import "ZZFriendDataHelper.h"
#import "ZZFriendDataHelper+Entities.h"
#import "ZZMessageDataProvider.h"


@implementation ZZFriendModelsMapper

+ (TBMFriend *)fillEntity:(TBMFriend *)entity fromModel:(ZZFriendDomainModel *)model
{
    entity.idTbm = model.idTbm;
    entity.firstName = model.firstName;
    entity.lastName = model.lastName;
    entity.hasApp = @(model.isHasApp);
    entity.mobileNumber = model.mobileNumber;
    entity.cid = @(model.cid);
    entity.ckey = model.cKey;
    entity.mkey = model.mKey;

    entity.lastIncomingVideoStatus = @(model.lastIncomingVideoStatus);
    entity.lastVideoStatusEventType = @(model.lastVideoStatusEventType);
    entity.lastEventType = @(model.lastEventType);
    
    entity.outgoingVideoId = model.outgoingVideoItemID;
    entity.outgoingVideoStatusValue = model.lastOutgoingVideoStatus;
    entity.everSent = @(model.everSent);

    entity.timeOfLastAction = model.lastActionTimestamp;
    entity.uploadRetryCount = @(model.uploadRetryCount);

    entity.friendshipStatus = model.friendshipStatus;

    entity.friendshipCreatorMKey = model.friendshipCreatorMkey;
    entity.isFriendshipCreator = @([model isCreator]);

    entity.abilities = @(model.abilities);
    entity.avatarTimestampValue = model.avatarTimestamp;
    
    return entity;
}

+ (ZZFriendDomainModel *)fillModel:(ZZFriendDomainModel *)model fromEntity:(TBMFriend *)entity
{
    @try
    {
        model.idTbm = entity.idTbm;
        model.firstName = entity.firstName;
        model.lastName = entity.lastName;
        model.hasApp = [entity.hasApp boolValue];
        model.mobileNumber = entity.mobileNumber;
        model.cid = [entity.cid integerValue];
        model.cKey = entity.ckey;
        model.mKey = entity.mkey;

        model.lastIncomingVideoStatus = [entity.lastIncomingVideoStatus integerValue];
        model.lastVideoStatusEventType = [entity.lastVideoStatusEventType integerValue];
        model.lastEventType = [entity.lastEventType integerValue];
        
        model.outgoingVideoItemID = entity.outgoingVideoId;
        model.lastOutgoingVideoStatus = [entity.outgoingVideoStatus integerValue];
        model.everSent = entity.everSent.boolValue;

        model.lastActionTimestamp = entity.timeOfLastAction;
        model.uploadRetryCount = [entity.uploadRetryCount integerValue];

        model.friendshipStatus = entity.friendshipStatus;

        model.videos = [ZZVideoDataProvider sortedIncomingVideosForUserWithID:entity.idTbm];
        model.messages = [ZZMessageDataProvider messagesOfFriendWithID:entity.idTbm newOnly:NO];
        
        model.hasOutgoingVideo = !ANIsEmpty(entity.outgoingVideoId);
        model.friendshipCreatorMkey = entity.friendshipCreatorMKey;
        model.avatarTimestamp = entity.avatarTimestamp.doubleValue;
        
        model.abilities = entity.abilitiesValue;
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
