//
//  ZZNetworkTestPresenter.m
//  Zazo
//
//  Created by Oksana Kovalchuk on 1/11/15.
//  Copyright (c) 2015 ANODA. All rights reserved.
//

#import "ZZNetworkTestPresenter.h"
#import "TBMFriend.h"
#import "ZZTestVideoStateController.h"

@interface ZZNetworkTestPresenter () <ZZTestVideoStateControllerDelegate>

@property (nonatomic, strong) ZZTestVideoStateController* videoStateController;

@end

@implementation ZZNetworkTestPresenter

- (void)configurePresenterWithUserInterface:(UIViewController<ZZNetworkTestViewInterface>*)userInterface
{
    self.userInterface = userInterface;
    self.videoStateController = [[ZZTestVideoStateController alloc] initWithDelegate:self];
}


#pragma makr - Output

- (void)videosatusChangedWithFriend:(TBMFriend *)friendEntity
{
    [self.videoStateController videoStatusChangedWithFriend:friendEntity];
}


#pragma mark - Event handler

- (void)startNetworkTest
{
    [self.interactor startSendingVideo];
}

- (void)stopNetworkTest
{
    [self.interactor stopSendingVideo];
}

- (void)resetStats
{
    [self.videoStateController resetStats];
}


#pragma mark - VideoStatuses controller delegate

- (void)outgoingVideoChangeWithCounter:(NSInteger)counter
{
    [self.userInterface outgoingVideoChangeWithCount:counter];
}

- (void)currentStatusChangedWithStatusString:(NSString *)statusString
{
    [self.userInterface updateCurrentStatus:statusString];
}

- (void)incomingVideoChangeWithCounter:(NSInteger)counter
{
    [self.userInterface incomingVideoChangeWithCount:counter];
}

- (void)completedVideoChangeWithCounter:(NSInteger)counter
{
    [self.userInterface completedVideoChangeWithCounter:counter];
}

- (void)failedOutgoingVideoWithCounter:(NSInteger)counter
{
    [self.userInterface failedOutgoingVideoWithCounter:counter];
}

- (void)failedIncomingVideoWithCounter:(NSInteger)counter
{
    [self.userInterface failedIncomingVideoWithCounter:counter];
}

- (void)updateTries:(NSInteger)coutner
{
    [self.userInterface updateTriesCount:coutner];
}

- (void)videoStatusChagnedWith:(NSString *)statusString
{
    [self.userInterface updateVideoSatus:statusString];
}

@end
