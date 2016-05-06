//
//  ZZNetworkTestStoredManger.m
//  Zazo
//
//  Created by ANODA on 12/11/15.
//  Copyright © 2015 No Plan B. All rights reserved.
//

#import "ZZNetworkTestStoredManger.h"
#import "NSObject+ANUserDefaults.h"

static NSString *const kNTestOutgoingVideoCounter = @"ntestOutgoingVideoCounter";
static NSString *const kNTestCompletedVideoCounter = @"ntestcompletedVideoCounter";
static NSString *const kNTestIncomingVideoCounter = @"ntestincomingVideoCounter";
static NSString *const kNTestTriesCounter = @"ntestTriesCounter";
static NSString *const kNTestFailedOutgoingCounter = @"ntestFailedOutgoingCounter";
static NSString *const kNTestFailedIncomingCounter = @"ntestFailedIncomingCounter";
static NSString *const kNTestPrevRetryCount = @"ntestPrevRetryCounter";

@implementation ZZNetworkTestStoredManger

- (void)setOutgoingVideoCounter:(NSInteger)outgoingVideoCounter
{
    [NSObject an_updateInteger:outgoingVideoCounter forKey:kNTestOutgoingVideoCounter];
}

- (NSInteger)outgoingVideoCounter
{
    return [NSObject an_integerForKey:kNTestOutgoingVideoCounter];
}


- (void)setCompletedVideoCounter:(NSInteger)completedVideoCounter
{
    [NSObject an_updateInteger:completedVideoCounter forKey:kNTestCompletedVideoCounter];
}

- (NSInteger)completedVideoCounter
{
    return [NSObject an_integerForKey:kNTestCompletedVideoCounter];
}


- (void)setIncomingVideoCounter:(NSInteger)incomingVideoCounter
{
    [NSObject an_updateInteger:incomingVideoCounter forKey:kNTestIncomingVideoCounter];
}

- (NSInteger)incomingVideoCounter
{
    return [NSObject an_integerForKey:kNTestIncomingVideoCounter];
}


- (void)setTriesCounter:(NSInteger)triesCounter
{
    [NSObject an_updateInteger:triesCounter forKey:kNTestTriesCounter];
}

- (NSInteger)triesCounter
{
    return [NSObject an_integerForKey:kNTestTriesCounter];
}


- (void)setFailedOutgoingVideoCounter:(NSInteger)failedOutgoingVideoCounter
{
    [NSObject an_updateInteger:failedOutgoingVideoCounter forKey:kNTestFailedOutgoingCounter];
}

- (NSInteger)failedOutgoingVideoCounter
{
    return [NSObject an_integerForKey:kNTestFailedOutgoingCounter];
}


- (void)setFailedIncomingVideoCounter:(NSInteger)failedIncomingVideoCounter
{
    [NSObject an_updateInteger:failedIncomingVideoCounter forKey:kNTestFailedIncomingCounter];
}

- (NSInteger)failedIncomingVideoCounter
{
    return [NSObject an_integerForKey:kNTestFailedIncomingCounter];
}


- (void)setPrevRetryCount:(NSInteger)prevRetryCount
{
    [NSObject an_updateInteger:prevRetryCount forKey:kNTestPrevRetryCount];
}

- (NSInteger)prevRetryCount
{
    return [NSObject an_integerForKey:kNTestPrevRetryCount];
}


- (void)cleanAllCounters
{
    [self cleanStatsCounters];
    [self cleanRetryCounter];
}

- (void)cleanStatsCounters
{
    self.outgoingVideoCounter = 0;
    self.completedVideoCounter = 0;
    self.incomingVideoCounter = 0;
    self.triesCounter = 0;
    self.failedOutgoingVideoCounter = 0;
    self.failedIncomingVideoCounter = 0;
}

- (void)cleanRetryCounter
{
    self.prevRetryCount = 0;
}

@end
