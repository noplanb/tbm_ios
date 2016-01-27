//
//  ZZApplicationRootService.m
//  Zazo
//
//  Created by Oksana Kovalchuk on 10/20/15.
//  Copyright © 2015 No Plan B. All rights reserved.
//

#import "ZZApplicationRootService.h"
#import "ZZLegacyVideoFileHandler.h"
#import "TBMVideoProcessor.h"
#import "ZZVideoRecorder.h"
#import "TBMVideoIDUtils.h"
#import "ZZApplicationDataUpdaterService.h"
#import "ZZNotificationDomainModel.h"
#import "ZZUserDomainModel.h"
#import "ZZNotificationTransportService.h"
#import "ZZUserDataProvider.h"
#import "ZZFriendDataProvider.h"
#import "ZZContentDataAccessor.h"
#import "ZZApplicationPermissionsHandler.h"
#import "ZZVideoDataProvider.h"
#import "ZZRootStateObserver.h"
#import "ZZFriendDomainModel.h"
#import "ZZVideoStatusHandler.h"
#import "ZZVideoDataUpdater.h"


@interface ZZApplicationRootService ()
<
    ZZVideoFileHandlerDelegate,
    ZZApplicationDataUpdaterServiceDelegate,
    ZZRootStateObserverDelegate,
    ZZVideoStatusHandlerDelegate
>

@property (nonatomic, strong) ZZLegacyVideoFileHandler * videoFileHandler;
@property (nonatomic, strong) ZZApplicationDataUpdaterService* dataUpdater;
@property (nonatomic, assign) UIBackgroundTaskIdentifier backgroundTaskID;

@end

@implementation ZZApplicationRootService

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        self.videoFileHandler = [ZZLegacyVideoFileHandler new];
        self.videoFileHandler.delegate = self;
        
        self.dataUpdater = [ZZApplicationDataUpdaterService new];
        self.dataUpdater.delegate = self;
        
        [[ZZRootStateObserver sharedInstance] addRootStateObserver:self];
        [[ZZVideoStatusHandler sharedInstance] addVideoStatusHandlerObserver:self];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(_videoProcessorDidFinishProcessingNotification:)
                                                     name:TBMVideoProcessorDidFinishProcessing
                                                   object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(_videoDidStartRecording:)
                                                     name:kZZVideoRecorderDidStartVideoCapture
                                                   object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(_videoDidEndRecording:)
                                                     name:kZZVideoRecorderDidEndVideoCapture
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

- (void)_videoDidEndRecording:(id)sender
{
    [UIApplication sharedApplication].idleTimerDisabled = NO;
}

- (void)_videoProcessorDidFinishProcessingNotification:(NSNotification *)notification
{
    NSURL *videoUrl = [notification.userInfo objectForKey:@"videoUrl"];
    ZZFileTransferMarkerDomainModel* marker = [TBMVideoIDUtils markerModelWithOutgoingVideoURL:videoUrl];

    ZZFriendDomainModel *friendModel = [ZZFriendDataProvider friendWithItemID:marker.friendID];
    [[ZZVideoStatusHandler sharedInstance] handleOutgoingVideoCreatedWithVideoID:marker.videoID withFriend:friendModel.idTbm];
    [self.videoFileHandler uploadWithVideoUrl:videoUrl friendCKey:friendModel.cKey];
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
    if (self.backgroundTaskID == UIBackgroundTaskInvalid )
    {
        ZZLogInfo(@"AppDelegate: requestBackground: requesting background.");
        self.backgroundTaskID = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^{
            ZZLogInfo(@"AppDelegate: Ending background");
            [[UIApplication sharedApplication] endBackgroundTask:self.backgroundTaskID];
            [ZZContentDataAccessor saveDataBase];
            self.backgroundTaskID = UIBackgroundTaskInvalid;
        }];
    }
    ZZLogInfo(@"AppDelegate: RequestBackground: exiting: refresh status = %ld, time Remaining = %f",
            (long)[UIApplication sharedApplication].backgroundRefreshStatus,
            [UIApplication sharedApplication].backgroundTimeRemaining);
}

- (void)sendNotificationForVideoReceived:(ZZFriendDomainModel *)friendModel videoID:(NSString *)videoID
{
    ZZUserDomainModel* me = [ZZUserDataProvider authenticatedUser];

    [[ZZNotificationTransportService sendVideoReceivedNotificationTo:friendModel
                                                         videoItemID:videoID
                                                                from:me] subscribeNext:^(id x) {}];
    
}

- (void)sendNotificationForVideoStatusUpdate:(ZZFriendDomainModel *)friendModel videoID:(NSString *)videoID status:(NSString *)status
{
    ZZUserDomainModel* me = [ZZUserDataProvider authenticatedUser];
    [[ZZNotificationTransportService sendVideoStatusUpdateNotificationTo:friendModel
                                                             videoItemID:videoID
                                                                  status:status from:me] subscribeNext:^(id x) {}];
}

//TODO: it's for legacy with TBMFriend
//+ (void)sendNotificationForVideoStatusUpdate:(ZZFriendDomainModel *)friend videoId:(NSString *)videoId status:(NSString *)status
//{

//    ZZFriendDomainModel* friendModel = [ZZFriendDataProvider modelFromEntity:friend];
//}

- (void)updateBadgeCounter
{
    [self.dataUpdater updateApplicationBadge];
}


#pragma mark - Video status handlerfriendID

- (void)notifyOutgoingVideoWithStatus:(ZZVideoOutgoingStatus)status withFriendID:(NSString *)friendID videoID:(NSString *)videoID
{
    [[ZZVideoStatusHandler sharedInstance] notifyOutgoingVideoWithStatus:status withFriendID:friendID withVideoID:videoID];
}


- (void)setAndNotifyUploadRetryCount:(NSInteger)count withFriendID:(NSString *)friendID videoID:(NSString *)videoID
{
    [[ZZVideoStatusHandler sharedInstance] setAndNotifyUploadRetryCount:count withFriendID:friendID videoID:videoID];
}

- (void)setAndNotifyIncomingVideoStatus:(ZZVideoIncomingStatus)status friendID:(NSString *)friendID videoID:(NSString *)videoID
{
    [[ZZVideoStatusHandler sharedInstance] setAndNotifyIncomingVideoStatus:status friendID:friendID videoID:videoID];
}


- (void)setAndNotifyDownloadRetryCount:(NSInteger)retryCount withFriendID:(NSString *)friendID videoID:(NSString *)videoID
{
    [[ZZVideoStatusHandler sharedInstance] setAndNotifyDownloadRetryCount:retryCount withFriendID:friendID videoID:videoID];
}


#pragma mark - Notification Delegate

- (void)handleVideoReceivedNotification:(ZZNotificationDomainModel *)notificationModel
{
    ZZFriendDomainModel* friendModel = [ZZFriendDataProvider friendWithMKeyValue:notificationModel.fromUserMKey];
    
    if (friendModel)
    {
        [self.videoFileHandler queueDownloadWithFriendID:friendModel.idTbm videoID:notificationModel.videoID];
    }
    else
    {
        ZZLogInfo(@"handleVideoReceivedNotification: got notification for non existant friend. calling getAndPollAllFriends");
        [self.dataUpdater updateAllData];
    }
}

- (void)handleVideoStatusUpdateNotification:(ZZNotificationDomainModel*)notificationModel
{
    ZZFriendDomainModel* friendModel = [ZZFriendDataProvider friendWithMKeyValue:notificationModel.toUserMKey];
    
    
    if (friendModel == nil)
    {
        ZZLogInfo(@"handleVideoStatusUPdateNotification: got notification for non existant friend. calling getAndPollAllFriends");
        [self.dataUpdater updateAllData];
        return;
    }
    
    ZZVideoOutgoingStatus outgoingStatus;
    if ([notificationModel.status isEqualToString:NOTIFICATION_STATUS_DOWNLOADED])
    {
        outgoingStatus = ZZVideoOutgoingStatusDownloaded;
    }
    else if ([notificationModel.status isEqualToString:NOTIFICATION_STATUS_VIEWED])
    {
        outgoingStatus = ZZVideoOutgoingStatusViewed;
    }
    else
    {
        ZZLogError(@"unknown status received in notification");
        return;
    }
    
    ZZFriendDomainModel* updatedFriendModel = [ZZFriendDataProvider friendWithMKeyValue:notificationModel.toUserMKey];

    [[ZZVideoStatusHandler sharedInstance] notifyOutgoingVideoWithStatus:outgoingStatus
                                                            withFriendID:updatedFriendModel.idTbm
                                                             withVideoID:notificationModel.videoID];
}


#pragma mark - Data Update

- (void)freshVideoDetectedWithVideoID:(NSString*)videoID friendID:(NSString*)friendID
{
    [self.videoFileHandler queueDownloadWithFriendID:friendID videoID:videoID];
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
    else if (event == ZZRootStateObserverEventResetAllLoaderTask)
    {
        [self _resetAllLoaderTasks];
    }
}


#pragma mark - Private

- (void)_resetAllLoaderTasks
{
    [self.videoFileHandler resetAllTasksCompletion:^{
        NSLog(@"stopped");
    }];
}

@end
