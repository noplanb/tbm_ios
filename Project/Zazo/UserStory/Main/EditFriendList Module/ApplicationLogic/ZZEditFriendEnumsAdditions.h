//
//  ZZEditFriendEnumsAdditions.h
//  Zazo
//
//  Created by ANODA on 8/26/15.
//  Copyright (c) 2015 ANODA. All rights reserved.
//

typedef NS_ENUM(NSInteger, ZZContactStatusType)
{
    ZZContactStatusTypeVoided = 0,
    ZZContactStatusTypeEstablished = 1,
    ZZContactStatusTypeHiddenByCreator = 2,
    ZZContactStatusTypeHiddenByTarget = 3,
    ZZContactStatusTypeHiddenByBoth = 4
};

NSString* ZZContactStatusTypeStringFromValue(ZZContactStatusType);
ZZContactStatusType ZZContactStatusTypeValueFromSrting(NSString*);


@interface ZZEditFriendEnumsAdditions : NSObject

@end
