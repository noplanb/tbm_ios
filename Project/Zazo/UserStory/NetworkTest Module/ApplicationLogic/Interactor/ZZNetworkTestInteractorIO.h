//
//  ZZNetworkTestInteractorIO.h
//  Zazo
//
//  Created by Oksana Kovalchuk on 1/12/15.
//  Copyright (c) 2015 ANODA. All rights reserved.
//

@class TBMFriend;

@protocol ZZNetworkTestInteractorInput <NSObject>

- (void)startSendingVideo;
- (void)stopSendingVideo;

@end


@protocol ZZNetworkTestInteractorOutput <NSObject>

- (void)videosatusChangedWithFriend:(TBMFriend*)friendEntity;

@end