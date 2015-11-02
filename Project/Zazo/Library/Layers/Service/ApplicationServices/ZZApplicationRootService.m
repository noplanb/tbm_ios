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
    TBMVideo* video = [ZZVideoDataProvider findWithVideoId:marker.videoID];
//    [friend handleOutgoingVideoCreatedWithVideoId:marker.videoID];
    [[ZZVideoStatusHandler sharedInstance] handleOutgoingVideoCreatedWithVideo:video withFriend:friend];
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

- (void)notifyOutgoinVideoWithStatus:(ZZVideoOutgoingStatus)status withFriend:(TBMFriend *)friend video:(TBMVideo *)video
{
    [[ZZVideoStatusHandler sharedInstance] notifyOutgoingVideoWithStatus:status withFriend:friend withVideo:video];
}

- (void)setAndNotifyUploadRetryCount:(NSInteger)count withFriend:(TBMFriend *)friend video:(TBMVideo *)video
{
    [[ZZVideoStatusHandler sharedInstance] setAndNotifyUploadRetryCount:count withFriend:friend video:video];
}

- (void)setAndNotifyIncomingVideoStatus:(ZZVideoIncomingStatus)status withFriend:(TBMFriend *)friend video:(TBMVideo *)video
{
    [[ZZVideoStatusHandler sharedInstance] setAndNotifyIncomingVideoStatus:status withFriend:friend withVideo:video];
}

- (void)deleteAllViewedOrFailedVideosForFriend:(TBMFriend *)friend
{
    [[ZZVideoStatusHandler sharedInstance] deleteAllViewedOrFailedVideoForFriend:friend]; //TODO: change delete method implementation?
}

- (void)setAndNotifyDownloadRetryCount:(NSInteger)retryCount withFriend:(TBMFriend *)friend video:(TBMVideo *)video
{
    [[ZZVideoStatusHandler sharedInstance] setAndNotifyDownloadRetryCount:retryCount withFriend:friend video:video];
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
    TBMVideo* video = [ZZVideoDataProvider entityWithID:model.videoID];
    [[ZZVideoStatusHandler sharedInstance] notifyOutgoingVideoWithStatus:outgoingStatus withFriend:friend withVideo:video];
}


#pragma mark - Data Update

- (void)freshVideoDetectedWithVideoID:(NSString*)videoID friendID:(NSString*)friendID
{
    [self.videoFileHandler queueDownloadWithFriendID:friendID videoId:videoID];
}


#pragma mark - Root Observer Delegate

- (void)handleEvent:(ZZRootStateObserverEvents)event
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
