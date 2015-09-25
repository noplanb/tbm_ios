//
//  ZZEditFriendEnumsAdditions.h
//  Zazo
//
//  Created by ANODA on 8/26/15.
//  Copyright (c) 2015 ANODA. All rights reserved.
//

typedef NS_ENUM(NSInteger, ZZConnectionStatusType)
{
    ZZConnectionStatusTypeVoided = 0,
    ZZConnectionStatusTypeEstablished = 1,
    ZZConnectionStatusTypeHiddenByCreator = 2,
    ZZConnectionStatusTypeHiddenByTarget = 3,
    ZZConnectionStatusTypeHiddenByBoth = 4
};

NSString* ZZConnectionStatusTypeStringFromValue(ZZConnectionStatusType);
ZZConnectionStatusType ZZConnectionStatusTypeValueFromSrting(NSString*);


@interface ZZEditFriendEnumsAdditions : NSObject

@end
