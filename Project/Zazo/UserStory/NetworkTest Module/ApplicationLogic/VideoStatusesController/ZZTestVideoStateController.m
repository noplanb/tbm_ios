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
@property (nonatomic, strong) ZZNetworkTestStoredManger* storedManager;


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

- (void)videoStatusChangedWithFriend:(ZZFriendDomainModel*)friend
{
    if (self.isNotificationEnabled)
    {
        if (friend.lastVideoStatusEventType == ZZVideoStatusEventTypeOutgoing )
        {
            [self _handleOutgoingVideoWithFriend:friend];
        }
        else
        {
            [self _handleDownloadVideoWithFriend:friend];
        }
        
        [self _updateRetryCountWithFriend:friend];
    }
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
    NSString* testedFriendID = [self.delegate testedFriendID];
    
    [ZZFriendDataUpdater updateFriendWithID:testedFriendID setUploadRetryCount:0];
}

#pragma mark - Private

- (void)_handleOutgoingVideoWithFriend:(ZZFriendDomainModel*)friend
{
    if (friend.outgoingVideoStatusValue == ZZVideoOutgoingStatusNew)
    {
        [self.delegate currentStatusChangedWithStatusString:NSLocalizedString(@"network-test-view.current.status.uploading", nil)];
    }
    else if (friend.outgoingVideoStatusValue == ZZVideoOutgoingStatusUploading)
    {
        self.triesCounter++;
        [self.delegate updateTries:self.triesCounter];
        [self _videoStatusProgress];
    }
    else if (friend.outgoingVideoStatusValue == ZZVideoOutgoingStatusUploaded)
    {
        self.outgoingVideoCounter++;
        [self.delegate outgoingVideoChangeWithCounter:self.outgoingVideoCounter];
        [self _videoStatusFinished];
    }
    else if (friend.outgoingVideoStatusValue == ZZVideoOutgoingStatusFailedPermanently &&
             friend.lastVideoStatusEventType == ZZVideoStatusEventTypeOutgoing)
    {
        self.failedOutgoingVideoCounter++;
        [self.delegate failedOutgoingVideoWithCounter:self.failedOutgoingVideoCounter];
        [self.delegate sendVideo];
    }
}

- (void)_handleDownloadVideoWithFriend:(ZZFriendDomainModel*)friend
{
    if (friend.lastIncomingVideoStatus == ZZVideoIncomingStatusDownloading)
    {
        [self _videoStatusProgress];
        [self.delegate currentStatusChangedWithStatusString:NSLocalizedString(@"network-test-view.current.status.downloading", nil)];
    }
    else if (friend.lastIncomingVideoStatus == ZZVideoIncomingStatusDownloaded)
    {
        self.incomingVideoCounter++;
        [self.delegate incomingVideoChangeWithCounter:self.incomingVideoCounter];
        [self _updateLastDownloadedVideoToViewedStatusForFriend:friend];
        [self _videoStatusFinished];
        
        [[OBLogger instance] error:@"Video DOWNLOADED!!!"];
        
    }
    else if (friend.lastIncomingVideoStatus == ZZVideoIncomingStatusFailedPermanently)
    {
        self.failedIncomingVideoCounter++;
        [self.delegate failedIncomingVideoWithCounter:self.failedIncomingVideoCounter];
        [self.delegate sendVideo];
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
                                             selector:@selector(_updateDeleteStatus)
                                                 name:kDeleteFileNotification object:nil];
}

- (void)_updateDeleteStatus
{
    if (self.isNotificationEnabled)
    {
        ANDispatchBlockToMainQueue(^{
            [self.delegate currentStatusChangedWithStatusString:NSLocalizedString(@"network-test-view.current.status.deleging", nil)];
            self.completedVideoCounter++;
            [self.delegate completedVideoChangeWithCounter:self.completedVideoCounter];
            [self.delegate sendVideo];
        });
    }
}

- (void)_updateRetryCountWithFriend:(ZZFriendDomainModel*)friend
{
    if (friend.uploadRetryCount != self.prevRetryCount)
    {
        self.prevRetryCount = friend.uploadRetryCount;
        [self.delegate updateRetryCount:friend.uploadRetryCount];
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

- (void)_updateLastDownloadedVideoToViewedStatusForFriend:(ZZFriendDomainModel*)friend
{
        NSSortDescriptor *d = [[NSSortDescriptor alloc] initWithKey:@"videoID" ascending:YES];
        NSArray* sortedVidoes = [friend.videos sortedArrayUsingDescriptors:@[d]];
        ZZVideoDomainModel* downloadedVideo = [sortedVidoes lastObject];
    
        if (downloadedVideo.incomingStatusValue == ZZVideoIncomingStatusDownloaded)
        {
            downloadedVideo.incomingStatusValue = ZZVideoIncomingStatusViewed;
            [ZZFriendDataUpdater updateFriendWithID:friend.idTbm setLastIncomingVideoStatus:ZZVideoIncomingStatusViewed];

        }
}

@end
