//
//  ZZNetworkTestVideoStatusesController.h
//  Zazo
//
//  Created by ANODA on 12/9/15.
//  Copyright © 2015 No Plan B. All rights reserved.
//

@class TBMFriend;

@protocol ZZNetworkTestVideoStatusesControllerDelegate <NSObject>

- (void)outgoingVideoChangeWithCounter:(NSInteger)counter;
- (void)completedVideoChangeWithCounter:(NSInteger)counter;

- (void)failedOutgoingVideoWithCounter:(NSInteger)counter;

- (void)currentStatusChangedWithStatusString:(NSString*)statusString;


@end

@interface ZZNetworkTestVideoStatusesController : NSObject

- (instancetype)initWithDelegate:(id <ZZNetworkTestVideoStatusesControllerDelegate>)delegate;
- (void)videoStatusChangedWithFriend:(TBMFriend*)friendEntity;

@end
