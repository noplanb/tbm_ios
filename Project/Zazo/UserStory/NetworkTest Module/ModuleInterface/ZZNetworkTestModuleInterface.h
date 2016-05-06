//
//  ZZNetworkTestModuleInterface.h
//  Zazo
//
//  Created by Oksana Kovalchuk on 1/12/15.
//  Copyright (c) 2015 ANODA. All rights reserved.
//

@protocol ZZNetworkTestModuleInterface <NSObject>

- (void)startNetworkTest;

- (void)stopNetworkTest;

- (void)resetStats;

- (void)resetRetries;

@end
