//
//  ZZTestVideoStateController.m
//  Zazo
//
//  Created by ANODA on 12/9/15.
//  Copyright © 2015 No Plan B. All rights reserved.
//

#import "ZZTestVideoStateController.h"
#import "ZZVideoStatuses.h"
#import "ZZFriendDataProvider.h"
#import "ZZNetworkTestStoredManger.h"
#import "ZZVideoDataProvider.h"
#import "ZZVideoDomainModel.h"
#import "OBLogger.h"
#import "ZZFriendDataUpdater.h"
#import "ZZVideoDataUpdater.h"

@interface ZZTestVideoStateController ()

@property (nonatomic, weak) id <ZZTestVideoStateControllerDelegate> delegate;
@property (nonatomic, assign) NSInteger outgoingVideoCounter;
@property (nonatomic, assign) NSInteger completedVideoCounter;
@property (nonatomic, assign) NSInteger incomingVideoCounter;
@property (nonatomic, assign) NSInteger triesCounter;


@property (nonatomic, assign) NSInteger failedOutgoingVideoCounter;
@property (nonatomic, assign) NSInteger failedIncomingVideoCounter;
@property (nonatomic, assign) NSInteger prevRetryCount;

@property (nonatomic, assign) BOOL isNotificationEnabled;
@property (nonatomic, strong) ZZNetworkTestStoredManger *storedManager;


@end

@implementation ZZTestVideoStateController

- (instancetype)initWithDelegate:(id <ZZTestVideoStateControllerDelegate>)delegate
{
    self = [super init];
    if (self)
    {
        self.delegate = delegate;
        self.outgoingVideoCounter = 0;
        [self _setupNotifications];
        self.storedManager = [ZZNetworkTestStoredManger new];
        [self _updateStateCounterWithStorredValue];
    }
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)videoStatusChangedWithFriend:(ZZFriendDomainModel *)friendModel
{

    if (friendModel.lastVideoStatusEventType == ZZVideoStatusEventTypeOutgoing)
    {
        [self _handleOutgoingVideoWithFriend:friendModel];
    }
    else
    {
        [self _handleDownloadVideoWithFriend:friendModel];
    }

    [self _updateRetryCountWithFriend:friendModel];

}

- (void)resetStats
{
    self.outgoingVideoCounter = 0;
    self.completedVideoCounter = 0;
    self.incomingVideoCounter = 0;
    self.triesCounter = 0;
    self.failedIncomingVideoCounter = 0;
    self.failedOutgoingVideoCounter = 0;
    [self.delegate outgoingVideoChangeWithCounter:self.outgoingVideoCounter];
    [self.delegate completedVideoChangeWithCounter:self.completedVideoCounter];
    [self.delegate incomingVideoChangeWithCounter:self.incomingVideoCounter];
    [self.delegate updateTries:self.triesCounter];
    [self.delegate failedOutgoingVideoWithCounter:self.failedOutgoingVideoCounter];
    [self.delegate failedIncomingVideoWithCounter:self.failedIncomingVideoCounter];
    [self.storedManager cleanAllCounters];
}

- (void)saveCounterState
{
    self.storedManager.outgoingVideoCounter = self.outgoingVideoCounter;
    self.storedManager.completedVideoCounter = self.completedVideoCounter;
    self.storedManager.incomingVideoCounter = self.incomingVideoCounter;
    self.storedManager.triesCounter = self.triesCounter;
    self.storedManager.failedIncomingVideoCounter = self.failedIncomingVideoCounter;
    self.storedManager.failedOutgoingVideoCounter = self.failedOutgoingVideoCounter;
    self.storedManager.prevRetryCount = self.prevRetryCount;

    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)stopNotify
{
    self.isNotificationEnabled = NO;
}

- (void)startNotify
{
    self.isNotificationEnabled = YES;
}

- (void)resetRetries
{
    self.prevRetryCount = 0;
    [self.delegate updateRetryCount:self.prevRetryCount];
    NSString *testedFriendID = [self.delegate testedFriendID];

    [ZZFriendDataUpdater updateFriendWithID:testedFriendID setUploadRetryCount:0];
}

#pragma mark - Private

- (void)_handleOutgoingVideoWithFriend:(ZZFriendDomainModel *)friendModel
{
    ZZLogInfo(@"🛂 upload video %@ status = %@", friendModel.outgoingVideoItemID, ZZVideoStatusStringWithFriendModel(friendModel));

    if (friendModel.lastOutgoingVideoStatus == ZZVideoOutgoingStatusNew)
    {
        [self.delegate currentStatusChangedWithStatusString:NSLocalizedString(@"network-test-view.current.status.uploading", nil)];
    }
    else if (friendModel.lastOutgoingVideoStatus == ZZVideoOutgoingStatusUploading)
    {
        self.triesCounter++;
        [self.delegate updateTries:self.triesCounter];
        [self _videoStatusProgress];
    }
    else if (friendModel.lastOutgoingVideoStatus == ZZVideoOutgoingStatusUploaded)
    {
        self.outgoingVideoCounter++;
        [self.delegate outgoingVideoChangeWithCounter:self.outgoingVideoCounter];
        [self _videoStatusFinished];
    }
    else if (friendModel.lastOutgoingVideoStatus == ZZVideoOutgoingStatusFailedPermanently &&
            friendModel.lastVideoStatusEventType == ZZVideoStatusEventTypeOutgoing)
    {
        self.failedOutgoingVideoCounter++;
        [self.delegate failedOutgoingVideoWithCounter:self.failedOutgoingVideoCounter];

        if (self.isNotificationEnabled)
        {
            [self.delegate didCompleteSendVideo:nil];
        }
    }
}

- (void)_handleDownloadVideoWithFriend:(ZZFriendDomainModel *)friendModel
{
    ZZVideoDomainModel *videoModel = [ZZVideoDataProvider sortedIncomingVideosForUserWithID:friendModel.idTbm].lastObject;
    ZZLogInfo(@"🛂 download video %@ status %@", videoModel.videoID, ZZVideoStatusStringWithFriendModel(friendModel));

    if (friendModel.lastIncomingVideoStatus == ZZVideoIncomingStatusDownloading)
    {
        [self _videoStatusProgress];
        [self.delegate currentStatusChangedWithStatusString:NSLocalizedString(@"network-test-view.current.status.downloading", nil)];
    }
    else if (friendModel.lastIncomingVideoStatus == ZZVideoIncomingStatusDownloaded)
    {
        self.incomingVideoCounter++;
        [self.delegate incomingVideoChangeWithCounter:self.incomingVideoCounter];
        [self _updateDownloadedVideosToViewedStatusForFriend:friendModel];
        [self _videoStatusFinished];

//        [[OBLogger instance] error:@"Video DOWNLOADED!!!"];

    }
    else if (friendModel.lastIncomingVideoStatus == ZZVideoIncomingStatusFailedPermanently)
    {
        self.failedIncomingVideoCounter++;
        [self.delegate failedIncomingVideoWithCounter:self.failedIncomingVideoCounter];

        if (self.isNotificationEnabled)
        {
            [self.delegate didCompleteSendVideo:videoModel.videoID];
        }
    }
}

- (void)_videoStatusProgress
{
    [self.delegate videoStatusChagnedWith:NSLocalizedString(@"network-test-view.videostatus.progress", nil)];
}

- (void)_videoStatusFinished
{
    [self.delegate videoStatusChagnedWith:NSLocalizedString(@"network-test-view.videostatus.finished", nil)];
}

- (void)_setupNotifications
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(_updateDeleteStatusNotification:)
                                                 name:kDeleteFileNotification object:nil];
}

- (void)_updateDeleteStatusNotification:(NSNotification *)notification
{
    ZZLogInfo(@"🛂 video deleted %@", notification.userInfo[@"videoID"]);

    ANDispatchBlockToMainQueue(^{
        [self.delegate currentStatusChangedWithStatusString:NSLocalizedString(@"network-test-view.current.status.deleging", nil)];
        self.completedVideoCounter++;
        [self.delegate completedVideoChangeWithCounter:self.completedVideoCounter];

        if (self.isNotificationEnabled)
        {
            [self.delegate didCompleteSendVideo:notification.userInfo[@"videoID"]];
        }
    });

}

- (void)_updateRetryCountWithFriend:(ZZFriendDomainModel *)friendModel
{
    if (friendModel.uploadRetryCount != self.prevRetryCount)
    {
        self.prevRetryCount = friendModel.uploadRetryCount;
        [self.delegate updateRetryCount:friendModel.uploadRetryCount];
    }
}

- (void)_updateStateCounterWithStorredValue
{
    self.outgoingVideoCounter = self.storedManager.outgoingVideoCounter;
    self.completedVideoCounter = self.storedManager.completedVideoCounter;
    self.incomingVideoCounter = self.storedManager.incomingVideoCounter;
    self.triesCounter = self.storedManager.triesCounter;
    self.failedIncomingVideoCounter = self.storedManager.failedIncomingVideoCounter;
    self.failedOutgoingVideoCounter = self.storedManager.failedOutgoingVideoCounter;
    self.prevRetryCount = self.storedManager.prevRetryCount;

    [self.delegate outgoingVideoChangeWithCounter:self.outgoingVideoCounter];
    [self.delegate completedVideoChangeWithCounter:self.completedVideoCounter];
    [self.delegate incomingVideoChangeWithCounter:self.incomingVideoCounter];
    [self.delegate updateTries:self.triesCounter];
    [self.delegate failedIncomingVideoWithCounter:self.failedIncomingVideoCounter];
    [self.delegate failedOutgoingVideoWithCounter:self.failedOutgoingVideoCounter];
    [self.delegate updateRetryCount:self.prevRetryCount];
}

- (void)_updateDownloadedVideosToViewedStatusForFriend:(ZZFriendDomainModel *)friendModel
{
    NSSortDescriptor *d = [[NSSortDescriptor alloc] initWithKey:@"videoID" ascending:YES];
    NSArray *sortedVidoes = [friendModel.videos sortedArrayUsingDescriptors:@[d]];


    [sortedVidoes enumerateObjectsUsingBlock:^(id _Nonnull obj, NSUInteger idx, BOOL *_Nonnull stop) {

        ZZVideoDomainModel *downloadedVideo = obj;

        if (downloadedVideo.incomingStatusValue == ZZVideoIncomingStatusDownloaded)
        {
            downloadedVideo.incomingStatusValue = ZZVideoIncomingStatusViewed;

            //TODO: Maybe it should be in one method:
            [ZZVideoDataUpdater updateVideoWithID:downloadedVideo.videoID setIncomingStatus:ZZVideoIncomingStatusViewed];
            [ZZFriendDataUpdater updateFriendWithID:friendModel.idTbm setLastIncomingVideoStatus:ZZVideoIncomingStatusViewed];

        }
    }];

}

@end
