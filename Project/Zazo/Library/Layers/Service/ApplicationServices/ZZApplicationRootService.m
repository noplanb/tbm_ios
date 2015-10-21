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

@interface ZZApplicationRootService () <ZZVideoFileHandlerDelegate, ZZApplicationDataUpdaterServiceDelegate>

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
    
    TBMFriend *friend = [TBMVideoIdUtils friendWithOutgoingVideoUrl:videoUrl];
    NSString *videoId = [TBMVideoIdUtils videoIdWithOutgoingVideoUrl:videoUrl];
    
    [friend handleOutgoingVideoCreatedWithVideoId:videoId];
    
    [self.videoFileHandler uploadWithVideoUrl:videoUrl friendCKey:friend.ckey];
}

- (void)checkApplicationPermissionsAndResources
{
    OB_INFO(@"performDidBecomeActiveActions: registered: %d", [ZZUserDataProvider authenticatedUser].isRegistered);
    
    if ([ZZUserDataProvider authenticatedUser].isRegistered)
    {
        [[ZZApplicationPermissionsHandler checkApplicationPermissions] subscribeNext:^(id x) {
            
            [self.notificationDelegate registerToPushNotifications]; //TODO: we will send serveral times token on a server.
            [TBMVideo printAll];
            [self.videoFileHandler startService];
        }];
    }
}


- (void)handleBackgroundSessionWithIdentifier:(NSString *)identifier completionHandler:(ANCodeBlock)completionHandler
{
    
}

#pragma mark - File Handler Delegate

- (void)requestBackground
{
    OB_INFO(@"AppDelegate: requestBackground: called:");
    if (self.backgroundTaskID == UIBackgroundTaskInvalid ) {
        OB_INFO(@"AppDelegate: requestBackground: requesting background.");
        self.backgroundTaskID = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^{
            OB_INFO(@"AppDelegate: Ending background");
            // The apple docs say you must terminate the background task you requested when they call the expiration handler
            // or before or they will terminate your app. I have found however that if I dont terminate and if
            // the usage of the phone is low by other apps they will let us run in the background indefinitely
            // even after the backgroundTimeRemaining has long gone to 0. This is good for our users as it allows us
            // to continue retries in the background for a long time in the case of poor coverage.
            
            // Actually on iphone4s 7.0 I encountered this:
            // Feb 18 20:34:28 Sanis-iPhone backboardd[28] <Warning>: Zazo[272] has active assertions beyond permitted time:
            //            {(
            //              <BKProcessAssertion: 0x15ebf2a0> identifier: Called by Zazo, from -[TBMAppDelegate requestBackground] process: Zazo[272] permittedBackgroundDuration: 40.000000 reason: finishTaskAfterBackgroundContentFetching owner pid:272 preventSuspend  preventIdleSleep  preventSuspendOnSleep
            //              )}
            //            Feb 18 20:34:28 Sanis-iPhone backboardd[28] <Warning>: Forcing crash report of Zazo[272]...
            
            
            // So as of 2/19/2005 I have uncommented the line below.
            [[UIApplication sharedApplication] endBackgroundTask:self.backgroundTaskID];
            [ZZContentDataAcessor saveDataBase];
            self.backgroundTaskID = UIBackgroundTaskInvalid;
        }];
    }
    OB_INFO(@"AppDelegate: RequestBackground: exiting: refresh status = %ld, time Remaining = %f",
            (long)[UIApplication sharedApplication].backgroundRefreshStatus,
            [UIApplication sharedApplication].backgroundTimeRemaining);
}

- (void)videoReceivedFromFriendWithItemID:(NSString*)friendItemID videoID:(NSString*)videoID
{
    //TODO: ?
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
//    TODO: map notification to notification mode, and pass to rootservice as delegate to handle and trigger proccesses
        TBMFriend *friend = [TBMFriend findWithMkey:model.fromUserMKey];
    
        if (friend == nil)
        {
            OB_INFO(@"handleVideoReceivedNotification: got notification for non existant friend. calling getAndPollAllFriends");
            [self.dataUpdater updateAllData];
            return;
        }
        [self.videoFileHandler queueDownloadWithFriendID:friend.idTbm videoId:model.videoID];
}

- (void)handleVideoStatusUpdateNotification:(ZZNotificationDomainModel *)model
{
//    TODO: the same as for video received notification
        TBMFriend *friend = [TBMFriend findWithMkey:model.toUserMKey];
    
        if (friend == nil)
        {
            OB_INFO(@"handleVideoStatusUPdateNotification: got notification for non existant friend. calling getAndPollAllFriends");
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
            OB_ERROR(@"unknown status received in notification");
            return;
        }
        
        [friend setAndNotifyOutgoingVideoStatus:outgoingStatus videoId:model.videoID];
}


#pragma mark - Data Update

- (void)freshVideoDetectedWithVideoID:(NSString*)videoID friendID:(NSString*)friendID
{
    [self.videoFileHandler queueDownloadWithFriendID:friendID videoId:videoID];
}

@end
