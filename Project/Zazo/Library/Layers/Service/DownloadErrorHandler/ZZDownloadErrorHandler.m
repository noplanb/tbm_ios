//
// Created by Rinat on 09/03/16.
// Copyright (c) 2016 No Plan B. All rights reserved.
//

#import "ZZDownloadErrorHandler.h"
#import "ZZFriendDataProvider.h"
#import "ZZFriendDomainModel.h"
#import "ZZVideoDataProvider.h"
#import "ZZVideoDataUpdater.h"
#import "ZZAlertController.h"
#import "ZZVideoFileHandler.h"

@interface ZZDownloadErrorHandler ()  <ZZVideoStatusHandlerDelegate>

@property(nonatomic, assign) BOOL isDialogShown;
@property(nonatomic, assign) BOOL isStarted;
@property(nonatomic, assign) BOOL isPaused;

@end

@implementation ZZDownloadErrorHandler

- (instancetype)init
{
    self = [super init];
    if (self) {
        [[ZZVideoStatusHandler sharedInstance] addVideoStatusHandlerObserver:self];
    }

    return self;
}

- (void)startService
{
    if (self.isStarted)
    {
        return;
    }

    ZZLogEvent(@"[ZZDownloadErrorHandler startService]");

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(appDidEnterForegroundNotification:)
                                                 name:UIApplicationWillEnterForegroundNotification
                                               object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(appDidEnterBackgroundNotification:)
                                                 name:UIApplicationDidEnterBackgroundNotification
                                               object:nil];


    self.isStarted = YES;

    [self _showRetryDialogIfNeeded];
}


- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [[ZZVideoStatusHandler sharedInstance] removeVideoStatusHandlerObserver:self];
}

#pragma mark Notifications

- (void)appDidEnterBackgroundNotification:(NSNotification *)notification
{
    self.isPaused = YES;
}

- (void)appDidEnterForegroundNotification:(NSNotification *)notification
{
    self.isPaused = NO;
    [self _showRetryDialogIfNeeded];
}

#pragma mark UI Dialog

- (void)_showRetryDialogIfNeeded
{
    if ([self _hasFailedVideos])
    {
        [self _showRetryDialog];
    }
}

- (void)_showRetryDialog
{
    if (self.isDialogShown || self.isPaused)
    {
        return;
    }

    self.isDialogShown = YES;

    ZZLogEvent(@"Showing retry user dialog...");

    ANDispatchBlockToMainQueue(^{
        [self _showRetryConfirmationDialog:^(BOOL needsRetry) {

        self.isDialogShown = NO;

            ZZLogEvent(@"Needs retry = %d", needsRetry);

            if (needsRetry)
            {
                [self _retryFailedVideos];
            }
            else
            {
                [self _deleteFailedVideos];
            }

        }];
    });
}

- (void)_showRetryConfirmationDialog:(void (^)(BOOL needsRetry))completion
{
    ZZAlertController *alertController =
            [ZZAlertController alertControllerWithTitle:@"Download Error"
                                                 message:@"Problem downloading a zazo.\nCheck your connection"];
    [alertController addAction:
            [SDCAlertAction actionWithTitle:@"Discard"
                                      style:SDCAlertActionStyleCancel
                                    handler:^(SDCAlertAction *action) {
                                        
                                        [Answers logCustomEventWithName:@"RetryDialogDiscard" customAttributes:nil];
                                        completion(NO);
                                    }]];

    [alertController addAction:
            [SDCAlertAction actionWithTitle:@"Try again"
                                      style:SDCAlertActionStyleDefault
                                    handler:^(SDCAlertAction *action) {
                                        
                                        [Answers logCustomEventWithName:@"RetryDialogTryAgain" customAttributes:nil];
                                        completion(YES);
                                    }]];

    [alertController presentWithCompletion:nil];
}

#pragma mark ZZVideoStatusHandlerDelegate

- (void)videoStatusChangedWithFriendID:(NSString *)friendID
{
    ZZFriendDomainModel *friendModel = [ZZFriendDataProvider friendWithItemID:friendID];

    if (friendModel.lastIncomingVideoStatus == ZZVideoIncomingStatusFailedPermanently &&
        friendModel.lastVideoStatusEventType == ZZVideoStatusEventTypeIncoming)
    {
        [self _showRetryDialog];
    }
}

#pragma mark Support

- (BOOL)_hasFailedVideos
{
    return [ZZVideoDataProvider countVideosWithStatus:ZZVideoIncomingStatusFailedPermanently] > 0;
}

- (void)_deleteFailedVideos
{
    [ZZVideoDataUpdater deleteAllFailedVideos];
}

- (void)_retryFailedVideos
{
    [self.videoFileHandler restartFailedDownloads];
}

@end
