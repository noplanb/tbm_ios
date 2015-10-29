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
#import "TBMVideo.h"
#import "MagicalRecord.h"
#import "ZZVideoStatuses.h"
#import "ZZFriendDataProvider.h"
#import "ZZContentDataAcessor.h"
#import "TBMFriend.h"
#import "ZZThumbnailGenerator.h"


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


+ (TBMVideo*)findWithVideoId:(NSString *)videoId
{
    return [self _findWithAttributeKey:@"videoId" value:videoId];
}

+ (TBMVideo*)_findWithAttributeKey:(NSString *)key value:(id)value
{
    return [[self _findAllWithAttributeKey:key value:value] lastObject];
}

+ (NSArray *)_findAllWithAttributeKey:(NSString *)key value:(id)value
{
    return [TBMVideo MR_findByAttribute:key withValue:value];
}

+ (NSArray *)all
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
    return [self _findAllWithAttributeKey:@"status" value:[NSNumber numberWithInt:ZZVideoIncomingStatusDownloading]];
}


#pragma mark - Mapping

+ (TBMVideo*)entityFromModel:(ZZVideoDomainModel*)model
{
    TBMVideo* entity = [self entityWithID:model.videoID];
    if (!entity)
    {
        entity = [TBMVideo MR_createEntityInContext:[self _context]];
    }
    return [ZZVideoModelsMapper fillEntity:entity fromModel:model];
}

+ (ZZVideoDomainModel*)modelFromEntity:(TBMVideo*)entity
{
    return [ZZVideoModelsMapper fillModel:[ZZVideoDomainModel new] fromEntity:entity];
}


#pragma mark - Load

+ (NSArray*)loadUnviewedVideos
{
    NSArray* result = [TBMVideo MR_findByAttribute:TBMVideoAttributes.status
                                         withValue:@(ZZVideoIncomingStatusDownloaded)
                                         inContext:[self _context]];
    return [[result.rac_sequence map:^id(id value) {
        return [self modelFromEntity:value];
    }] array];
}

+ (NSUInteger)countDownloadedUnviewedVideos
{
    NSPredicate* predicate = [NSPredicate predicateWithFormat:@"%K = %@", TBMVideoAttributes.status, @(ZZVideoIncomingStatusDownloaded)];
    return [TBMVideo MR_countOfEntitiesWithPredicate:predicate inContext:[self _context]];
}

+ (NSArray*)loadDownloadingVideos
{
    NSArray* result = [TBMVideo MR_findByAttribute:TBMVideoAttributes.status
                                         withValue:@(ZZVideoIncomingStatusDownloading)
                                         inContext:[self _context]];
    return [[result.rac_sequence map:^id(id value) {
        return [self modelFromEntity:value];
    }] array];
}

+ (NSUInteger)countDownloadingVideos
{
    NSPredicate* predicate = [NSPredicate predicateWithFormat:@"%K = %@", TBMVideoAttributes.status, @(ZZVideoIncomingStatusDownloading)];
    return [TBMVideo MR_countOfEntitiesWithPredicate:predicate inContext:[self _context]];
}

+ (NSUInteger)countTotalUnviewedVideos
{
    return ([self countDownloadingVideos] + [self countDownloadedUnviewedVideos]);
}

+ (NSArray*)loadAllVideos
{
    NSArray* result = [TBMVideo MR_findAllInContext:[self _context]];
    
    return [[result.rac_sequence map:^id(id value) {
        return [self modelFromEntity:value];
    }] array];
}

+ (NSUInteger)countAllVideos
{
    return [TBMVideo MR_countOfEntitiesWithContext:[self _context]];
}

+ (NSArray*)sortedIncomingVideosForUser:(ZZFriendDomainModel*)friendModel
{
    TBMFriend* friendEntity = [ZZFriendDataProvider entityFromModel:friendModel];
    NSPredicate* predicate = [NSPredicate predicateWithFormat:@"%K = %@", TBMVideoRelationships.friend, friendEntity];
    NSArray* videos = [TBMVideo MR_findAllSortedBy:TBMVideoAttributes.videoId ascending:YES withPredicate:predicate inContext:[self _context]];
    
    return [[videos.rac_sequence map:^id(id value) {
        return [self modelFromEntity:value];
    }] array];
}


#pragma mark - Helpers

+ (void)printAll
{
    OB_INFO(@"All Videos (%lu)", (unsigned long)[self countAllVideos]);
    for (TBMVideo * v in [self all])
    {
        OB_INFO(@"%@ %@ status=%@", v.friend.firstName, v.videoId, v.status);
    }
}


+ (NSURL *)videoUrlWithVideo:(TBMVideo*)video
{
    
    NSString *filename = [NSString stringWithFormat:@"incomingVidFromFriend_%@-VideoId_%@", video.friend.idTbm, video.videoId];
    NSURL* videosURL = [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] firstObject];
    return [videosURL URLByAppendingPathComponent:[filename stringByAppendingPathExtension:@"mp4"]];
}

+ (BOOL)videoFileExistsForVideo:(TBMVideo*)video
{
    NSURL* videoUrl = [self videoUrlWithVideo:video];
    return [[NSFileManager defaultManager] fileExistsAtPath:videoUrl.path];
}


+ (unsigned long long)videoFileSizeForVideo:(TBMVideo*)video
{
    if (![self videoFileExistsForVideo:video])
        return 0;
    
    NSError *error;
    
    NSURL* videoUrl = [self videoUrlWithVideo:video];
    NSDictionary *fa = [[NSFileManager defaultManager] attributesOfItemAtPath:videoUrl.path error:&error];
    if (error)
        return 0;
    
    return fa.fileSize;
}

+ (BOOL)hasValidVideoFileWithVideo:(TBMVideo*)video
{
    return [self videoFileSizeForVideo:video] > 0;
}

+ (BOOL)isStatusDownloadingWithVideo:(TBMVideo*)video
{
    return (video.statusValue == ZZVideoIncomingStatusDownloading);
}

#pragma mark - Private

+ (NSManagedObjectContext*)_context
{
    return [ZZContentDataAcessor contextForCurrentThread];
}

@end
