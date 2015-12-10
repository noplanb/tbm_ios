//
//  ZZVideoDataUpdater.m
//  Zazo
//
//  Created by ANODA on 10/28/15.
//  Copyright © 2015 No Plan B. All rights reserved.
//

#import "ZZVideoDataUpdater.h"
#import "ZZVideoDataProvider.h"
#import "ZZVideoDataProvider+Private.h"
#import "ZZThumbnailGenerator.h"
#import "ZZVideoDomainModel.h"
#import "ZZVideoModelsMapper.h"
#import "ZZContentDataAcessor.h"
#import "ZZFriendDataProvider.h"
#import "ZZFriendDataProvider+Private.h"

#import "TBMVideo.h"
#import "TBMFriend.h"

#import "MagicalRecord.h"


@implementation ZZVideoDataUpdater

+ (void)deleteVideo:(ZZVideoDomainModel*)videoModel withFriend:(ZZFriendDomainModel*)friendModel
{
    TBMVideo* videoEntity = [ZZVideoDataProvider entityWithID:videoModel.videoID];
    NSManagedObjectContext* context = videoEntity.managedObjectContext;
    
    [videoEntity MR_deleteEntity];
    
    [self _deleteFilesForVideo:videoModel];

    TBMFriend* friendEntity = [ZZFriendDataProvider entityFromModel:friendModel];
    [friendEntity removeVideosObject:videoEntity];

    [context MR_saveToPersistentStoreAndWait];
}


+ (void)deleteAllViewedOrFailedVideoWithFriendId:(NSString*)friendId
{
    TBMFriend* friendEntity = [ZZFriendDataProvider friendEntityWithItemID:friendId];
    NSManagedObjectContext* context = friendEntity.managedObjectContext;
    
    NSSortDescriptor *d = [[NSSortDescriptor alloc] initWithKey:@"videoId" ascending:YES];
    NSArray* sortedVidoes = [friendEntity.videos sortedArrayUsingDescriptors:@[d]];
    
    for (TBMVideo *videoEntity in sortedVidoes)
    {
        if (videoEntity.statusValue == ZZVideoIncomingStatusViewed ||
            videoEntity.statusValue == ZZVideoIncomingStatusFailedPermanently)
        {
            ZZVideoDomainModel *videoModel = [ZZVideoDataProvider modelFromEntity:videoEntity];
            [self _deleteFilesForVideo:videoModel];
            [videoEntity MR_deleteEntity];
            
            [friendEntity removeVideosObject:videoEntity];
        }
    }
    
    [context MR_saveToPersistentStoreAndWait];
}

+ (void)_deleteVideoFileWithVideo:(ZZVideoDomainModel*)video
{
    ZZLogInfo(@"deleteVideoFile");
    NSFileManager *fm = [NSFileManager defaultManager];
    NSError *error = nil;
    [fm removeItemAtURL:[ZZVideoDataProvider videoUrlWithVideo:video] error:&error];
}

+ (void)_deleteFilesForVideo:(ZZVideoDomainModel*)video
{
    [self _deleteVideoFileWithVideo:video];
    [ZZThumbnailGenerator deleteThumbFileForVideo:video];
}

+ (ZZVideoDomainModel*)upsertVideo:(ZZVideoDomainModel*)model
{
    NSManagedObjectContext *context = [self _context];
    
    TBMVideo* item = [ZZVideoDataProvider entityWithID:model.videoID];
    
    if (!item)
    {
        item = [TBMVideo MR_createEntityInContext:context];
    }

    item = [ZZVideoModelsMapper fillEntity:item fromModel:model];
    [item.managedObjectContext MR_saveToPersistentStoreAndWait];

    return [ZZVideoDataProvider modelFromEntity:item];
}

#pragma mark - Private

+ (NSManagedObjectContext*)_context
{
    return [ZZContentDataAcessor contextForCurrentThread];
}


@end
