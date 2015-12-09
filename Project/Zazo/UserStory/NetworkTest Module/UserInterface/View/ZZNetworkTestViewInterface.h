//
//  ZZNetworkTestViewInterface.h
//  Zazo
//
//  Created by Oksana Kovalchuk on 1/12/15.
//  Copyright (c) 2015 ANODA. All rights reserved.
//

@protocol ZZNetworkTestViewInterface <NSObject>

- (void)outgoingVideoChangeWithCount:(NSInteger)count;
- (void)completedVideoChangeWithCounter:(NSInteger)count;

- (void)failedOutgoingVideoWithCounter:(NSInteger)count;

- (void)updateCurrentStatus:(NSString*)status;

@end
