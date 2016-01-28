//
//  ZZNetworkTestInteractorIO.h
//  Zazo
//
//  Created by Oksana Kovalchuk on 1/12/15.
//  Copyright (c) 2015 ANODA. All rights reserved.
//

@class ZZFriendDomainModel;

@protocol ZZNetworkTestInteractorInput <NSObject>

- (void)updateWithActualFriendID:(NSString*)friendID;
- (void)startSendingVideo;
- (void)stopSendingVideo;
- (NSString*)testedFriendID;

@end


@protocol ZZNetworkTestInteractorOutput <NSObject>

- (void)videoStatusChangedWithFriend:(ZZFriendDomainModel*)friendEntity;

@end