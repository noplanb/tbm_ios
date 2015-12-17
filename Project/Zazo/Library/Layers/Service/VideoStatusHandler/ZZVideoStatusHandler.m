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
#import "ZZFriendDataUpdater.h"
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
            if ([delegate respondsToSelector:@selector(videoStatusChangedWithFriendID:)]) {
                [delegate videoStatusChangedWithFriendID:friendID];
            }
        }
    });
}

- (void)_notifyObserveresSendNotificationForVideoStatusUpdate:(ZZFriendDomainModel *)friend videoId:(NSString *)videoID status:(NSString *)status
{
    ANDispatchBlockToMainQueue(^{
        for (id <ZZVideoStatusHandlerDelegate> delegate in self.observers)
        {
            if ([delegate respondsToSelector:@selector(sendNotificationForVideoStatusUpdate: videoId: status:)]) {
                [delegate sendNotificationForVideoStatusUpdate:friend videoId:videoID status:status];
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
                        withFriendID:(NSString*)friendID
                             videoID:(NSString*)videoID
{
    ANDispatchBlockToMainQueue(^{
        

        ZZFriendDomainModel *friend = [ZZFriendDataProvider friendWithItemID:friendID];
        [ZZContentDataAcessor refreshContext:[ZZContentDataAcessor mainThreadContext]];
        if (![videoID isEqualToString:friend.outgoingVideoItemID])
        {
            ZZLogWarning(@"setAndNotifyUploadRetryCount: Unrecognized vidoeId. Ignoring.");
            return;
        }
        
        if (retryCount != friend.uploadRetryCount)
        {
            [ZZFriendDataUpdater updateFriendWithID:friendID setUploadRetryCount:retryCount];
            [ZZFriendDataUpdater updateFriendWithID:friendID setLastVideoStatusEventType:ZZVideoStatusEventTypeOutgoing];
            
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
        
        ZZFriendDomainModel *friend = [ZZFriendDataProvider friendWithItemID:friendID];
        ZZVideoDomainModel *video = [ZZVideoDataProvider itemWithID:videoID];
        
        if (video.downloadRetryCount == retryCount)
            return;
        
        [ZZVideoDataUpdater updateVideoWithID:videoID setDownloadRetryCount:retryCount];
        
        if ([self _isNewestIncomingVideo:video withFriend:friend])
        {
            [ZZFriendDataUpdater updateFriendWithID:friendID setLastVideoStatusEventType:ZZVideoStatusEventTypeIncoming];

            [self _notifyObserversVideoStatusChangeWithFriendID:friendID];
        }
    });
}

- (BOOL)_isNewestIncomingVideo:(ZZVideoDomainModel *)video withFriend:(ZZFriendDomainModel*)friend
{
    return [video.videoID isEqualToString:[self _newestIncomingVideoWithFriend:friend].videoID];
}

- (ZZVideoDomainModel *)_newestIncomingVideoWithFriend:(ZZFriendDomainModel*)friend
{
    NSSortDescriptor *d = [[NSSortDescriptor alloc] initWithKey:@"videoID" ascending:YES];
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
        
        ZZFriendDomainModel * friend = [ZZFriendDataProvider friendWithItemID:friendID];
        
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
                               friendId:(NSString*)friendID
                                videoId:(NSString*)videoID;
{
    
    ANDispatchBlockToMainQueue(^{
        
        ZZVideoDomainModel *video = [ZZVideoDataProvider itemWithID:videoID];
        
        if (video.incomingStatusValue != videoStatus)
        {
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
    
    ZZFriendDomainModel* friend = [ZZFriendDataProvider friendWithItemID:friendID];
    [self _notifyObserveresSendNotificationForVideoStatusUpdate:friend videoId:videoID status:NOTIFICATION_STATUS_VIEWED];

}

- (void)handleOutgoingVideoCreatedWithVideoId:(NSString*)videoID withFriend:(NSString*)friendID
{
    ANDispatchBlockToMainQueue(^{

        ZZFriendDomainModel* friend = [ZZFriendDataProvider friendWithItemID:friendID];
        
        friend.outgoingVideoItemID = videoID;
        
        [ZZFriendDataUpdater updateFriendWithID:friendID setUploadRetryCount:0];
        [ZZFriendDataUpdater updateFriendWithID:friendID setOutgoingVideoItemID:videoID];
        
        [self notifyOutgoingVideoWithStatus:ZZVideoOutgoingStatusNew withFriendID:friendID withVideoId:videoID];
    });
}

@end
