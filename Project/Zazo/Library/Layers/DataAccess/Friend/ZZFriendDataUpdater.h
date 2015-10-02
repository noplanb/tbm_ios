//
//  ZZFriendDataUpdater.h
//  Zazo
//
//  Created by Oksana Kovalchuk on 9/30/15.
//  Copyright © 2015 No Plan B. All rights reserved.
//

#import "ZZEditFriendEnumsAdditions.h"

@class ZZFriendDomainModel;

@interface ZZFriendDataUpdater : NSObject

+ (ZZFriendDomainModel*)updateLastTimeActionFriendWithID:(NSString*)itemID;
+ (ZZFriendDomainModel*)updateConnectionStatusForUserWithID:(NSString*)itemID toValue:(ZZFriendshipStatusType)value;

@end
