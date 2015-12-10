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
#import "ZZFriendDataUpdater.h"
#import "ZZFriendDomainModel.h"
#import "ZZVideoDomainModel.h"

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
    
    [ZZVideoDataUpdater deleteAllViewedOrFailedVideoWithFriendId:friendId];
}

#pragma mark - Notification part


- (void)setAndNotifyUploadRetryCount:(NSInteger)retryCount
                        withFriendID:(NSString*)friendID
                             videoID:(NSString*)videoID
{
    ANDispatchBlockToMainQueue(^{
        ZZFriendDomainModel* friend = [ZZFriendDataProvider friendWithItemID:friendID];

        if (![videoID isEqualToString:friend.outgoingVideoItemID])
        {
            ZZLogWarning(@"setAndNotifyUploadRetryCount: Unrecognized videoId. Ignoring.");
            return;
        }
        
        if (retryCount != friend.uploadRetryCount)
        {
            friend.uploadRetryCount = retryCount;
            friend.lastVideoStatusEventType = ZZVideoStatusEventTypeOutgoing;
            
            [ZZFriendDataUpdater upsertFriend:friend];
            [self _notifyObserversVideoStatusChangeWithFriendID:friendID];
        }
        else
        {
            ZZLogWarning(@"retryCount:%ld equals self.retryCount:%ld. Ignoring.", (long)retryCount, (long)friend.uploadRetryCount);
        }
    });
}

- (void)setAndNotifyDownloadRetryCount:(NSInteger)retryCount
                          withFriendID:(NSString*)friendID
                               videoID:(NSString*)videoID
{
    ANDispatchBlockToMainQueue(^{
        ZZFriendDomainModel* friend = [ZZFriendDataProvider friendWithItemID:friendID];
        ZZVideoDomainModel* video = [ZZVideoDataProvider itemWithID:videoID];
        
        if (video.downloadRetryCount == retryCount)
            return;
        
        video.downloadRetryCount = retryCount;
        [ZZVideoDataUpdater upsertVideo:video];
        
        if ([self _isNewestIncomingVideo:video withFriend:friend])
        {
            friend.lastVideoStatusEventType = ZZVideoStatusEventTypeIncoming;
            [ZZFriendDataUpdater upsertFriend:friend];
            
            //[friendEntity.managedObjectContext MR_saveToPersistentStoreAndWait];
            [self _notifyObserversVideoStatusChangeWithFriendID:friendID];
        }
    });
    
}

- (BOOL)_isNewestIncomingVideo:(ZZVideoDomainModel *)video withFriend:(ZZFriendDomainModel*)friend
{
    return [video isEqual:[self _newestIncomingVideoWithFriend:friend]];
}

- (ZZVideoDomainModel *)_newestIncomingVideoWithFriend:(ZZFriendDomainModel*)friend
{
    NSSortDescriptor *d = [[NSSortDescriptor alloc] initWithKey:ZZVideoDomainModelAttributes.videoID ascending:YES];
    NSArray* videos = [friend.videos sortedArrayUsingDescriptors:@[d]];
    
    return [videos lastObject];
}

#pragma mark - Outgoin video notification

- (void)notifyOutgoingVideoWithStatus:(ZZVideoOutgoingStatus)status
                         withFriendID:(NSString*)friendID
                          withVideoId:(NSString*)videoId;
{
    ANDispatchBlockToMainQueue(^{
        [ZZContentDataAcessor refreshContext:[ZZContentDataAcessor contextForCurrentThread]];
        ZZFriendDomainModel* friend = [ZZFriendDataProvider friendWithItemID:friendID];
        
        NSLog(@"OKS- videoID - %@, friendID - %@, friend.lastVideoID - %@ videoStatus: %li", videoId, friend.idTbm, friend.outgoingVideoItemID,(long)status);
        NSLog(@"THREAD: %@",[NSThread currentThread]);
        if (![videoId isEqualToString:friend.outgoingVideoItemID])
        {
            ZZLogWarning(@"setAndNotifyOutgoingVideoStatus: Unrecognized vidoeId:%@. != ougtoingVid:%@. friendId:%@ Ignoring.", videoId, friend.outgoingVideoItemID, friendID);
            return;
        }
        
        if (status == friend.outgoingVideoStatus)
        {
            ZZLogWarning(@"setAndNotifyOutgoingVideoStatusWithVideo: Identical status. Ignoring.");
            return;
        }
        
        friend.lastVideoStatusEventType = ZZVideoStatusEventTypeOutgoing;
        friend.outgoingVideoStatus = status;
        
        
        if (status == ZZVideoOutgoingStatusUploaded ||
            status == ZZVideoOutgoingStatusDownloaded ||
            status == ZZVideoOutgoingStatusViewed)
        {
            friend.lastActionTimestamp = [NSDate date];
        }
        
        [ZZFriendDataUpdater upsertFriend:friend];
        
        [self _notifyObserversVideoStatusChangeWithFriendID:friendID];
    });
}

- (void)setAndNotifyIncomingVideoStatus:(ZZVideoIncomingStatus)videoStatus
                               friendId:(NSString*)friendId
                                videoId:(NSString*)videoId;
{
    ANDispatchBlockToMainQueue(^{
        
        ZZVideoDomainModel* video = [ZZVideoDataProvider itemWithID:videoId];
        ZZFriendDomainModel* friend = [ZZFriendDataProvider friendWithItemID:friendId];
        
        if (video.incomingStatusValue != videoStatus)
        {
            video.incomingStatusValue = videoStatus;
            [ZZVideoDataUpdater upsertVideo:video];
            
            friend.lastIncomingVideoStatus = videoStatus;
            
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
                friend.lastActionTimestamp = [NSDate date];
            }
            
            [ZZFriendDataUpdater upsertFriend:friend];
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
    
    ZZFriendDomainModel* friend = [ZZFriendDataProvider friendWithItemID:friendID];
    [ZZApplicationRootService sendNotificationForVideoStatusUpdate:friend
                                                           videoId:videoID
                                                            status:NOTIFICATION_STATUS_VIEWED];
    
}

- (void)handleOutgoingVideoCreatedWithVideoId:(NSString*)videoId withFriendId:(NSString*)friendID
{
    ANDispatchBlockToMainQueue(^{
        ZZFriendDomainModel* friend = [ZZFriendDataProvider friendWithItemID:friendID];
        
        friend.uploadRetryCount = 0;
        friend.outgoingVideoItemID = videoId;
        
        [ZZFriendDataUpdater upsertFriend:friend];
        
        [self notifyOutgoingVideoWithStatus:ZZVideoOutgoingStatusNew withFriendID:friend.idTbm withVideoId:videoId];
    });
}

@end
