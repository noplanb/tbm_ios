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
                                                     name:kZZVideoRecorderShouldStartRecording
                                                   object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(_videoDidFinishRecording:)
                                                     name:kZZVideoRecorderDidCancelRecording
                                                   object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(_videoDidFinishRecording:)
                                                     name:kZZVideoRecorderDidFail
                                                   object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(_videoDidFinishRecording:)
                                                     name:kZZVideoRecorderDidFinishRecording
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

    TBMFriend *friend = [ZZFriendDataProvider friendEntityWithItemID:marker.friendID];
    [friend handleOutgoingVideoCreatedWithVideoId:marker.videoID];
    
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


#pragma mark - Notification Delegate

- (void)handleVideoReceivedNotification:(ZZNotificationDomainModel *)model
{
    TBMFriend *friend = [TBMFriend findWithMkey:model.fromUserMKey];
    
    if (friend == nil)
    {
        ZZLogInfo(@"handleVideoReceivedNotification: got notification for non existant friend. calling getAndPollAllFriends");
        [self.dataUpdater updateAllData];
        return;
    }
    [self.videoFileHandler queueDownloadWithFriendID:friend.idTbm videoId:model.videoID];
}

- (void)handleVideoStatusUpdateNotification:(ZZNotificationDomainModel *)model
{
    TBMFriend *friend = [TBMFriend findWithMkey:model.toUserMKey];
    
    if (friend == nil)
    {
        ZZLogInfo(@"handleVideoStatusUPdateNotification: got notification for non existant friend. calling getAndPollAllFriends");
        [self.dataUpdater updateAllData];
        return;
    }
    
    TBMOutgoingVideoStatus outgoingStatus;
    if ([model.status isEqualToString:NOTIFICATION_STATUS_DOWNLOADED])
    {
        outgoingStatus = OUTGOING_VIDEO_STATUS_DOWNLOADED;
    }
    else if ([model.status isEqualToString:NOTIFICATION_STATUS_VIEWED])
    {
        outgoingStatus = OUTGOING_VIDEO_STATUS_VIEWED;
    }
    else
    {
        ZZLogError(@"unknown status received in notification");
        return;
    }
    
    [friend setAndNotifyOutgoingVideoStatus:outgoingStatus videoId:model.videoID];
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
        [self.dataUpdater updateAllData];
    }
}

@end
