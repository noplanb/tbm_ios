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

+ (void)deleteAllVideos {
    ANDispatchBlockToMainQueue(^{
        NSManagedObjectContext* context = [ZZContentDataAccessor mainThreadContext];
        [TBMVideo MR_truncateAllInContext:context];
        [context MR_saveToPersistentStoreAndWait];
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

+ (void)_updateVideoWithID:(NSString *)videoID usingBlock:(void (^)(TBMVideo *videoEntity))updateBlock
{
    ANDispatchBlockToMainQueue(^{
        TBMVideo* videoEntity = [ZZVideoDataProvider entityWithID:videoID];
        updateBlock(videoEntity);
        [videoEntity.managedObjectContext MR_saveToPersistentStoreAndWait];
    });
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

+ (void)_deleteVideo:(ZZVideoDomainModel *)videoModel
{
    ANDispatchBlockToMainQueue(^{
        TBMVideo *videoEntity = [ZZVideoDataProvider entityWithID:videoModel.videoID];
        TBMFriend *friendEntity = videoEntity.friend;
        
        videoEntity.statusValue = ZZVideoIncomingStatusGhost;
        
        [self _deleteOutdatedVideosInNeeded];
        
        [friendEntity.managedObjectContext MR_saveToPersistentStoreAndWait];
    });
}

+ (void)_deleteOutdatedVideosInNeeded
{
    ANDispatchBlockToMainQueue(^{
        NSPredicate *ghostStatus =
        [NSPredicate predicateWithFormat:@"%K == %@", TBMVideoAttributes.status, @(ZZVideoIncomingStatusGhost)];
        
        NSUInteger ghostCount =
        [TBMVideo MR_countOfEntitiesWithPredicate:ghostStatus inContext:[self _context]];
        
        const NSUInteger MaxGhostCount = 1000;
        const NSUInteger MaxGhostTolerance = 10;
        
        if (ghostCount < MaxGhostCount + MaxGhostTolerance)
        {
            return;
        }
        
        ZZLogInfo(@"Deleting outdated videos");
        
        NSArray *ghostVideoEntities =
        [TBMVideo MR_findAllSortedBy:TBMVideoAttributes.videoId
                           ascending:NO
                       withPredicate:ghostStatus
                           inContext:[self _context]];
        
        NSUInteger outdatedVideoCount = ghostCount - MaxGhostCount;
        
        NSArray *outdatedVideoEntities = [ghostVideoEntities subarrayWithRange:NSMakeRange(MaxGhostCount, outdatedVideoCount)];
        
        [outdatedVideoEntities enumerateObjectsUsingBlock:^(TBMVideo *videoEntity, NSUInteger idx, BOOL * _Nonnull stop) {
            ZZLogDebug(@"Deleting video %@", videoEntity.videoId);
            [videoEntity.friend removeVideosObject:videoEntity];
            [videoEntity MR_deleteEntity];
        }];

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
