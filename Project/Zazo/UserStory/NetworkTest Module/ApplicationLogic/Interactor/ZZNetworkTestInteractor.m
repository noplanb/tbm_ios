//
//  ZZNetworkTestInteractor.m
//  Zazo
//
//  Created by Oksana Kovalchuk on 1/11/15.
//  Copyright (c) 2015 ANODA. All rights reserved.
//

#import "ZZNetworkTestInteractor.h"
#import "ZZUpdateCredentialsManager.h"
#import "ZZSendVideoManager.h"
#import "ZZVideoStatusHandler.h"
#import "ZZFriendDataProvider.h"
#import "ZZVideoDataProvider.h"

@interface ZZNetworkTestInteractor () <ZZVideoStatusHandlerDelegate>

@property (nonatomic, strong) ZZUpdateCredentialsManager* updateCredentialsManager;
@property (nonatomic, strong) ZZSendVideoManager* sendVideoManger;

@end


@implementation ZZNetworkTestInteractor

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        self.updateCredentialsManager = [ZZUpdateCredentialsManager new];
        self.sendVideoManger = [ZZSendVideoManager new];
        [[ZZVideoStatusHandler sharedInstance] addVideoStatusHandlerObserver:self];
    }
    return self;
}

- (void)dealloc
{
    [[ZZVideoStatusHandler sharedInstance] removeVideoStatusHandlerObserver:self];
}

#pragma mark - Updte credentials part

- (void)updateCredentials:(ANCodeBlock)completion
{
    [self.updateCredentialsManager updateCredentialsWithCompletion:completion];
}


#pragma mark - Send test video

- (void)startSendingVideo
{
    [self.sendVideoManger start];
}

- (void)stopSendingVideo
{
    [self.sendVideoManger stop];
}


#pragma mark - Video status handler delegate method

- (void)videoStatusChangedWithFriendID:(NSString*)friendID
{
    TBMFriend* friend = [ZZFriendDataProvider friendEntityWithItemID:friendID];
    [self.output videosatusChangedWithFriend:friend];
}

@end
