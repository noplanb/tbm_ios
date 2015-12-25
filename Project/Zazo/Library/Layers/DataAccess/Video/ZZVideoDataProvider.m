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

+ (TBMVideo*)newWithVideoId:(NSString *)videoID onContext:(NSManagedObjectContext *)context
{
    return ZZDispatchOnMainThreadAndReturn(^id{
        TBMVideo *videoEntity = [TBMVideo MR_createEntityInContext:context];
        videoEntity.downloadRetryCount = @(0);
        videoEntity.status = ZZVideoIncomingStatusNew;
        videoEntity.videoId = videoID;
        return videoEntity;
    });
}

+ (TBMVideo*)newOutgoingVideoWithId:(NSString*)videoID onContext:(NSManagedObjectContext*)context
{
    TBMVideo* videoEntity = [TBMVideo MR_createEntityInContext:context];
    videoEntity.status = @(ZZVideoOutgoingStatusNew);
    videoEntity.videoId = videoID;
    
    return videoEntity;
}

+ (TBMVideo*)findWithVideoId:(NSString *)videoID
{
    return ZZDispatchOnMainThreadAndReturn(^id{
        return [self _findWithAttributeKey:@"videoId" value:videoID];
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
        ZZVideoDomainModel* modelModel;
        if (!ANIsEmpty(itemID))
        {
            TBMVideo* entity = [[TBMVideo MR_findByAttribute:TBMVideoAttributes.videoId withValue:itemID inContext:[self _context]] firstObject];
            modelModel = [self modelFromEntity:entity];
        }
        return modelModel;

    });
}

+ (TBMVideo*)entityWithID:(NSString*)itemID
{
    return ZZDispatchOnMainThreadAndReturn(^id{
        TBMVideo* itemEntity = nil;
        if (!ANIsEmpty(itemID))
        {
            NSArray* items = [TBMVideo MR_findByAttribute:TBMVideoAttributes.videoId withValue:itemID inContext:[self _context]];
            if (items.count > 1)
            {
                ANLogWarning(@"TBMVideo contains dupples for %@", itemID);
            }
            itemEntity = [items firstObject];
        }
        return itemEntity;

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

+ (ZZVideoDomainModel*)createIncomingVideoModelForFriend:(ZZFriendDomainModel*)friendModel withVideoId:(NSString*)videoID
{
    return ZZDispatchOnMainThreadAndReturn(^id{
        
        TBMFriend *friendEntity = [ZZFriendDataProvider entityFromModel:friendModel];
        TBMVideo *videoEntity = [self createIncomingVideoForFriend:friendEntity withVideoId:videoID];
        ZZVideoDomainModel *modelModel = [self modelFromEntity:videoEntity];
        modelModel.relatedUserID = friendModel.idTbm;
        return modelModel;
    });
}

+ (TBMVideo*)createIncomingVideoForFriend:(TBMFriend*)friendEntity withVideoId:(NSString*)videoID
{
    return ZZDispatchOnMainThreadAndReturn(^id{
        TBMVideo *videoEntity = [ZZVideoDataProvider newWithVideoId:videoID onContext:friendEntity.managedObjectContext];;
        [friendEntity addVideosObject:videoEntity];
        [friendEntity.managedObjectContext MR_saveToPersistentStoreAndWait];
        return videoEntity;

    });
}

+ (TBMVideo*)createOutgoingVideoForFriendID:(NSString*)friendID videoID:(NSString*)videoID context:(NSManagedObjectContext*)context
{
    TBMVideo* videoEntity = [ZZVideoDataProvider newOutgoingVideoWithId:videoID onContext:context];
    TBMFriend* friendEntity = [ZZFriendDataProvider friendEntityWithItemID:friendID];
    [friendEntity addSendVideosObject:videoEntity];
    [friendEntity.managedObjectContext MR_saveToPersistentStoreAndWait];
    
    return videoEntity;
}

+ (void)deleteVideoWithID:(NSString*)videoID context:(NSManagedObjectContext*)context
{
    TBMVideo* videoEntity = [ZZVideoDataProvider findWithVideoId:videoID];
    [videoEntity MR_deleteEntity];
    [context MR_saveToPersistentStoreAndWait];
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

+ (ZZVideoDomainModel*)modelFromEntity:(TBMVideo*)videoEntity
{
    return ZZDispatchOnMainThreadAndReturn(^id{
        return [ZZVideoModelsMapper fillModel:[ZZVideoDomainModel new] fromEntity:videoEntity];
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
        
        return [self sortedIncomingVideosForFriendEntity:friendEntity];
    });
}

+ (NSArray*)sortedIncomingVideosForFriendEntity:(TBMFriend*)friendEntity
{
    NSPredicate* predicate = [NSPredicate predicateWithFormat:@"%K = %@", TBMVideoRelationships.friend, friendEntity];

    NSArray* videos =
    [TBMVideo MR_findAllSortedBy:TBMVideoAttributes.videoId
                       ascending:YES
                   withPredicate:predicate
                       inContext:[self _context]];
    
    return [[videos.rac_sequence map:^id(id value) {
        return [self modelFromEntity:value];
    }] array];
}


#pragma mark - Helpers

+ (void)printAll
{
    ANDispatchBlockToMainQueue(^{
        ZZLogInfo(@"All Videos (%lu)", (unsigned long)[self countAllVideos]);
        for (TBMVideo * videoEntity in [self all])
        {
            ZZLogInfo(@"%@ %@ status=%@", videoEntity.friend.firstName, videoEntity.videoId, videoEntity.status);
        }

    });
}

+ (NSURL *)videoUrlWithVideoModel:(ZZVideoDomainModel*)videoModel
{
    return ZZDispatchOnMainThreadAndReturn(^id{
        TBMVideo *videoEntity = [self entityWithID:videoModel.videoID];
        return [self videoUrlWithVideo:videoEntity];
    });
}

+ (NSURL *)videoUrlWithVideo:(TBMVideo*)videoEntity
{
    return ZZDispatchOnMainThreadAndReturn(^id{
        
        NSString *filename = [NSString stringWithFormat:@"incomingVidFromFriend_%@-VideoId_%@", videoEntity.friend.idTbm, videoEntity.videoId];
        NSURL* videosURL = [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] firstObject];
        return [videosURL URLByAppendingPathComponent:[filename stringByAppendingPathExtension:@"mp4"]];
    });
}

+ (BOOL)videoFileExistsForVideo:(TBMVideo*)videoEntity
{
    NSURL* videoUrl = [self videoUrlWithVideo:videoEntity];
    return [[NSFileManager defaultManager] fileExistsAtPath:videoUrl.path];
}

+ (BOOL)isStatusDownloadingWithVideo:(ZZVideoDomainModel *)videoModel
{
    NSNumber *result = ZZDispatchOnMainThreadAndReturn(^id{
        return @(videoModel.incomingStatusValue == ZZVideoIncomingStatusDownloading);
    });
    
    return result.boolValue;
}

#pragma mark - Private

+ (NSManagedObjectContext*)_context
{
    return [ZZContentDataAcessor mainThreadContext];

}
@end
