//
//  ZZApplicationRootService.m
//  Zazo
//
//  Created by Oksana Kovalchuk on 10/20/15.
//  Copyright © 2015 No Plan B. All rights reserved.
//

#import "ZZApplicationRootService.h"
#import "ZZVideoFileHandler.h"
#import "TBMVideoProcessor.h"
#import "TBMVideoRecorder.h"
#import "ZZVideoRecorder.h"
#import "TBMVideoIdUtils.h"
#import "ZZApplicationDataUpdaterService.h"
#import "ZZNotificationDomainModel.h"
#import "ZZUserDomainModel.h"
#import "ZZNotificationTransportService.h"
#import "ZZUserDataProvider.h"
#import "ZZFriendDataProvider.h"
#import "ZZContentDataAcessor.h"
#import "ZZApplicationPermissionsHandler.h"
#import "ZZVideoDataProvider.h"
#import "ZZRootStateObserver.h"
#import "ZZFriendDomainModel.h"
#import "ZZVideoStatusHandler.h"

@interface ZZApplicationRootService ()
<
    ZZVideoFileHandlerDelegate,
    ZZApplicationDataUpdaterServiceDelegate,
    ZZRootStateObserverDelegate
>

@property (nonatomic, strong) ZZVideoFileHandler* videoFileHandler;
@property (nonatomic, strong) ZZApplicationDataUpdaterService* dataUpdater;
@property (nonatomic, assign) UIBackgroundTaskIdentifier backgroundTaskID;

@end

@implementation ZZApplicationRootService

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        self.videoFileHandler = [ZZVideoFileHandler new];
        self.videoFileHandler.delegate = self;
        
        self.dataUpdater = [ZZApplicationDataUpdaterService new];
        self.dataUpdater.delegate = self;
        
        [[ZZRootStateObserver sharedInstance] addRootStateObserver:self];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(_videoProcessorDidFinishProcessingNotification:)
                                                     name:TBMVideoProcessorDidFinishProcessing
                                                   object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(_videoDidStartRecording:)
                                                     name:TBMVideoRecorderShouldStartRecording
                                                   object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(_videoDidFinishRecording:)
                                                     name:TBMVideoRecorderDidCancelRecording
                                                   object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(_videoDidFinishRecording:)
                                                     name:TBMVideoRecorderDidFail
                                                   object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(_videoDidFinishRecording:)
                                                     name:TBMVideoRecorderDidFinishRecording
                                                   object:nil];
    }
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [[ZZRootStateObserver sharedInstance] removeRootStateObserver:self];
}

- (void)updateDataRequired
{
    [self.dataUpdater updateAllData];
}

- (void)applicationBecameActive
{
    [self.dataUpdater updateAllData];
}

- (void)_videoDidStartRecording:(id)sender
{
    [UIApplication sharedApplication].idleTimerDisabled = YES;
}

- (void)_videoDidFinishRecording:(id)sender
{
    [UIApplication sharedApplication].idleTimerDisabled = NO;
}

- (void)_videoProcessorDidFinishProcessingNotification:(NSNotification *)notification
{
    NSURL *videoUrl = [notification.userInfo objectForKey:@"videoUrl"];
    ZZFileTransferMarkerDomainModel* marker = [TBMVideoIdUtils markerModelWithOutgoingVideoURL:videoUrl];

    TBMFriend* friend = [ZZFriendDataProvider friendEntityWithItemID:marker.friendID];
    [[ZZVideoStatusHandler sharedInstance] handleOutgoingVideoCreatedWithVideoId:marker.videoID withFriend:friend];
    
    [self.videoFileHandler uploadWithVideoUrl:videoUrl friendCKey:friend.ckey];
}

- (void)checkApplicationPermissionsAndResources
{
    ZZLogInfo(@"performDidBecomeActiveActions: registered: %d", [ZZUserDataProvider authenticatedUser].isRegistered);
    
    if ([ZZUserDataProvider authenticatedUser].isRegistered)
    {
        [[ZZApplicationPermissionsHandler checkApplicationPermissions] subscribeNext:^(id x) {
            [ZZNotificationsHandler registerToPushNotifications];
            [ZZVideoDataProvider printAll];
            [self.videoFileHandler startService];
        }];
    }
}

- (void)handleBackgroundSessionWithIdentifier:(NSString *)identifier completionHandler:(ANCodeBlock)completionHandler
{
    [self.videoFileHandler handleBackgroundSessionWithIdentifier:identifier completionHandler:completionHandler];
}

#pragma mark - File Handler Delegate

- (void)requestBackground
{
    ZZLogInfo(@"AppDelegate: requestBackground: called:");
    if (self.backgroundTaskID == UIBackgroundTaskInvalid ) {
        ZZLogInfo(@"AppDelegate: requestBackground: requesting background.");
        self.backgroundTaskID = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^{
            ZZLogInfo(@"AppDelegate: Ending background");
            [[UIApplication sharedApplication] endBackgroundTask:self.backgroundTaskID];
            [ZZContentDataAcessor saveDataBase];
            self.backgroundTaskID = UIBackgroundTaskInvalid;
        }];
    }
    ZZLogInfo(@"AppDelegate: RequestBackground: exiting: refresh status = %ld, time Remaining = %f",
            (long)[UIApplication sharedApplication].backgroundRefreshStatus,
            [UIApplication sharedApplication].backgroundTimeRemaining);
}

- (void)sendNotificationForVideoReceived:(TBMFriend*)friend videoId:(NSString *)videoId
{
    ZZUserDomainModel* me = [ZZUserDataProvider authenticatedUser];
    ZZFriendDomainModel* friendModel = [ZZFriendDataProvider modelFromEntity:friend];
    [[ZZNotificationTransportService sendVideoReceivedNotificationTo:friendModel
                                                         videoItemID:videoId
                                                                from:me] subscribeNext:^(id x) {}];
}

- (void)sendNotificationForVideoStatusUpdate:(TBMFriend *)friend videoId:(NSString *)videoId status:(NSString *)status
{
    [ZZApplicationRootService sendNotificationForVideoStatusUpdate:friend videoId:videoId status:status];
}

//TODO: it's for legacy with TBMFriend
+ (void)sendNotificationForVideoStatusUpdate:(TBMFriend *)friend videoId:(NSString *)videoId status:(NSString *)status
{
    ZZUserDomainModel* me = [ZZUserDataProvider authenticatedUser];
    ZZFriendDomainModel* friendModel = [ZZFriendDataProvider modelFromEntity:friend];
    
    [[ZZNotificationTransportService sendVideoStatusUpdateNotificationTo:friendModel
                                                             videoItemID:videoId
                                                                  status:status from:me] subscribeNext:^(id x) {}];
}

- (void)updateBadgeCounter
{
    [self.dataUpdater updateApplicationBadge];
}


#pragma mark - Video status handler

- (void)notifyOutgoingVideoWithStatus:(ZZVideoOutgoingStatus)status withFriend:(TBMFriend *)friendModel videoId:(NSString *)videoId
{
    [[ZZVideoStatusHandler sharedInstance] notifyOutgoingVideoWithStatus:status withFriend:friendModel withVideoId:videoId];
}

- (void)setAndNotifyUploadRetryCount:(NSInteger)count withFriend:(TBMFriend *)friendModel video:(TBMVideo *)video
{
    [[ZZVideoStatusHandler sharedInstance] setAndNotifyUploadRetryCount:count withFriend:friendModel video:video];
}

- (void)setAndNotifyIncomingVideoStatus:(ZZVideoIncomingStatus)status friendId:(NSString *)friendId videoId:(NSString *)videoId
{
    [[ZZVideoStatusHandler sharedInstance] setAndNotifyIncomingVideoStatus:status friendId:friendId videoId:videoId];
}

- (void)deleteAllViewedOrFailedVideosWithFriendId:(NSString *)friendId
{
    [[ZZVideoStatusHandler sharedInstance] deleteAllViewedOrFailedVideoWithFriendId:friendId];
}

- (void)setAndNotifyDownloadRetryCount:(NSInteger)retryCount withFriend:(TBMFriend *)friendModel video:(TBMVideo *)video
{
    [[ZZVideoStatusHandler sharedInstance] setAndNotifyDownloadRetryCount:retryCount withFriend:friendModel video:video];
}


#pragma mark - Notification Delegate

- (void)handleVideoReceivedNotification:(ZZNotificationDomainModel *)model
{
    ZZFriendDomainModel* friendModel = [ZZFriendDataProvider friendWithMKeyValue:model.fromUserMKey];
    
    if (friendModel)
    {
        [self.videoFileHandler queueDownloadWithFriendID:friendModel.idTbm videoId:model.videoID];
    }
    else
    {
        ZZLogInfo(@"handleVideoReceivedNotification: got notification for non existant friend. calling getAndPollAllFriends");
        [self.dataUpdater updateAllData];
    }
}

- (void)handleVideoStatusUpdateNotification:(ZZNotificationDomainModel*)model
{
    ZZFriendDomainModel* friendModel = [ZZFriendDataProvider friendWithMKeyValue:model.fromUserMKey];
    
    
    if (friendModel == nil)
    {
        ZZLogInfo(@"handleVideoStatusUPdateNotification: got notification for non existant friend. calling getAndPollAllFriends");
        [self.dataUpdater updateAllData];
        return;
    }
    
    ZZVideoOutgoingStatus outgoingStatus;
    if ([model.status isEqualToString:NOTIFICATION_STATUS_DOWNLOADED])
    {
        outgoingStatus = ZZVideoOutgoingStatusDownloaded;
    }
    else if ([model.status isEqualToString:NOTIFICATION_STATUS_VIEWED])
    {
        outgoingStatus = ZZVideoOutgoingStatusViewed;
    }
    else
    {
        ZZLogError(@"unknown status received in notification");
        return;
    }
    
    ZZFriendDomainModel* updatedFriendModel = [ZZFriendDataProvider friendWithMKeyValue:model.toUserMKey];
    
    TBMFriend* friend = [ZZFriendDataProvider entityFromModel:updatedFriendModel];
    [[ZZVideoStatusHandler sharedInstance] notifyOutgoingVideoWithStatus:outgoingStatus
                                                              withFriend:friend
                                                             withVideoId:model.videoID];
}


#pragma mark - Data Update

- (void)freshVideoDetectedWithVideoID:(NSString*)videoID friendID:(NSString*)friendID
{
    [self.videoFileHandler queueDownloadWithFriendID:friendID videoId:videoID];
}


#pragma mark - Root Observer Delegate

- (void)handleEvent:(ZZRootStateObserverEvents)event notificationObject:(id)notificationObject
{
    if (event == ZZRootStateObserverEventsUserAuthorized)
    {
        [self.videoFileHandler updateS3CredentialsWithRequest];
    }
    else if (event == ZZRootStateObserverEventsFriendsAfterAuthorizationLoaded)
    {
        [self.dataUpdater updateAllDataWithoutRequest];
    }
}

@end
