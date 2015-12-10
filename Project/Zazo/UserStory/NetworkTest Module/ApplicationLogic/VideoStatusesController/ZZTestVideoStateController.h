//
//  ZZTestVideoStateController.h
//  Zazo
//
//  Created by ANODA on 12/9/15.
//  Copyright © 2015 No Plan B. All rights reserved.
//

@class TBMFriend;

@protocol ZZTestVideoStateControllerDelegate <NSObject>

- (void)outgoingVideoChangeWithCounter:(NSInteger)counter;
- (void)incomingVideoChangeWithCounter:(NSInteger)counter;
- (void)completedVideoChangeWithCounter:(NSInteger)counter;
- (void)updateTries:(NSInteger)coutner;

- (void)failedOutgoingVideoWithCounter:(NSInteger)counter;
- (void)failedIncomingVideoWithCounter:(NSInteger)counter;

- (void)currentStatusChangedWithStatusString:(NSString*)statusString;
- (void)videoStatusChagnedWith:(NSString*)statusString;

@end

@interface ZZTestVideoStateController : NSObject

- (instancetype)initWithDelegate:(id <ZZTestVideoStateControllerDelegate>)delegate;
- (void)videoStatusChangedWithFriend:(TBMFriend*)friendEntity;
- (void)resetStats;

@end
