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
#import "ZZContentDataAcessor.h"
#import "ZZFriendDomainModel.h"

@implementation ZZVideoDataUpdater

+ (ZZVideoDomainModel*)upsertVideo:(ZZVideoDomainModel*)model
{
    return ZZDispatchOnMainThreadAndReturn(^id{
        TBMVideo* item = [ZZVideoDataProvider entityWithID:model.videoID];
        
        if (!item)
        {
            item = [TBMVideo MR_createEntityInContext:[self _context]];
        }
        
        item = [ZZVideoModelsMapper fillEntity:item fromModel:model];
        [item.managedObjectContext MR_saveToPersistentStoreAndWait];
        
        return [ZZVideoDataProvider modelFromEntity:item];
    });
}

//+ (void)deleteItem:(ZZVideoDomainModel*)model
//{
//    TBMVideo* entity = [self entityFromModel:model];
//    [entity MR_deleteEntityInContext:[self _context]];
//
//    [[self _context] MR_saveToPersistentStoreAndWait];
//}

//+ (TBMVideo*)entityWithID:(NSString*)itemID
//{
//    TBMVideo* item = nil;
//    if (!ANIsEmpty(itemID))
//    {
//        NSArray* items = [TBMVideo MR_findByAttribute:TBMVideoAttributes.videoId withValue:itemID inContext:[self _context]];
//        if (items.count > 1)
//        {
//            ANLogWarning(@"TBMVideo contains dupples for %@", itemID);
//        }
//        item = [items firstObject];
//    }
//    return item;
//}

+ (void)destroy:(TBMVideo *)video
{
    ANDispatchBlockToMainQueue(^{
        NSManagedObjectContext* context = video.managedObjectContext;
        [video MR_deleteEntity];
        [context MR_saveToPersistentStoreAndWait];
    });
}

#pragma mark - Delete Video Methods

+ (void)deleteAllViewedOrFailedVideoWithFriendId:(NSString*)friendId
{
    ZZLogInfo(@"deleteAllViewedVideos");
    
    TBMFriend* friendModel = [ZZFriendDataProvider friendEntityWithItemID:friendId];
    
    NSSortDescriptor *d = [[NSSortDescriptor alloc] initWithKey:@"videoId" ascending:YES];
    NSArray* sortedVidoes = [friendModel.videos sortedArrayUsingDescriptors:@[d]];
    
    for (TBMVideo *v in sortedVidoes)
    {
        if (v.statusValue == ZZVideoIncomingStatusViewed ||
            v.statusValue == ZZVideoIncomingStatusFailedPermanently)
        {
            [self deleteVideo:v withFriend:friendModel];
        }
    }
}

+ (void)deleteVideo:(TBMVideo*)video withFriend:(TBMFriend*)friend
{
    [ZZVideoDataUpdater deleteFilesForVideo:video];
    [friend removeVideosObject:video];
    [ZZVideoDataUpdater destroy:video];
    [friend.managedObjectContext MR_saveToPersistentStoreAndWait];
}

+ (void)deleteVideoFileWithVideo:(TBMVideo*)video
{
    ANDispatchBlockToMainQueue(^{
        ZZLogInfo(@"deleteVideoFile");
        NSFileManager *fm = [NSFileManager defaultManager];
        NSError *error = nil;
        [fm removeItemAtURL:[ZZVideoDataProvider videoUrlWithVideo:video] error:&error];
    });
}

+ (void)deleteFilesForVideo:(TBMVideo*)video
{
    ANDispatchBlockToMainQueue(^{
        [self deleteVideoFileWithVideo:video];
        ZZVideoDomainModel* videoModel = [ZZVideoDataProvider modelFromEntity:video];
        [ZZThumbnailGenerator deleteThumbFileForVideo:videoModel];
        
    });
}

+ (void)updateViewedVideoCounterWithVideoDomainModel:(ZZVideoDomainModel*)playedVideoModel
{
    ANDispatchBlockToMainQueue(^{
        TBMVideo* viewedVideo = [ZZVideoDataProvider entityWithID:playedVideoModel.videoID];
        if (!ANIsEmpty(viewedVideo))
        {
            if (viewedVideo.statusValue == ZZVideoIncomingStatusDownloaded)
            {
                //            viewedVideo.status = @(ZZVideoIncomingStatusViewed);
                if (playedVideoModel.relatedUser.unviewedCount > 0)
                {
                    playedVideoModel.relatedUser.unviewedCount--;
                }
                else
                {
                    playedVideoModel.relatedUser.unviewedCount = 0;
                }
                
                //            [viewedVideo.managedObjectContext MR_saveToPersistentStoreAndWait];
            }
        }

    });
}

//+ (TBMVideo*)entityFromModel:(ZZVideoDomainModel*)model
//{
//    TBMVideo* entity = [ZZVideoDataProvider entityWithID:model.videoID];
//    if (!entity)
//    {
//        entity = [TBMVideo MR_createEntityInContext:[self _context]];
//    }
//    return [ZZVideoModelsMapper fillEntity:entity fromModel:model];
//}


#pragma mark - Private

+ (NSManagedObjectContext*)_context
{
    return [ZZContentDataAcessor mainThreadContext];
}


@end
