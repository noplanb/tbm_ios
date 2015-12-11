//
//  ZZFriendDataUpdater.h
//  Zazo
//
//  Created by Oksana Kovalchuk on 9/30/15.
//  Copyright © 2015 No Plan B. All rights reserved.
//

#import "ZZEditFriendEnumsAdditions.h"
#import "ZZFriendDomainModel.h"

@interface ZZFriendDataUpdater : NSObject

+ (void)updateLastTimeActionFriendWithID:(NSString*)itemID;
+ (ZZFriendDomainModel*)updateConnectionStatusForUserWithID:(NSString*)itemID toValue:(ZZFriendshipStatusType)value;
+ (ZZFriendDomainModel*)upsertFriend:(ZZFriendDomainModel*)model;
+ (void)updateEverSentFriendsWithMkeys:(NSArray*)mKeys;
+ (void)fillEntitiesAfterMigration;


@end
