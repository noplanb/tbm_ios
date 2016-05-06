//
//  ZZEditFriendEnumsAdditions.h
//  Zazo
//
//  Created by ANODA on 8/26/15.
//  Copyright (c) 2015 ANODA. All rights reserved.
//

typedef NS_ENUM(NSInteger, ZZFriendshipStatusType)
{
    ZZFriendshipStatusTypeVoided = 0,
    ZZFriendshipStatusTypeEstablished = 1,
    ZZFriendshipStatusTypeHiddenByCreator = 2,
    ZZFriendshipStatusTypeHiddenByTarget = 3,
    ZZFriendshipStatusTypeHiddenByBoth = 4
};

NSString *ZZFriendshipStatusTypeStringFromValue(ZZFriendshipStatusType);

ZZFriendshipStatusType ZZFriendshipStatusTypeValueFromSrting(NSString *);


@interface ZZEditFriendEnumsAdditions : NSObject

@end
