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
#import "ZZNetworkTestFriendshipController.h"
#import "ZZRootStateObserver.h"

@interface ZZNetworkTestPresenter () <ZZTestVideoStateControllerDelegate>

@property (nonatomic, strong) ZZTestVideoStateController* videoStateController;

@end

@implementation ZZNetworkTestPresenter

- (void)configurePresenterWithUserInterface:(UIViewController<ZZNetworkTestViewInterface>*)userInterface
{
    self.userInterface = userInterface;
    
    self.videoStateController = [[ZZTestVideoStateController alloc] initWithDelegate:self];
    
    [ZZNetworkTestFriendshipController updateFriendShipIfNeededWithCompletion:^(NSString *actualFriendID) {
        [self.interactor updateWithActualFriendID:actualFriendID];
    }];
}


#pragma makr - Output

- (void)videosatusChangedWithFriend:(TBMFriend *)friendEntity
{
    [self.videoStateController videoStatusChangedWithFriend:friendEntity];
}


#pragma mark - Event handler

- (void)startNetworkTest
{
    [self.videoStateController startNotify];
    [self.interactor startSendingVideo];
}

- (void)stopNetworkTest
{
    [self.videoStateController stopNotify];
    [[ZZRootStateObserver sharedInstance] notifyWithEvent:ZZRootStateObserverEventResetAllLoaderTask notificationObject:nil];
    [self.interactor stopSendingVideo];
}

- (void)resetStats
{
    [self.videoStateController resetStats];
}

- (void)resetRetries
{
    [self.videoStateController resetRetries];
    
}

#pragma mark - VideoStatuses controller delegate

- (void)sendVideo
{
    [self.interactor startSendingVideo];
}

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

- (void)updateRetryCount:(NSInteger)count
{
    [self.userInterface updateRetryCount:count];
}

@end
