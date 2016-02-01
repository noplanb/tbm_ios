//
//  ZZNetworkTestPresenter.m
//  Zazo
//
//  Created by Oksana Kovalchuk on 1/11/15.
//  Copyright (c) 2015 ANODA. All rights reserved.
//

#import "ZZNetworkTestPresenter.h"
#import "ZZTestVideoStateController.h"
#import "ZZNetworkTestFriendshipController.h"
#import "ZZRootStateObserver.h"
#import "ZZFriendDomainModel.h"

@interface ZZNetworkTestPresenter () <ZZTestVideoStateControllerDelegate>

@property (nonatomic, strong) ZZTestVideoStateController* videoStateController;

@end

@implementation ZZNetworkTestPresenter

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        [self _configureNotifications];
    }
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)configurePresenterWithUserInterface:(UIViewController<ZZNetworkTestViewInterface>*)userInterface
{
    self.userInterface = userInterface;
    
    self.videoStateController = [[ZZTestVideoStateController alloc] initWithDelegate:self];
    
    [ZZNetworkTestFriendshipController updateFriendShipIfNeededWithCompletion:^(NSString *actualFriendID) {
        [self.interactor updateWithActualFriendID:actualFriendID];
        [self startNetworkTest];
    }];
}

- (void)_configureNotifications
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(_saveCountersState)
                                                 name:UIApplicationWillTerminateNotification
                                               object:nil];
}


#pragma makr - Output

- (void)videosatusChangedWithFriend:(ZZFriendDomainModel *)friendModel
{
    [self.videoStateController videoStatusChangedWithFriend:friendModel];
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

- (NSString *)testedFriendID
{
    return [self.interactor testedFriendID];
}


#pragma mark - Private

- (void)_saveCountersState
{
    [self.videoStateController saveCounterState];
}

@end
