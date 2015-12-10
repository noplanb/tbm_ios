//
//  ZZTestVideoStateController.m
//  Zazo
//
//  Created by ANODA on 12/9/15.
//  Copyright © 2015 No Plan B. All rights reserved.
//

#import "ZZTestVideoStateController.h"
#import "TBMFriend.h"
#import "ZZVideoStatuses.h"

@interface ZZTestVideoStateController ()

@property (nonatomic, strong) id <ZZTestVideoStateControllerDelegate> delegate;
@property (nonatomic, assign) NSInteger outgoingVideoCounter;
@property (nonatomic, assign) NSInteger completedVideoCounter;
@property (nonatomic, assign) NSInteger incomingVideoCounter;
@property (nonatomic, assign) NSInteger triesCounter;


@property (nonatomic, assign) NSInteger failedOutgoingVideoCounter;
@property (nonatomic, assign) NSInteger failedIncomingVideoCounter;

@end

@implementation ZZTestVideoStateController

- (instancetype)initWithDelegate:(id <ZZTestVideoStateControllerDelegate>)delegate
{
    self = [super init];
    if (self)
    {
        self.delegate = delegate;
        self.outgoingVideoCounter = 0;
    }
    return self;
}

- (void)videoStatusChangedWithFriend:(TBMFriend*)friendEntity
{
    if (friendEntity.lastVideoStatusEventTypeValue == ZZVideoStatusEventTypeOutgoing )
    {
        [self _handleOutgoingVideoWithFriend:friendEntity];
    }
    else
    {
        [self _handleDownloadVideoWithFriend:friendEntity];
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
}


#pragma mark - Private

- (void)_handleOutgoingVideoWithFriend:(TBMFriend*)friend
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
//        self.completedVideoCounter++;
//        [self.delegate completedVideoChangeWithCounter:self.completedVideoCounter];
        self.outgoingVideoCounter++;
        [self.delegate outgoingVideoChangeWithCounter:self.outgoingVideoCounter];
        [self _videoStatusFinished];
    }
    else if (friend.outgoingVideoStatusValue == ZZVideoOutgoingStatusFailedPermanently &&
             friend.lastVideoStatusEventTypeValue == ZZVideoStatusEventTypeOutgoing)
    {
        self.failedOutgoingVideoCounter++;
        [self.delegate failedOutgoingVideoWithCounter:self.failedOutgoingVideoCounter];
    }
}

- (void)_handleDownloadVideoWithFriend:(TBMFriend*)friend
{
    if (friend.lastIncomingVideoStatusValue == ZZVideoIncomingStatusDownloading)
    {
        [self _videoStatusProgress];
        [self.delegate currentStatusChangedWithStatusString:NSLocalizedString(@"network-test-view.current.status.downloading", nil)];
    }
    else if (friend.lastIncomingVideoStatusValue == ZZVideoIncomingStatusDownloaded)
    {
        self.incomingVideoCounter++;
        [self.delegate incomingVideoChangeWithCounter:self.incomingVideoCounter];
        [self _videoStatusFinished];
    }
    else if (friend.lastIncomingVideoStatusValue == ZZVideoIncomingStatusFailedPermanently)
    {
        self.failedIncomingVideoCounter++;
        [self.delegate failedIncomingVideoWithCounter:self.failedIncomingVideoCounter];
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

@end
