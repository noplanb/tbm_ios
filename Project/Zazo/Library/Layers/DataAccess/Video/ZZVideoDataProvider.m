//
//  ZZVideoDataProvider.m
//  Zazo
//
//  Created by ANODA on 8/10/15.
//  Copyright (c) 2015 ANODA. All rights reserved.
//

#import "ZZVideoDataProvider+Entities.h"
#import "ZZVideoModelsMapper.h"
#import "ZZVideoDomainModel.h"
#import "TBMVideo.h"
#import "MagicalRecord.h"
#import "ZZFriendDataProvider+Entities.h"
#import "ZZContentDataAcessor.h"
#import "TBMFriend.h"
#import "ZZFriendDomainModel.h"

@implementation ZZVideoDataProvider


#pragma mark - Fetches

+ (TBMVideo*)newWithVideoId:(NSString *)videoId onContext:(NSManagedObjectContext *)context
{
    return ZZDispatchOnMainThreadAndReturn(^id{
        TBMVideo *video = [TBMVideo MR_createEntityInContext:context];
        video.downloadRetryCount = @(0);
        video.status = ZZVideoIncomingStatusNew;
        video.videoId = videoId;
        return video;
    });
}

+ (TBMVideo*)findWithVideoId:(NSString *)videoId
{
    return ZZDispatchOnMainThreadAndReturn(^id{
        return [self _findWithAttributeKey:@"videoId" value:videoId];
    });
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
    return ZZDispatchOnMainThreadAndReturn(^id{
        return [TBMVideo MR_findAllInContext:[self _context]];
    });
}

+ (ZZVideoDomainModel*)itemWithID:(NSString*)itemID
{
    return ZZDispatchOnMainThreadAndReturn(^id{
        ZZVideoDomainModel* model;
        if (!ANIsEmpty(itemID))
        {
            TBMVideo* entity = [[TBMVideo MR_findByAttribute:TBMVideoAttributes.videoId withValue:itemID inContext:[self _context]] firstObject];
            model = [self modelFromEntity:entity];
        }
        return model;

    });
}

+ (TBMVideo*)entityWithID:(NSString*)itemID
{
    return ZZDispatchOnMainThreadAndReturn(^id{
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

    });
}

+ (NSArray *)downloadingVideos
{
    return ZZDispatchOnMainThreadAndReturn(^id{
        return [[[self downloadingEntities].rac_sequence map:^id(id value) {
            return [self modelFromEntity:value];
        }] array];
    });
}

+ (NSArray*)downloadingEntities
{
    return [self _findAllWithAttributeKey:@"status" value:@(ZZVideoIncomingStatusDownloading)];
}

+ (ZZVideoDomainModel*)createIncomingVideoModelForFriend:(ZZFriendDomainModel*)friend withVideoId:(NSString*)videoId
{
    return ZZDispatchOnMainThreadAndReturn(^id{
        
        TBMFriend *friendEntity = [ZZFriendDataProvider entityFromModel:friend];
        TBMVideo *video = [self createIncomingVideoForFriend:friendEntity withVideoId:videoId];
        ZZVideoDomainModel *model = [self modelFromEntity:video];
        model.relatedUser = friend;
        return model;
    });
}

+ (TBMVideo*)createIncomingVideoForFriend:(TBMFriend*)friend withVideoId:(NSString*)videoId
{
    return ZZDispatchOnMainThreadAndReturn(^id{
        TBMVideo *video = [ZZVideoDataProvider newWithVideoId:videoId onContext:friend.managedObjectContext];;
        [friend addVideosObject:video];
        [friend.managedObjectContext MR_saveToPersistentStoreAndWait];
        return video;

    });
}

#pragma mark - Mapping

//+ (TBMVideo*)entityFromModel:(ZZVideoDomainModel*)model
//{
//    TBMVideo* entity = [self entityWithID:model.videoID];
//    if (!entity)
//    {
//        entity = [TBMVideo MR_createEntityInContext:[self _context]];
//    }
//    return [ZZVideoModelsMapper fillEntity:entity fromModel:model];
//}

+ (ZZVideoDomainModel*)modelFromEntity:(TBMVideo*)entity
{
    return ZZDispatchOnMainThreadAndReturn(^id{
        return [ZZVideoModelsMapper fillModel:[ZZVideoDomainModel new] fromEntity:entity];
    });
}


#pragma mark - Load

//+ (NSArray*)loadUnviewedVideos
//{
//    NSArray* result = [TBMVideo MR_findByAttribute:TBMVideoAttributes.status
//                                         withValue:@(ZZVideoIncomingStatusDownloaded)
//                                         inContext:[self _context]];
//    return [[result.rac_sequence map:^id(id value) {
//        return [self modelFromEntity:value];
//    }] array];
//}

+ (NSUInteger)countDownloadedUnviewedVideos
{
    NSNumber *count =
    ZZDispatchOnMainThreadAndReturn(^id{
        NSPredicate* predicate = [NSPredicate predicateWithFormat:@"%K = %@", TBMVideoAttributes.status, @(ZZVideoIncomingStatusDownloaded)];
        return @([TBMVideo MR_countOfEntitiesWithPredicate:predicate inContext:[self _context]]);

    });
    
    return count.unsignedIntegerValue;
}

//+ (NSArray*)loadDownloadingVideos
//{
//    NSArray* result = [TBMVideo MR_findByAttribute:TBMVideoAttributes.status
//                                         withValue:@(ZZVideoIncomingStatusDownloading)
//                                         inContext:[self _context]];
//    return [[result.rac_sequence map:^id(id value) {
//        return [self modelFromEntity:value];
//    }] array];
//}

+ (NSUInteger)countDownloadingVideos
{
    NSNumber *count =
    ZZDispatchOnMainThreadAndReturn(^id{
        NSPredicate* predicate = [NSPredicate predicateWithFormat:@"%K = %@", TBMVideoAttributes.status, @(ZZVideoIncomingStatusDownloading)];
        return @([TBMVideo MR_countOfEntitiesWithPredicate:predicate inContext:[self _context]]);
    });
    
    return count.unsignedIntegerValue;
}

+ (NSUInteger)countTotalUnviewedVideos
{
    NSNumber *count = ZZDispatchOnMainThreadAndReturn(^id{
        return @([self countDownloadedUnviewedVideos]);
    });
    
    return count.unsignedIntegerValue;
}

//+ (NSArray*)loadAllVideos
//{
//    NSArray* result = [TBMVideo MR_findAllInContext:[self _context]];
//
//    return [[result.rac_sequence map:^id(id value) {
//        return [self modelFromEntity:value];
//    }] array];
//}

+ (NSUInteger)countAllVideos
{
    NSNumber *count =
    ZZDispatchOnMainThreadAndReturn(^id{
        return @([TBMVideo MR_countOfEntitiesWithContext:[self _context]]);
    });
    
    return count.unsignedIntegerValue;
}

+ (NSArray*)sortedIncomingVideosForUser:(ZZFriendDomainModel*)friendModel
{
    return ZZDispatchOnMainThreadAndReturn(^id{
        TBMFriend* friendEntity = [ZZFriendDataProvider friendEntityWithItemID:friendModel.idTbm];
        NSPredicate* predicate = [NSPredicate predicateWithFormat:@"%K = %@", TBMVideoRelationships.friend, friendEntity];
        NSArray* videos = [TBMVideo MR_findAllSortedBy:TBMVideoAttributes.videoId ascending:YES withPredicate:predicate inContext:[self _context]];
        
        return [[videos.rac_sequence map:^id(id value) {
            return [self modelFromEntity:value];
        }] array];
    });
}


#pragma mark - Helpers

+ (void)printAll
{
    ANDispatchBlockToMainQueue(^{
        ZZLogInfo(@"All Videos (%lu)", (unsigned long)[self countAllVideos]);
        for (TBMVideo * v in [self all])
        {
            ZZLogInfo(@"%@ %@ status=%@", v.friend.firstName, v.videoId, v.status);
        }

    });
}

+ (NSURL *)videoUrlWithVideoModel:(ZZVideoDomainModel*)video
{
    return ZZDispatchOnMainThreadAndReturn(^id{
        TBMVideo *entity = [self entityWithID:video.videoID];
        return [self videoUrlWithVideo:entity];
    });
}

+ (NSURL *)videoUrlWithVideo:(TBMVideo*)video
{
    return ZZDispatchOnMainThreadAndReturn(^id{
        
        NSString *filename = [NSString stringWithFormat:@"incomingVidFromFriend_%@-VideoId_%@", video.friend.idTbm, video.videoId];
        NSURL* videosURL = [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] firstObject];
        return [videosURL URLByAppendingPathComponent:[filename stringByAppendingPathExtension:@"mp4"]];
    });
}

+ (BOOL)videoFileExistsForVideo:(TBMVideo*)video
{
    NSURL* videoUrl = [self videoUrlWithVideo:video];
    return [[NSFileManager defaultManager] fileExistsAtPath:videoUrl.path];
}

+ (BOOL)isStatusDownloadingWithVideo:(ZZVideoDomainModel *)video
{
    NSNumber *result = ZZDispatchOnMainThreadAndReturn(^id{
        return @(video.incomingStatusValue == ZZVideoIncomingStatusDownloading);
    });
    
    return result.boolValue;
}

#pragma mark - Private

+ (NSManagedObjectContext*)_context
{
    return [ZZContentDataAcessor mainThreadContext];

}
@end
