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

@interface ZZNetworkTestInteractor ()

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
    }
    return self;
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

@end
