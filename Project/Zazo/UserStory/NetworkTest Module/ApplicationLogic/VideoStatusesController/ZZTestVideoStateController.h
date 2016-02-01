//
//  ZZTestVideoStateController.h
//  Zazo
//
//  Created by ANODA on 12/9/15.
//  Copyright © 2015 No Plan B. All rights reserved.
//

@class ZZFriendDomainModel;

@protocol ZZTestVideoStateControllerDelegate <NSObject>

- (void)sendVideo;

- (void)outgoingVideoChangeWithCounter:(NSInteger)counter;
- (void)incomingVideoChangeWithCounter:(NSInteger)counter;
- (void)completedVideoChangeWithCounter:(NSInteger)counter;
- (void)updateTries:(NSInteger)coutner;
- (void)updateRetryCount:(NSInteger)count;

- (void)failedOutgoingVideoWithCounter:(NSInteger)counter;
- (void)failedIncomingVideoWithCounter:(NSInteger)counter;

- (void)currentStatusChangedWithStatusString:(NSString*)statusString;
- (void)videoStatusChagnedWith:(NSString*)statusString;
- (NSString*)testedFriendID;

@end

@interface ZZTestVideoStateController : NSObject

- (instancetype)initWithDelegate:(id <ZZTestVideoStateControllerDelegate>)delegate;
- (void)videoStatusChangedWithFriend:(ZZFriendDomainModel*)friendModel;
- (void)resetStats;
- (void)resetRetries;

- (void)stopNotify;
- (void)startNotify;

- (void)saveCounterState;

@end
