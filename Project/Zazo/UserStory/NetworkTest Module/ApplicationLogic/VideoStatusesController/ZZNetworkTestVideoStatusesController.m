//
//  ZZNetworkTestVideoStatusesController.m
//  Zazo
//
//  Created by ANODA on 12/9/15.
//  Copyright © 2015 No Plan B. All rights reserved.
//

#import "ZZNetworkTestVideoStatusesController.h"
#import "TBMFriend.h"
#import "ZZVideoStatuses.h"

@interface ZZNetworkTestVideoStatusesController ()

@property (nonatomic, strong) id <ZZNetworkTestVideoStatusesControllerDelegate> delegate;
@property (nonatomic, assign) NSInteger outgoingVideoCounter;
@property (nonatomic, assign) NSInteger completedVideoCounter;
@property (nonatomic, assign) NSInteger failedOutgoingVideoCounter;

@end

@implementation ZZNetworkTestVideoStatusesController

- (instancetype)initWithDelegate:(id <ZZNetworkTestVideoStatusesControllerDelegate>)delegate
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
    
}


#pragma mark - Private

- (void)_handleOutgoingVideoWithFriend:(TBMFriend*)friend
{
    if (friend.outgoingVideoStatusValue == ZZVideoOutgoingStatusNew)
    {
        self.outgoingVideoCounter++;
        [self.delegate outgoingVideoChangeWithCounter:self.outgoingVideoCounter];
        [self.delegate currentStatusChangedWithStatusString:NSLocalizedString(@"network-test-view.current.status.uploading", nil)];
    }
    else if (friend.outgoingVideoStatusValue == ZZVideoOutgoingStatusUploaded)
    {
        self.completedVideoCounter++;
        [self.delegate completedVideoChangeWithCounter:self.completedVideoCounter];
    }
    else if (friend.outgoingVideoStatusValue == ZZVideoOutgoingStatusFailedPermanently &&
             friend.lastVideoStatusEventTypeValue == ZZVideoStatusEventTypeOutgoing)
    {
        self.failedOutgoingVideoCounter++;
        [self.delegate failedOutgoingVideoWithCounter:self.failedOutgoingVideoCounter];
    }
}

@end
