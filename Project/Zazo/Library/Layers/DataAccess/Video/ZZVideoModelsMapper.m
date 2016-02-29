//
//  ZZVideoModelsMapper.m
//  Zazo
//
//  Created by ANODA on 8/10/15.
//  Copyright (c) 2015 ANODA. All rights reserved.
//

#import "ZZVideoModelsMapper.h"
#import "ZZVideoDomainModel.h"
#import "TBMVideo.h"
#import "TBMFriend.h"
#import "ZZVideoDataProvider+Entities.h"

@implementation ZZVideoModelsMapper

+ (TBMVideo*)fillEntity:(TBMVideo*)videoEntity fromModel:(ZZVideoDomainModel*)videoModel
{
    videoEntity.videoId = videoModel.videoID;
    videoEntity.downloadRetryCount = @(videoModel.downloadRetryCount);
    videoEntity.status = @(videoModel.incomingStatusValue);
    
    return videoEntity;
}

+ (ZZVideoDomainModel*)fillModel:(ZZVideoDomainModel*)videoModel fromEntity:(TBMVideo*)videoEntity
{
    @try
    {
        videoModel.videoID = videoEntity.videoId;
        videoModel.downloadRetryCount = [videoEntity.downloadRetryCount integerValue];
        videoModel.incomingStatusValue = [videoEntity.status integerValue];
        videoModel.videoURL = [ZZVideoDataProvider videoUrlWithVideo:videoEntity];
        videoModel.relatedUserID = videoEntity.friend.idTbm;
    }
    @catch (NSException *exception)
    {
        videoModel = nil;
        ZZLogError(@"Exception: %@", exception);
    }
    @finally
    {
        return videoModel;
    }
}

@end
