//
//  ZZUserFriendshipStatusHandler.h
//  Zazo
//
//  Created by Oksana Kovalchuk on 9/14/15.
//  Copyright (c) 2015 No Plan B. All rights reserved.
//

#import "ZZEditFriendEnumsAdditions.h"

@class ZZFriendDomainModel;

@interface ZZUserFriendshipStatusHandler : NSObject

+ (ZZFriendshipStatusType)switchedContactStatusTypeForFriend:(ZZFriendDomainModel *)friendModel;

+ (BOOL)shouldFriendBeVisible:(ZZFriendDomainModel *)friendModel;

@end
