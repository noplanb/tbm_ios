//
//  ZZVideoDataUpdater.m
//  Zazo
//
//  Created by ANODA on 10/28/15.
//  Copyright © 2015 No Plan B. All rights reserved.
//

#import "ZZVideoDataUpdater.h"
#import "TBMVideo.h"
#import "TBMFriend.h"
#import "MagicalRecord.h"
#import "ZZVideoDataProvider+Entities.h"
#import "ZZFriendDataProvider+Entities.h"
#import "ZZThumbnailGenerator.h"
#import "ZZVideoDomainModel.h"
#import "ZZVideoModelsMapper.h"
#import "ZZContentDataAccessor.h"
#import "ZZFriendDomainModel.h"

@implementation ZZVideoDataUpdater

#pragma mark Update methods

+ (void)_updateVideoWithID:(NSString *)videoID usingBlock:(void (^)(TBMVideo *videoEntity))updateBlock
{
    ANDispatchBlockToMainQueue(^{
        TBMVideo* videoEntity = [ZZVideoDataProvider entityWithID:videoID];
        updateBlock(videoEntity);
        [videoEntity.managedObjectContext MR_saveToPersistentStoreAndWait];
    });
}

+ (void)updateVideoWithID:(NSString *)videoID setIncomingStatus:(ZZVideoIncomingStatus)videoStatus
{
    [self _updateVideoWithID:videoID usingBlock:^(TBMVideo *videoEntity) {
        videoEntity.statusValue = videoStatus;
    }];
}

+ (void)updateVideoWithID:(NSString *)videoID setDownloadRetryCount:(NSUInteger)count
{
    [self _updateVideoWithID:videoID usingBlock:^(TBMVideo *videoEntity) {
        videoEntity.downloadRetryCount = @(count);
    }];
}

#pragma mark - Delete Video Methods

+ (void)deleteAllViewedOrFailedVideoWithFriendID:(NSString*)friendID
{
    ZZLogInfo(@"deleteAllViewedVideos");
    
    NSArray* sortedVideos = [ZZVideoDataProvider sortedIncomingVideosForUserWithID:friendID];
    
    for (ZZVideoDomainModel *videoModel in sortedVideos)
    {
        if (videoModel.incomingStatusValue == ZZVideoIncomingStatusViewed ||
            videoModel.incomingStatusValue == ZZVideoIncomingStatusFailedPermanently)
        {
            [self _deleteVideo:videoModel];
        }
    }
}

+ (void)_deleteVideo:(ZZVideoDomainModel *)videoModel {
    [ZZVideoDataUpdater _deleteFilesForVideo:videoModel];

    ANDispatchBlockToMainQueue(^{
        TBMVideo *videoEntity = [ZZVideoDataProvider entityWithID:videoModel.videoID];
        TBMFriend *friendEntity = videoEntity.friend;
        
        [friendEntity removeVideosObject:videoEntity];
        [videoEntity MR_deleteEntity];
        
        [friendEntity.managedObjectContext MR_saveToPersistentStoreAndWait];
    });
}

+ (void)_deleteVideoFileWithVideo:(ZZVideoDomainModel*)videoModel
{
    ZZLogInfo(@"deleteVideoFile");
    NSFileManager *fm = [NSFileManager defaultManager];
    NSError *error = nil;
    [fm removeItemAtURL:[ZZVideoDataProvider videoUrlWithVideoModel:videoModel] error:&error];
}

+ (void)_deleteFilesForVideo:(ZZVideoDomainModel*)videoModel
{
    [self _deleteVideoFileWithVideo:videoModel];
    [ZZThumbnailGenerator deleteThumbFileForVideo:videoModel];
}

#pragma mark - Private

+ (NSManagedObjectContext*)_context
{
    return [ZZContentDataAccessor mainThreadContext];
}


@end
