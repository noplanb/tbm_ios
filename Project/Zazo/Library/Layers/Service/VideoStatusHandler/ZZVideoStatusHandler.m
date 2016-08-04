//
//  ZZVideoStatusHandler.m
//  Zazo
//
//  Created by Oksana Kovalchuk on 11/1/15.
//  Copyright © 2015 No Plan B. All rights reserved.
//

#import "ZZVideoStatusHandler.h"
#import "ZZContentDataAccessor.h"
#import "ZZVideoDataUpdater.h"
#import "ZZApplicationRootService.h"
#import "ZZNotificationsConstants.h"
#import "ZZVideoStatuses.h"
#import "ZZVideoDataProvider.h"
#import "ZZFriendDataProvider.h"
#import "ZZFriendDomainModel.h"
#import "ZZFriendDataUpdater.h"
#import "ZZVideoDomainModel.h"
#import "ZZThumbnailGenerator.h"

@interface ZZVideoStatusHandler ()

@property (nonatomic, strong) NSMutableArray *observers;

@end

@implementation ZZVideoStatusHandler

+ (id)sharedInstance
{
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

- (void)_notifyObserversVideoStatusChangeWithFriendID:(NSString *)friendID
{
    ANDispatchBlockToMainQueue(^{
        for (id <ZZVideoStatusHandlerDelegate> delegate in self.observers)
        {
            if ([delegate respondsToSelector:@selector(videoStatusChangedWithFriendID:)])
            {
                [delegate videoStatusChangedWithFriendID:friendID];
            }
        }
    });
}

- (void)_notifyObserveresSendNotificationForVideoStatusUpdate:(ZZFriendDomainModel *)friendModel videoId:(NSString *)videoID status:(NSString *)status
{
    ANDispatchBlockToMainQueue(^{
        for (id <ZZVideoStatusHandlerDelegate> delegate in self.observers)
        {
            if ([delegate respondsToSelector:@selector(sendNotificationForVideoStatusUpdate: videoId: status:)])
            {
                [delegate sendNotificationForVideoStatusUpdate:friendModel videoId:videoID status:status];
            }
        }
    });
}


#pragma mark - Video status change methodsFF

- (void)notifyFriendChangedWithId:(NSString *)friendID
{
    [self _notifyObserversVideoStatusChangeWithFriendID:friendID];
}

#pragma mark - Notification part


- (void)setAndNotifyUploadRetryCount:(NSInteger)retryCount
                        withFriendID:(NSString *)friendID
                             videoID:(NSString *)videoID
{
    ANDispatchBlockToMainQueue(^{


        ZZFriendDomainModel *friendModel = [ZZFriendDataProvider friendWithItemID:friendID];
        [ZZContentDataAccessor refreshContext:[ZZContentDataAccessor mainThreadContext]];
        if (![videoID isEqualToString:friendModel.outgoingVideoItemID])
        {
            ZZLogWarning(@"setAndNotifyUploadRetryCount: Unrecognized vidoeId. Ignoring.");
            return;
        }

        if (retryCount != friendModel.uploadRetryCount)
        {
            [ZZFriendDataUpdater updateFriendWithID:friendID setUploadRetryCount:retryCount];
            [ZZFriendDataUpdater updateFriendWithID:friendID setLastVideoStatusEventType:ZZVideoStatusEventTypeOutgoing];

            [self _notifyObserversVideoStatusChangeWithFriendID:friendID];
        }
        else
        {
            ZZLogWarning(@"retryCount:%ld equals self.retryCount:%ld. Ignoring.", (long)retryCount, (long)friendModel.uploadRetryCount);
        }
    });
}

- (void)setAndNotifyDownloadRetryCount:(NSInteger)retryCount
                          withFriendID:(NSString *)friendID
                               videoID:(NSString *)videoID
{
    ANDispatchBlockToMainQueue(^{

        ZZFriendDomainModel *friendModel = [ZZFriendDataProvider friendWithItemID:friendID];
        ZZVideoDomainModel *videoModel = [ZZVideoDataProvider itemWithID:videoID];

        if (videoModel.downloadRetryCount == retryCount)
            return;

        [ZZVideoDataUpdater updateVideoWithID:videoID setDownloadRetryCount:retryCount];

        if ([self _isNewestIncomingVideo:videoModel withFriend:friendModel])
        {
            [ZZFriendDataUpdater updateFriendWithID:friendID setLastVideoStatusEventType:ZZVideoStatusEventTypeIncoming];

            [self _notifyObserversVideoStatusChangeWithFriendID:friendID];
        }
    });
}

- (BOOL)_isNewestIncomingVideo:(ZZVideoDomainModel *)videoModel withFriend:(ZZFriendDomainModel *)friendModel
{
    return [videoModel.videoID isEqualToString:[self _newestIncomingVideoWithFriend:friendModel].videoID];
}

- (ZZVideoDomainModel *)_newestIncomingVideoWithFriend:(ZZFriendDomainModel *)friendModel
{
    NSSortDescriptor *d = [[NSSortDescriptor alloc] initWithKey:@"videoID" ascending:YES];
    NSArray *videos = [friendModel.videos sortedArrayUsingDescriptors:@[d]];

    return [videos lastObject];
}


#pragma mark - Outgoin video notification


- (void)notifyOutgoingVideoWithStatus:(ZZVideoOutgoingStatus)status
                         withFriendID:(NSString *)friendID
                          withVideoId:(NSString *)videoID;
{
    ANDispatchBlockToMainQueue(^{
        [ZZContentDataAccessor refreshContext:[ZZContentDataAccessor mainThreadContext]];

        ZZFriendDomainModel *friendModel = [ZZFriendDataProvider friendWithItemID:friendID];

        NSLog(@"OKS- videoID - %@, friendID - %@, friend.lastVideoID - %@ videoStatus: %li", videoID, friendModel.idTbm, friendModel.outgoingVideoItemID, (long)status);
        NSLog(@"THREAD: %@", [NSThread currentThread]);

        if (![videoID isEqualToString:friendModel.outgoingVideoItemID])
        {
            ZZLogWarning(@"setAndNotifyOutgoingVideoStatus: Unrecognized vidoeId:%@. != ougtoingVid:%@. friendId:%@ Ignoring.", videoID, friendModel.outgoingVideoItemID, friendID);
            return;
        }

        if (status == friendModel.lastOutgoingVideoStatus)
        {
            ZZLogWarning(@"setAndNotifyOutgoingVideoStatusWithVideo: Identical status. Ignoring.");
            return;
        }

        [ZZFriendDataUpdater updateFriendWithID:friendID setLastVideoStatusEventType:ZZVideoStatusEventTypeOutgoing];
        [ZZFriendDataUpdater updateFriendWithID:friendID setOutgoingVideoStatus:status];

        if (status == ZZVideoOutgoingStatusUploaded ||
                status == ZZVideoOutgoingStatusDownloaded ||
                status == ZZVideoOutgoingStatusViewed)
        {
            [ZZFriendDataUpdater updateLastTimeActionFriendWithID:friendID];
        }

        [self _notifyObserversVideoStatusChangeWithFriendID:friendID];
    });
}

- (void)setAndNotifyIncomingVideoStatus:(ZZVideoIncomingStatus)videoStatus
                               friendId:(NSString *)friendID
                                videoId:(NSString *)videoID;
{

    ANDispatchBlockToMainQueue(^{

        ZZVideoDomainModel *videoModel = [ZZVideoDataProvider itemWithID:videoID];

        if (videoModel.incomingStatusValue != videoStatus)
        {
            
            if (videoStatus == ZZVideoIncomingStatusDownloaded)
            {
                BOOL validThumbnail = [ZZThumbnailGenerator generateThumbVideo:videoModel];
                
                if (validThumbnail)
                {
                    [ZZVideoDataUpdater deleteAllViewedVideosWithFriendID:friendID
                                                        exceptVideoWithID:self.currentlyPlayedVideoID];
                }
                
            }

            [ZZMessageDataUpdater deleteReadMessagesForFriendWithID:friendID];

            [ZZFriendDataUpdater updateFriendWithID:friendID setLastEventType:ZZIncomingEventTypeVideo];
            [ZZVideoDataUpdater updateVideoWithID:videoID setIncomingStatus:videoStatus];
            [ZZFriendDataUpdater updateFriendWithID:friendID setLastIncomingVideoStatus:videoStatus];

            // Serhii says: We want to preserve previous status if last event type is incoming and status is VIEWED
            // Sani complicates it by saying: This is a bit subtle. We don't want an action by this user of
            // viewing his incoming video to count
            // as cause a change in lastVideoStatusEventType. That way if the last action by the user was sending a
            // video (recording on a person with unviewed indicator showing) then later viewed the incoming videos
            // he gets to see the status of the last outgoing video he sent after play is complete and the unviewed count
            // indicator goes away.

            if (videoStatus != ZZVideoIncomingStatusViewed)
            {
                [ZZFriendDataUpdater updateFriendWithID:friendID setLastVideoStatusEventType:ZZVideoStatusEventTypeIncoming];
            }

            if (videoStatus == ZZVideoIncomingStatusDownloaded || videoStatus == ZZVideoIncomingStatusViewed)
            {
                [ZZFriendDataUpdater updateLastTimeActionFriendWithID:friendID];
            }

            [self _notifyObserversVideoStatusChangeWithFriendID:friendID];
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

    ZZFriendDomainModel *friendModel = [ZZFriendDataProvider friendWithItemID:friendID];
    [self _notifyObserveresSendNotificationForVideoStatusUpdate:friendModel videoId:videoID status:NOTIFICATION_STATUS_VIEWED];

}

- (void)handleOutgoingVideoCreatedWithVideoId:(NSString *)videoID withFriend:(NSString *)friendID
{
    ANDispatchBlockToMainQueue(^{

        ZZFriendDomainModel *friendModel = [ZZFriendDataProvider friendWithItemID:friendID];

        friendModel.outgoingVideoItemID = videoID;

        [ZZFriendDataUpdater updateFriendWithID:friendID setUploadRetryCount:0];
        [ZZFriendDataUpdater updateFriendWithID:friendID setOutgoingVideoItemID:videoID];

        [self notifyOutgoingVideoWithStatus:ZZVideoOutgoingStatusNew withFriendID:friendID withVideoId:videoID];
    });
}

- (void)notifyVideoID:(NSString *)videoID downloadProgress:(CGFloat)progress
{
    ANDispatchBlockToMainQueue(^{
        for (id <ZZVideoStatusHandlerDelegate> delegate in self.observers)
        {
            if ([delegate respondsToSelector:@selector(videoID:downloadProgress:)])
            {
                [delegate videoID:videoID downloadProgress:progress];
            }
        }
    });

}

@end
