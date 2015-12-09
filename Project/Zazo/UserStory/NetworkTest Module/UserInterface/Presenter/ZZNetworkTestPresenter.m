//
//  ZZNetworkTestPresenter.m
//  Zazo
//
//  Created by Oksana Kovalchuk on 1/11/15.
//  Copyright (c) 2015 ANODA. All rights reserved.
//

#import "ZZNetworkTestPresenter.h"
#import "TBMFriend.h"
#import "ZZNetworkTestVideoStatusesController.h"

@interface ZZNetworkTestPresenter () <ZZNetworkTestVideoStatusesControllerDelegate>

@property (nonatomic, strong) ZZNetworkTestVideoStatusesController* videoStatusesConteoller;

@end

@implementation ZZNetworkTestPresenter

- (void)configurePresenterWithUserInterface:(UIViewController<ZZNetworkTestViewInterface>*)userInterface
{
    self.userInterface = userInterface;
    self.videoStatusesConteoller = [[ZZNetworkTestVideoStatusesController alloc] initWithDelegate:self];
}


#pragma makr - Output

- (void)videosatusChangedWithFriend:(TBMFriend *)friendEntity
{
    [self.videoStatusesConteoller videoStatusChangedWithFriend:friendEntity];
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


#pragma mark - VideoStatuses controller delegate

- (void)outgoingVideoChangeWithCounter:(NSInteger)counter
{
    [self.userInterface outgoingVideoChangeWithCount:counter];
}

- (void)currentStatusChangedWithStatusString:(NSString *)statusString
{
    [self.userInterface updateCurrentStatus:statusString];
}

- (void)completedVideoChangeWithCounter:(NSInteger)counter
{
    [self.userInterface completedVideoChangeWithCounter:counter];
}

- (void)failedOutgoingVideoWithCounter:(NSInteger)counter
{
    [self.userInterface failedOutgoingVideoWithCounter:counter];
}

@end
