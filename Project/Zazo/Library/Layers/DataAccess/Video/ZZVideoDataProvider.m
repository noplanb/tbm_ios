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
        
        NSArray *downloadingEntities =
        [TBMVideo MR_findByAttribute:TBMVideoAttributes.status withValue:@(ZZVideoIncomingStatusDownloading)];
        
        return [[downloadingEntities.rac_sequence map:^id(id value) {
            return [self modelFromEntity:value];
        }] array];
    });
}

+ (ZZVideoDomainModel*)createIncomingVideoModelForFriend:(ZZFriendDomainModel*)friendModel withVideoID:(NSString*)videoID
{
    return ZZDispatchOnMainThreadAndReturn(^id{
        
        TBMFriend *friendEntity = [ZZFriendDataProvider entityFromModel:friendModel];
        TBMVideo *videoEntity = [self _createIncomingVideoForFriend:friendEntity withVideoID:videoID];
        ZZVideoDomainModel *modelModel = [self modelFromEntity:videoEntity];
        modelModel.relatedUserID = friendModel.idTbm;
        return modelModel;
    });
}

+ (TBMVideo*)_createIncomingVideoForFriend:(TBMFriend *)friendEntity withVideoID:(NSString*)videoID
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

+ (NSUInteger)countDownloadedUnviewedVideos
{
    NSNumber *count =
    ZZDispatchOnMainThreadAndReturn(^id{
        NSPredicate* predicate = [NSPredicate predicateWithFormat:@"%K = %@", TBMVideoAttributes.status, @(ZZVideoIncomingStatusDownloaded)];
        return @([TBMVideo MR_countOfEntitiesWithPredicate:predicate inContext:[self _context]]);

    });
    
    return count.unsignedIntegerValue;
}

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

+ (NSUInteger)countAllVideos
{
    NSNumber *count =
    ZZDispatchOnMainThreadAndReturn(^id{
        return @([TBMVideo MR_countOfEntitiesWithContext:[self _context]]);
    });
    
    return count.unsignedIntegerValue;
}

+ (NSArray*)sortedIncomingVideosForUserWithID:(NSString *)friendID
{
    return ZZDispatchOnMainThreadAndReturn(^id{
        
        NSPredicate* predicate = [NSPredicate predicateWithFormat:@"%K.idTbm = %@", TBMVideoRelationships.friend, friendID];
        
        NSArray* videos =
        [TBMVideo MR_findAllSortedBy:TBMVideoAttributes.videoId
                           ascending:YES
                       withPredicate:predicate
                           inContext:[self _context]];
        
        NSArray* videoModels = [[videos.rac_sequence map:^id(id value) {
            return [self modelFromEntity:value];
        }] array];
        
        return videoModels;
        
    });
}

#pragma mark - Helpers

+ (void)printAll
{
    ZZLogInfo(@"All Videos (%lu)", (unsigned long)[self countAllVideos]);
    for (ZZVideoDomainModel *videoModel in [self _all])
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

+ (NSArray *)_all
{
    return ZZDispatchOnMainThreadAndReturn(^id{
        return [[[TBMVideo MR_findAllInContext:[self _context]].rac_sequence map:^id(id value) {
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
