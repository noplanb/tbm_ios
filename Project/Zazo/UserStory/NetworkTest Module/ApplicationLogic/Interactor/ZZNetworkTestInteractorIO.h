//
//  ZZNetworkTestInteractorIO.h
//  Zazo
//
//  Created by Oksana Kovalchuk on 1/12/15.
//  Copyright (c) 2015 ANODA. All rights reserved.
//

@protocol ZZNetworkTestInteractorInput <NSObject>

- (void)updateCredentials:(ANCodeBlock)completion;
- (void)startSendingVideo;
- (void)stopSendingVideo;

@end


@protocol ZZNetworkTestInteractorOutput <NSObject>


@end