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
@import MagicalRecord;
#import "ZZVideoDataProvider+Entities.h"
#import "ZZThumbnailGenerator.h"
#import "ZZVideoDomainModel.h"
#import "ZZContentDataAccessor.h"

@implementation ZZVideoDataUpdater

#pragma mark Update methods

+ (void)updateVideoWithID:(NSString *)videoID setTranscription:(NSString *)transcription
{
    [self _updateVideoWithID:videoID usingBlock:^(TBMVideo *videoEntity) {
        videoEntity.transcription = transcription;
    }];
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
        TBMVideo *videoEntity = [ZZVideoDataProvider entityWithID:videoID];
        updateBlock(videoEntity);
        [videoEntity.managedObjectContext MR_saveToPersistentStoreAndWait];
    });
}

#pragma mark - Delete Video Methods

+ (void)deleteAllVideos
{
    ANDispatchBlockToMainQueue(^{
        NSManagedObjectContext *context = [ZZContentDataAccessor mainThreadContext];
        [TBMVideo MR_truncateAllInContext:context];
        [context MR_saveToPersistentStoreAndWait];
    });
}

+ (void)deleteAllViewedVideosWithFriendID:(NSString *)friendID exceptVideoWithID:(NSString *)videoID
{
    ZZLogInfo(@"deleteAllViewedVideos");

    __block BOOL videosDeleted = NO;
    
    NSArray *sortedVideos = [ZZVideoDataProvider sortedIncomingVideosForUserWithID:friendID];

    for (ZZVideoDomainModel *videoModel in sortedVideos)
    {
        if (videoModel.incomingStatusValue == ZZVideoIncomingStatusViewed && ![videoModel.videoID isEqualToString:videoID])
        {
            videosDeleted = YES;
            [self _deleteVideo:videoModel];
        }
    }
    
    if (videosDeleted)
    {
        ZZLogInfo(@"Deletion completed");
        [[NSNotificationCenter defaultCenter] postNotificationName:ZZVideosDeletedNotification object:nil];
    }
}

+ (void)deleteAllFailedVideos
{
    ZZLogEvent(@"deleteAllFailedVideos");
    ANDispatchBlockToMainQueue(^{

        NSArray <ZZVideoDomainModel *> *downloadingEntities =
            [ZZVideoDataProvider videosWithStatus:ZZVideoIncomingStatusFailedPermanently];

        [downloadingEntities enumerateObjectsUsingBlock:^(ZZVideoDomainModel *obj, NSUInteger idx, BOOL *stop) {
            [self _deleteVideo:obj];
        }];
    });

}

+ (void)_deleteVideo:(ZZVideoDomainModel *)videoModel
{
    [self _deleteFilesForVideo:videoModel];

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

        [outdatedVideoEntities enumerateObjectsUsingBlock:^(TBMVideo *videoEntity, NSUInteger idx, BOOL *_Nonnull stop) {
            ZZLogDebug(@"Deleting video %@", videoEntity.videoId);
            [videoEntity.friend removeVideosObject:videoEntity];
            [videoEntity MR_deleteEntity];
        }];

    });
}

+ (BOOL)_deleteVideoFileWithVideo:(ZZVideoDomainModel *)videoModel
{
    ZZLogInfo(@"deleteVideoFile: %@", videoModel);
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    NSError *error = nil;
    
    if([fileManager removeItemAtURL:[ZZVideoDataProvider videoUrlWithVideoModel:videoModel] error:&error])
    {
        return YES;
    }
    else
    {
        ZZLogWarning(@"Videofile deletion error: %@", error);
        return NO;
    }
    
}

+ (void)_deleteFilesForVideo:(ZZVideoDomainModel *)videoModel
{
    [self _deleteVideoFileWithVideo:videoModel];
    [ZZThumbnailGenerator deleteThumbFileForVideo:videoModel];
}

#pragma mark - Private

+ (NSManagedObjectContext *)_context
{
    return [ZZContentDataAccessor mainThreadContext];
}


@end
