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

- (void)_notifyObserversVideoStatusChangeForFriend:(TBMFriend*)friend
{
    ANDispatchBlockToMainQueue(^{
        for (id <ZZVideoStatusHandlerDelegate> delegate in self.observers)
        {
            [delegate videoStatusChangedForFriend:friend];
        }
    });
}


#pragma mark - Video status change methods

- (void)notifyFriendChanged:(TBMFriend*)friend
{
    [self _notifyObserversVideoStatusChangeForFriend:friend];
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
                          withFriend:(TBMFriend*)friend
                               video:(TBMVideo*)video
{
    [ZZContentDataAcessor refreshContext:friend.managedObjectContext];
    if (![video.videoId isEqualToString:friend.outgoingVideoId])
    {
        ZZLogWarning(@"setAndNotifyUploadRetryCount: Unrecognized vidoeId. Ignoring.");
        return;
    }
    
    if (retryCount != friend.uploadRetryCountValue)
    {
        friend.uploadRetryCount = @(retryCount);
        friend.lastVideoStatusEventTypeValue = ZZVideoStatusEventTypeOutgoing;
        [friend.managedObjectContext MR_saveToPersistentStoreAndWait];
        [self _notifyObserversVideoStatusChangeForFriend:friend];
    }
    else
    {
        ZZLogWarning(@"retryCount:%ld equals self.retryCount:%@. Ignoring.", (long)retryCount, friend.uploadRetryCount);
    }
}

- (void)setAndNotifyDownloadRetryCount:(NSInteger)retryCount
                            withFriend:(TBMFriend *)friend
                                 video:(TBMVideo *)video
{
    [ZZContentDataAcessor refreshContext:friend.managedObjectContext];
    [ZZContentDataAcessor refreshContext:video.managedObjectContext];
    
    if (video.downloadRetryCountValue == retryCount)
        return;
    
    video.downloadRetryCount = @(retryCount);
    [video.managedObjectContext MR_saveToPersistentStoreAndWait];
    [friend.managedObjectContext MR_saveToPersistentStoreAndWait];
    
    if ([self _isNewestIncomingVideo:video withFriend:friend])
    {
        friend.lastVideoStatusEventType = ZZVideoStatusEventTypeIncoming;
        [friend.managedObjectContext MR_saveToPersistentStoreAndWait];
        [self _notifyObserversVideoStatusChangeForFriend:friend];
    }
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
                           withFriend:(TBMFriend*)friend
                          withVideoId:(NSString*)videoId
{
    [ZZContentDataAcessor refreshContext:friend.managedObjectContext];
    if (![videoId isEqualToString:friend.outgoingVideoId])
    {
        ZZLogWarning(@"setAndNotifyOutgoingVideoStatus: Unrecognized vidoeId:%@. != ougtoingVid:%@. friendId:%@ Ignoring.", videoId, friend.outgoingVideoId, friend.idTbm);
        return;
    }
    
    if (status == friend.outgoingVideoStatusValue)
    {
        ZZLogWarning(@"setAndNotifyOutgoingVideoStatusWithVideo: Identical status. Ignoring.");
        return;
    }
    
    friend.lastVideoStatusEventTypeValue = ZZVideoStatusEventTypeOutgoing;
    friend.outgoingVideoStatusValue = status;
    
    
    if (status == ZZVideoOutgoingStatusUploaded ||
        status == ZZVideoOutgoingStatusDownloaded ||
        status == ZZVideoOutgoingStatusViewed)
    {
        friend.timeOfLastAction = [NSDate date];
    }
    
    [friend.managedObjectContext MR_saveToPersistentStoreAndWait];
    
    [self _notifyObserversVideoStatusChangeForFriend:friend];
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
            
            [self _notifyObserversVideoStatusChangeForFriend:friend];
        }
        else
        {
            ZZLogWarning(@"setAndNotifyIncomingVideoStatusWithVideo: Identical status. Ignoring.");
        }
        
    });
}

- (void)setAndNotityViewedIncomingVideoWithFriend:(TBMFriend*)friend video:(TBMVideo*)video
{
    [self setAndNotifyIncomingVideoStatus:ZZVideoIncomingStatusViewed friendId:friend.idTbm videoId:video.videoId];
    [ZZApplicationRootService sendNotificationForVideoStatusUpdate:friend
                                                           videoId:video.videoId
                                                            status:NOTIFICATION_STATUS_VIEWED];
    
}

- (void)handleOutgoingVideoCreatedWithVideoId:(NSString*)videoId withFriend:(TBMFriend*)friend
{
    friend.uploadRetryCount = 0;
    friend.outgoingVideoId = videoId;
    [self notifyOutgoingVideoWithStatus:ZZVideoOutgoingStatusNew withFriend:friend withVideoId:videoId];
}



@end
