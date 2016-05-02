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
@import MagicalRecord;
#import "ZZFriendDataProvider+Entities.h"
#import "ZZContentDataAccessor.h"
#import "TBMFriend.h"
#import "ZZFriendDomainModel.h"

@implementation ZZVideoDataProvider


#pragma mark - Fetches

+ (ZZVideoDomainModel*)itemWithID:(NSString*)itemID
{
    return ZZDispatchOnMainThreadAndReturn(^id{
        ZZVideoDomainModel* modelModel;
        if (!ANIsEmpty(itemID))
        {
            TBMVideo* entity = [self entityWithID:itemID];
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
                ZZLogWarning(@"TBMVideo contains dupples for %@", itemID);
            }
            itemEntity = [items firstObject];
        }
        return itemEntity;

    });
}

+ (NSArray <ZZVideoDomainModel *> *)videosWithStatus:(ZZVideoIncomingStatus)status
{
    return ZZDispatchOnMainThreadAndReturn(^id{
        
        NSArray *downloadingEntities =
        [TBMVideo MR_findByAttribute:TBMVideoAttributes.status withValue:@(status)];
        
        return [[downloadingEntities.rac_sequence map:^id(id value) {
            return [self modelFromEntity:value];
        }] array];
    });
}

+ (ZZVideoDomainModel*)createIncomingVideoModelForFriend:(ZZFriendDomainModel*)friendModel withVideoID:(NSString*)videoID
{
    return ZZDispatchOnMainThreadAndReturn(^id{
        
        TBMFriend *friendEntity = [ZZFriendDataProvider entityFromModel:friendModel];
        TBMVideo *videoEntity = [self _createIncomingVideoForFriend:friendEntity withVideoId:videoID];
        ZZVideoDomainModel *modelModel = [self modelFromEntity:videoEntity];
        modelModel.relatedUserID = friendModel.idTbm;
        return modelModel;
    });
}

+ (TBMVideo*)_createIncomingVideoForFriend:(TBMFriend*)friendEntity withVideoId:(NSString*)videoID
{
    TBMVideo *videoEntity = [ZZVideoDataProvider _newWithVideoID:videoID onContext:friendEntity.managedObjectContext];;
    [friendEntity addVideosObject:videoEntity];
    [friendEntity.managedObjectContext MR_saveToPersistentStoreAndWait];
    return videoEntity;
}

#pragma mark - Mapping

+ (ZZVideoDomainModel*)modelFromEntity:(TBMVideo*)videoEntity
{
    return ZZDispatchOnMainThreadAndReturn(^id{
        return [ZZVideoModelsMapper fillModel:[ZZVideoDomainModel new] fromEntity:videoEntity];
    });
}


#pragma mark - Load

+ (NSUInteger)countVideosWithStatus:(ZZVideoIncomingStatus)status fromFriend:(NSString *)friendID
{
    NSNumber *count =
    ZZDispatchOnMainThreadAndReturn(^id{
        
        NSPredicate *predicate;
        NSPredicate *statusPredicate = [NSPredicate predicateWithFormat:@"%K = %@", TBMVideoAttributes.status, @(status)];
        
        if (ANIsEmpty(friendID))
        {
            predicate = statusPredicate;
        }
        else
        {
            NSPredicate *friendIDPredicate =
                [NSPredicate predicateWithFormat:@"%K.idTbm = %@", TBMVideoRelationships.friend, friendID];
            
            predicate = [NSCompoundPredicate andPredicateWithSubpredicates:@[statusPredicate, friendIDPredicate]];
            
        }
        
        return @([TBMVideo MR_countOfEntitiesWithPredicate:predicate inContext:[self _context]]);
        
    });
    
    return count.unsignedIntegerValue;
    
}

+ (NSUInteger)countVideosWithStatus:(ZZVideoIncomingStatus)status
{
    return [self countVideosWithStatus:status fromFriend:nil];
}

+ (NSUInteger)countAllVideos
{
    NSNumber *count =
    ZZDispatchOnMainThreadAndReturn(^id{
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"%K != %@", TBMVideoAttributes.status, @(ZZVideoIncomingStatusGhost)];
        return @([TBMVideo MR_countOfEntitiesWithPredicate:predicate inContext:[self _context]]);
    });
    
    return count.unsignedIntegerValue;
}

+ (NSArray*)sortedIncomingVideosForUserWithID:(NSString *)friendID
{
    return ZZDispatchOnMainThreadAndReturn(^id{
        
        NSPredicate *friend = [NSPredicate predicateWithFormat:@"%K.idTbm = %@", TBMVideoRelationships.friend, friendID];
        NSPredicate *statusNotDeleted = [NSPredicate predicateWithFormat:@"%K != %@", TBMVideoAttributes.status, @(ZZVideoIncomingStatusGhost)];
        
        NSArray* videos =
        [TBMVideo MR_findAllSortedBy:TBMVideoAttributes.videoId
                           ascending:YES
                       withPredicate:[[NSCompoundPredicate alloc] initWithType:NSAndPredicateType subpredicates:@[friend, statusNotDeleted]]
                           inContext:[self _context]];
        
        NSArray* videoModels = [[videos.rac_sequence map:^id(id value) {
            return [self modelFromEntity:value];
        }] array];
        
        return videoModels;
        
    });
}

#pragma mark - Helpers


+ (BOOL)videoExists:(NSString*)videoID
{
    return [ZZDispatchOnMainThreadAndReturn(^id{
        NSPredicate *videoPredicate = [NSPredicate predicateWithFormat:@"%K = %@", TBMVideoAttributes.videoId, videoID];
        return @([TBMVideo MR_countOfEntitiesWithPredicate:videoPredicate inContext:[self _context]] > 0);
    }) boolValue];
    
}

+ (void)printAll
{
    ZZLogInfo(@"All Videos (%lu)", (unsigned long)[self countAllVideos]);
    for (ZZVideoDomainModel *videoModel in [self _allNotDeleted])
    {
        ZZLogInfo(@"%@ %@ status=%ld", [ZZFriendDataProvider friendWithItemID:videoModel.relatedUserID].firstName, videoModel.videoID, (long)videoModel.incomingStatusValue);
    }
}

+ (NSURL *)videoUrlWithVideoModel:(ZZVideoDomainModel*)videoModel
{
    return [self _videoUrlWithFriendID:videoModel.relatedUserID videoID:videoModel.videoID];
}

+ (NSURL *)videoUrlWithVideo:(TBMVideo*)videoEntity
{
    return ZZDispatchOnMainThreadAndReturn(^id{
        return [self _videoUrlWithFriendID:videoEntity.friend.idTbm videoID:videoEntity.videoId];
    });
}

+ (NSURL *)_videoUrlWithFriendID:(NSString *)friendID videoID:(NSString *)videoID
{
    NSString *filename = [NSString stringWithFormat:@"incomingVidFromFriend_%@-VideoId_%@", friendID, videoID];
    NSURL* videosURL = [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] firstObject];
    return [videosURL URLByAppendingPathComponent:[filename stringByAppendingPathExtension:@"mp4"]];
}

#pragma mark - Private

+ (NSArray *)_allNotDeleted
{
    return ZZDispatchOnMainThreadAndReturn(^id{
        // TODO: Optimize. Must not fetch ghost videos
        return [[[[TBMVideo MR_findAllInContext:[self _context]].rac_sequence filter:^BOOL(TBMVideo *value) {
            return value.statusValue != ZZVideoIncomingStatusGhost;
        }] map:^id(id value) {
            return [self modelFromEntity:value];
        }] array];
    });
}

+ (TBMVideo*)_newWithVideoID:(NSString *)videoID onContext:(NSManagedObjectContext *)context
{
    TBMVideo *videoEntity = [TBMVideo MR_createEntityInContext:context];
    videoEntity.downloadRetryCount = @(0);
    videoEntity.status = ZZVideoIncomingStatusNew;
    videoEntity.videoId = videoID;
    return videoEntity;
}

+ (NSManagedObjectContext*)_context
{
    return [ZZContentDataAccessor mainThreadContext];

}
@end
