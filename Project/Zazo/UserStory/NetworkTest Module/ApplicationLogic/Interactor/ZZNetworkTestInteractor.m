//
//  ZZNetworkTestInteractor.m
//  Zazo
//
//  Created by Oksana Kovalchuk on 1/11/15.
//  Copyright (c) 2015 ANODA. All rights reserved.
//

#import "ZZNetworkTestInteractor.h"
#import "ZZSendVideoService.h"
#import "ZZVideoStatusHandler.h"
#import "ZZFriendDataProvider.h"
#import "ZZVideoDataProvider.h"

@interface ZZNetworkTestInteractor () <ZZVideoStatusHandlerDelegate>

@property (nonatomic, strong) ZZSendVideoService* sendVideoService;

@end


@implementation ZZNetworkTestInteractor

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        self.sendVideoService = [ZZSendVideoService new];
        [[ZZVideoStatusHandler sharedInstance] addVideoStatusHandlerObserver:self];
    }
    return self;
}

- (void)dealloc
{
    [[ZZVideoStatusHandler sharedInstance] removeVideoStatusHandlerObserver:self];
}

- (void)updateWithActualFriendID:(NSString *)friendID
{
    [self.sendVideoService configureActionFriendID:friendID];
}

- (NSString *)testedFriendID
{
    return [self.sendVideoService sendedFriendID];
}

#pragma mark - Send Video

- (void)startSendingVideo
{
    [self.sendVideoService sendVideo];
}

- (void)stopSendingVideo
{
    
}


#pragma mark - Video status handler delegate method

- (void)videoStatusChangedWithFriendID:(NSString*)friendID
{
    TBMFriend* friend = [ZZFriendDataProvider friendEntityWithItemID:friendID];
    [self.output videosatusChangedWithFriend:friend];
}

@end
