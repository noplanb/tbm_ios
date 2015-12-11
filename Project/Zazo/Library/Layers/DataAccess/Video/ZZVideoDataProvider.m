//
//  ZZVideoDataProvider.m
//  Zazo
//
//  Created by ANODA on 8/10/15.
//  Copyright (c) 2015 ANODA. All rights reserved.
//

#import "ZZVideoDataProvider.h"
#import "ZZVideoModelsMapper.h"
#import "ZZVideoDomainModel.h"
#import "ZZFriendDataProvider.h"
#import "ZZFriendDataProvider+Private.h"
#import "ZZContentDataAcessor.h"
#import "ZZFriendDomainModel.h"

#import "TBMFriend.h"
#import "TBMVideo.h"
#import "MagicalRecord.h"

@implementation ZZVideoDataProvider


#pragma mark - Fetches

+ (TBMVideo*)newWithVideoId:(NSString *)videoId onContext:(NSManagedObjectContext *)context
{
    TBMVideo *video = [TBMVideo MR_createEntityInContext:context];
    video.downloadRetryCount = @(0);
    video.status = ZZVideoIncomingStatusNew;
    video.videoId = videoId;
    return video;
}

+ (ZZVideoDomainModel*)findWithVideoId:(NSString *)videoId;
{
    TBMVideo* entity = [self _findWithAttributeKey:@"videoId" value:videoId];
    return [self modelFromEntity:entity];
}

+ (TBMVideo*)_findWithAttributeKey:(NSString *)key value:(id)value
{
    return [[self _findAllWithAttributeKey:key value:value] lastObject];
}

+ (NSArray *)_findAllWithAttributeKey:(NSString *)key value:(id)value
{
    return [TBMVideo MR_findByAttribute:key withValue:value];
}

+ (NSArray *)allEntities
{
    return [TBMVideo MR_findAllInContext:[self _context]];
}

+ (ZZVideoDomainModel*)itemWithID:(NSString*)itemID
{
    ZZVideoDomainModel* model;
    if (!ANIsEmpty(itemID))
    {
        TBMVideo* entity = [[TBMVideo MR_findByAttribute:TBMVideoAttributes.videoId withValue:itemID inContext:[self _context]] firstObject];
        model = [self modelFromEntity:entity];
    }
    return model;
}

+ (TBMVideo*)entityWithID:(NSString*)itemID
{
    TBMVideo* item = nil;
    if (!ANIsEmpty(itemID))
    {
        NSArray* items = [TBMVideo MR_findByAttribute:TBMVideoAttributes.videoId withValue:itemID inContext:[self _context]];
        if (items.count > 1)
        {
            ANLogWarning(@"TBMVideo contains dupples for %@", itemID);
        }
        item = [items firstObject];
    }
    return item;
}

+ (NSArray*)downloadingEntities
{
    return [self _findAllWithAttributeKey:@"status" value:@(ZZVideoIncomingStatusDownloading)];
}

+ (NSArray*)downloadingItems
{
    NSArray *entities = [self _findAllWithAttributeKey:@"status" value:@(ZZVideoIncomingStatusDownloading)];
    
    NSArray *items = [[entities.rac_sequence map:^id(id value) {
                return [self modelFromEntity:value];
    }] array];
    
    return items;
}

+ (ZZVideoDomainModel*)createIncomingVideoForFriendId:(NSString*)friendId withVideoId:(NSString*)videoId
{
    NSManagedObjectContext *context = [self _context];
    TBMVideo *videoEntity = [ZZVideoDataProvider newWithVideoId:videoId onContext:context];
    TBMFriend *friendEntity = [ZZFriendDataProvider friendEntityWithItemID:friendId];
    [friendEntity addVideosObject:videoEntity];
    [context MR_saveToPersistentStoreAndWait];
    
    ZZVideoDomainModel *videoModel = [self modelFromEntity:videoEntity];
    return videoModel;
}

#pragma mark - Mapping

+ (ZZVideoDomainModel*)modelFromEntity:(TBMVideo*)entity
{
    return [ZZVideoModelsMapper fillModel:[ZZVideoDomainModel new] fromEntity:entity];
}


#pragma mark - Load

+ (NSUInteger)countDownloadedUnviewedVideos
{
    NSPredicate* predicate = [NSPredicate predicateWithFormat:@"%K = %@", TBMVideoAttributes.status, @(ZZVideoIncomingStatusDownloaded)];
    return [TBMVideo MR_countOfEntitiesWithPredicate:predicate inContext:[self _context]];
}

+ (NSUInteger)countDownloadingVideos
{
    NSPredicate* predicate = [NSPredicate predicateWithFormat:@"%K = %@", TBMVideoAttributes.status, @(ZZVideoIncomingStatusDownloading)];
    return [TBMVideo MR_countOfEntitiesWithPredicate:predicate inContext:[self _context]];
}

+ (NSUInteger)countTotalUnviewedVideos
{
    return [self countDownloadedUnviewedVideos];
}

+ (NSUInteger)countAllVideos
{
    return [TBMVideo MR_countOfEntitiesWithContext:[self _context]];
}

+ (NSArray*)sortedIncomingVideosForUser:(ZZFriendDomainModel*)friendModel
{
    return [self sortedIncomingVideosForUserID:friendModel.idTbm];
}

+ (NSArray*)sortedIncomingVideosForUserID:(NSString*)userID
{
    TBMFriend* friendEntity = [ZZFriendDataProvider friendEntityWithItemID:userID];
    NSPredicate* predicate = [NSPredicate predicateWithFormat:@"%K = %@", TBMVideoRelationships.friend, friendEntity];
    NSArray* videos = [TBMVideo MR_findAllSortedBy:TBMVideoAttributes.videoId ascending:YES withPredicate:predicate inContext:[self _context]];
    
    return [[videos.rac_sequence map:^id(id value) {
        return [self modelFromEntity:value];
    }] array];
}

#pragma mark - Helpers

+ (void)printAll
{
    ZZLogInfo(@"All Videos (%lu)", (unsigned long)[self countAllVideos]);
    for (TBMVideo * v in [self allEntities])
    {
        ZZLogInfo(@"%@ %@ status=%@", v.friend.firstName, v.videoId, v.status);
    }
}

+ (NSURL *)videoUrlWithVideo:(ZZVideoDomainModel*)video
{
    NSString *filename = [NSString stringWithFormat:@"incomingVidFromFriend_%@-VideoId_%@", video.relatedUserID, video.videoID];
    NSURL* videosURL = [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] firstObject];
    return [videosURL URLByAppendingPathComponent:[filename stringByAppendingPathExtension:@"mp4"]];
}

+ (BOOL)videoFileExistsForVideo:(ZZVideoDomainModel*)video;
{
    NSURL* videoUrl = [self videoUrlWithVideo:video];
    return [[NSFileManager defaultManager] fileExistsAtPath:videoUrl.path];
}

+ (BOOL)isStatusDownloadingWithVideo:(ZZVideoDomainModel*)video
{
    return (video.incomingStatusValue == ZZVideoIncomingStatusDownloading);
}

#pragma mark - Private

+ (NSManagedObjectContext*)_context
{
    return [ZZContentDataAcessor contextForCurrentThread];
}

@end
