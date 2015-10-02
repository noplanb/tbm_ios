//
//  ZZEditFriendListModuleDelegate.h
//  Zazo
//
//  Created by ANODA on 1/12/15.
//  Copyright (c) 2015 ANODA. All rights reserved.
//

@class ZZFriendDomainModel;

@protocol ZZEditFriendListModuleDelegate <NSObject>

- (void)friendWasRemovedFromContacts:(ZZFriendDomainModel*)model;
- (void)friendWasUnblockedFromContacts:(ZZFriendDomainModel*)model;

@end
