//
//  ZZNetworkTestStoredManger.h
//  Zazo
//
//  Created by ANODA on 12/11/15.
//  Copyright © 2015 No Plan B. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ZZNetworkTestStoredManger : NSObject

@property (nonatomic, assign) NSInteger outgoingVideoCounter;
@property (nonatomic, assign) NSInteger completedVideoCounter;
@property (nonatomic, assign) NSInteger incomingVideoCounter;
@property (nonatomic, assign) NSInteger triesCounter;
@property (nonatomic, assign) NSInteger failedOutgoingVideoCounter;
@property (nonatomic, assign) NSInteger failedIncomingVideoCounter;
@property (nonatomic, assign) NSInteger prevRetryCount;

- (void)cleanAllCounters;
- (void)cleanRetryCounter;
- (void)cleanStatsCounters;

@end
