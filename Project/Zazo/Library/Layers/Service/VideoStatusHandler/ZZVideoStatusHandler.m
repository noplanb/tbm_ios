//
//  ZZVideoStatusHandler.m
//  Zazo
//
//  Created by Oksana Kovalchuk on 11/1/15.
//  Copyright © 2015 No Plan B. All rights reserved.
//

#import "ZZVideoStatusHandler.h"
#import "ZZContentDataAcessor.h"
#import "ZZVideoDataUpdater.h"
#import "ZZApplicationRootService.h"
#import "ZZNotificationsConstants.h"
#import "ZZVideoStatuses.h"
#import "ZZVideoDataProvider.h"
#import "ZZFriendDataProvider.h"
#import "ZZFriendDomainModel.h"

@interface ZZVideoStatusHandler ()

@property (nonatomic, strong) NSMutableArray* observers;

@end

@implementation ZZVideoStatusHandler

+ (id)sharedInstance {
    static ZZVideoStatusHandler *sharedMyManager = nil;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        sharedMyManager = [[self alloc] init];
    });
    
    return sharedMyManager;
}

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        self.observers = [NSMutableArray array];
    }
    return self;
}


#pragma mark - Observer Methods

- (void)addVideoStatusHandlerObserver:(id <ZZVideoStatusHandlerDelegate>)observer
{
    [self.observers addObject:observer];
}

- (void)removeVideoStatusHandlerObserver:(id <ZZVideoStatusHandlerDelegate>)observer
{
    [self.observers removeObject:observer];
}

- (void)_notifyObserversVideoStatusChangeWithFriendID:(NSString*)friendID
{
    ANDispatchBlockToMainQueue(^{
        for (id <ZZVideoStatusHandlerDelegate> delegate in self.observers)
        {
            [delegate videoStatusChangedWithFriendID:friendID];
        }
    });
}


#pragma mark - Video status change methodsFF

- (void)notifyFriendChangedWithId:(NSString *)friendID
{
    [self _notifyObserversVideoStatusChangeWithFriendID:friendID];
}


#pragma mark - Delete Video Methods

- (void)deleteAllViewedOrFailedVideoWithFriendId:(NSString*)friendId
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

- (void)deleteVideo:(TBMVideo*)video withFriend:(TBMFriend*)friend
{
    [ZZVideoDataUpdater deleteFilesForVideo:video];
    [friend removeVideosObject:video];
    [ZZVideoDataUpdater destroy:video];
    [friend.managedObjectContext MR_saveToPersistentStoreAndWait];
}


#pragma mark - Notification part


- (void)setAndNotifyUploadRetryCount:(NSInteger)retryCount
                        withFriendID:(NSString*)friendID
                             videoID:(NSString*)videoID
{
    ANDispatchBlockToMainQueue(^{
        TBMFriend* friendEntity = [ZZFriendDataProvider friendEntityWithItemID:friendID];
        [ZZContentDataAcessor refreshContext:friendEntity.managedObjectContext];
        if (![videoID isEqualToString:friendEntity.outgoingVideoId])
        {
            ZZLogWarning(@"setAndNotifyUploadRetryCount: Unrecognized vidoeId. Ignoring.");
            return;
        }
        
        if (retryCount != friendEntity.uploadRetryCountValue)
        {
            friendEntity.uploadRetryCount = @(retryCount);
            friendEntity.lastVideoStatusEventTypeValue = ZZVideoStatusEventTypeOutgoing;
            [friendEntity.managedObjectContext MR_saveToPersistentStoreAndWait];
            [self _notifyObserversVideoStatusChangeWithFriendID:friendID];
        }
        else
        {
            ZZLogWarning(@"retryCount:%ld equals self.retryCount:%@. Ignoring.", (long)retryCount, friendEntity.uploadRetryCount);
        }
    });
}

- (void)setAndNotifyDownloadRetryCount:(NSInteger)retryCount
                          withFriendID:(NSString*)friendID
                               videoID:(NSString*)videoID
{
    ANDispatchBlockToMainQueue(^{
        TBMFriend* friendEntity = [ZZFriendDataProvider friendEntityWithItemID:friendID];
        TBMVideo* videoEntity = [ZZVideoDataProvider entityWithID:videoID];
        
        if (videoEntity.downloadRetryCountValue == retryCount)
            return;
        
        videoEntity.downloadRetryCount = @(retryCount);
        [videoEntity.managedObjectContext MR_saveToPersistentStoreAndWait];
        
        if ([self _isNewestIncomingVideo:videoEntity withFriend:friendEntity])
        {
            friendEntity.lastVideoStatusEventType = ZZVideoStatusEventTypeIncoming;
            [friendEntity.managedObjectContext MR_saveToPersistentStoreAndWait];
            [self _notifyObserversVideoStatusChangeWithFriendID:friendID];
        }
    });
}

- (BOOL)_isNewestIncomingVideo:(TBMVideo *)video withFriend:(TBMFriend*)friend
{
    return [video isEqual:[self _newestIncomingVideoWithFriend:friend]];
}

- (TBMVideo *)_newestIncomingVideoWithFriend:(TBMFriend*)friend
{
    NSSortDescriptor *d = [[NSSortDescriptor alloc] initWithKey:@"videoId" ascending:YES];
    NSArray* videos = [friend.videos sortedArrayUsingDescriptors:@[d]];
    
    return [videos lastObject];
}


#pragma mark - Outgoin video notification


- (void)notifyOutgoingVideoWithStatus:(ZZVideoOutgoingStatus)status
                         withFriendID:(NSString*)friendID
                          withVideoId:(NSString*)videoId;
{
    ANDispatchBlockToMainQueue(^{
        [ZZContentDataAcessor refreshContext:[ZZContentDataAcessor mainThreadContext]];
        TBMFriend* friendEntity = [ZZFriendDataProvider friendEntityWithItemID:friendID];
        
        NSLog(@"OKS- videoID - %@, friendID - %@, friend.lastVideoID - %@ videoStatus: %li", videoId, friendEntity.idTbm, friendEntity.outgoingVideoId,(long)status);
        NSLog(@"THREAD: %@",[NSThread currentThread]);
        if (![videoId isEqualToString:friendEntity.outgoingVideoId])
        {
            ZZLogWarning(@"setAndNotifyOutgoingVideoStatus: Unrecognized vidoeId:%@. != ougtoingVid:%@. friendId:%@ Ignoring.", videoId, friendEntity.outgoingVideoId, friendID);
            return;
        }
        
        if (status == friendEntity.outgoingVideoStatusValue)
        {
            ZZLogWarning(@"setAndNotifyOutgoingVideoStatusWithVideo: Identical status. Ignoring.");
            return;
        }
        
        friendEntity.lastVideoStatusEventTypeValue = ZZVideoStatusEventTypeOutgoing;
        friendEntity.outgoingVideoStatusValue = status;
        
        
        if (status == ZZVideoOutgoingStatusUploaded ||
            status == ZZVideoOutgoingStatusDownloaded ||
            status == ZZVideoOutgoingStatusViewed)
        {
            friendEntity.timeOfLastAction = [NSDate date];
        }
        
        [friendEntity.managedObjectContext MR_saveToPersistentStoreAndWait];
        
        [self _notifyObserversVideoStatusChangeWithFriendID:friendID];
    });
}

- (void)setAndNotifyIncomingVideoStatus:(ZZVideoIncomingStatus)videoStatus
                               friendId:(NSString*)friendId
                                videoId:(NSString*)videoId;
{
    
    ANDispatchBlockToMainQueue(^{
    
        TBMVideo* video = [ZZVideoDataProvider entityWithID:videoId];
        TBMFriend* friend = [ZZFriendDataProvider friendEntityWithItemID:friendId];
        
        if (video.statusValue != videoStatus)
        {
            video.statusValue = videoStatus;
            [video.managedObjectContext MR_saveToPersistentStoreAndWait];
            
            friend.lastIncomingVideoStatusValue = videoStatus;
            
            // Serhii says: We want to preserve previous status if last event type is incoming and status is VIEWED
            // Sani complicates it by saying: This is a bit subtle. We don't want an action by this user of
            // viewing his incoming video to count
            // as cause a change in lastVideoStatusEventType. That way if the last action by the user was sending a
            // video (recording on a person with unviewed indicator showing) then later viewed the incoming videos
            // he gets to see the status of the last outgoing video he sent after play is complete and the unviewed count
            // indicator goes away.
            if (videoStatus != ZZVideoIncomingStatusViewed)
            {
                friend.lastVideoStatusEventType = ZZVideoStatusEventTypeIncoming;
            }
            
            
            if (videoStatus == ZZVideoIncomingStatusDownloaded || videoStatus == ZZVideoIncomingStatusViewed)
            {
                friend.timeOfLastAction = [NSDate date];
            }
            
            [friend.managedObjectContext MR_saveToPersistentStoreAndWait];
            
            [self _notifyObserversVideoStatusChangeWithFriendID:friendId];
        }
        else
        {
            ZZLogWarning(@"setAndNotifyIncomingVideoStatusWithVideo: Identical status. Ignoring.");
        }
        
    });
}


- (void)setAndNotityViewedIncomingVideoWithFriendID:(NSString *)friendID videoID:(NSString *)videoID
{
    [self setAndNotifyIncomingVideoStatus:ZZVideoIncomingStatusViewed friendId:friendID videoId:videoID];
    TBMFriend* friend = [ZZFriendDataProvider friendEntityWithItemID:friendID];
    [ZZApplicationRootService sendNotificationForVideoStatusUpdate:friend
                                                           videoId:videoID
                                                            status:NOTIFICATION_STATUS_VIEWED];
    
}

- (void)handleOutgoingVideoCreatedWithVideoId:(NSString*)videoId withFriend:(NSString*)friendID
{
    ANDispatchBlockToMainQueue(^{
        TBMFriend* friendEntity = [ZZFriendDataProvider friendEntityWithItemID:friendID];
        
        friendEntity.uploadRetryCount = 0;
        friendEntity.outgoingVideoId = videoId;
        [friendEntity.managedObjectContext MR_saveToPersistentStoreAndWait];
        
        [self notifyOutgoingVideoWithStatus:ZZVideoOutgoingStatusNew withFriendID:friendEntity.idTbm withVideoId:videoId];
    });
}

@end
