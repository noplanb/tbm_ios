//
//  ZZEditFriendListInteractorIO.h
//  Zazo
//
//  Created by ANODA on 1/12/15.
//  Copyright (c) 2015 ANODA. All rights reserved.
//

@class ZZFriendDomainModel;

@protocol ZZEditFriendListInteractorInput <NSObject>

- (void)loadData;

- (void)changeContactStatusTypeForFriend:(ZZFriendDomainModel *)friendModel;

@end

@protocol ZZEditFriendListInteractorOutput <NSObject>

- (void)dataLoaded:(NSArray *)friends;

- (void)contactSuccessfullyUpdated:(ZZFriendDomainModel *)model toVisibleState:(BOOL)isVisible;

- (void)updatedWithError:(NSError *)error friend:(ZZFriendDomainModel *)model;

@end