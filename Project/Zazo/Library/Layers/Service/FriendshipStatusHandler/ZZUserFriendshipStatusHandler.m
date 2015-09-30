//
//  ZZUserFriendshipStatusHandler.m
//  Zazo
//
//  Created by Oksana Kovalchuk on 9/14/15.
//  Copyright (c) 2015 No Plan B. All rights reserved.
//

#import "ZZUserFriendshipStatusHandler.h"
#import "ZZFriendDomainModel.h"

@implementation ZZUserFriendshipStatusHandler

+ (ZZFriendshipStatusType)switchedContactStatusTypeForFriend:(ZZFriendDomainModel*)friendModel
{
    if ([friendModel isCreator])
    {
        switch (friendModel.friendshipStatusValue)
        {
            case ZZFriendshipStatusTypeEstablished:
            {
                return ZZFriendshipStatusTypeHiddenByTarget;
            } break;
            case ZZFriendshipStatusTypeHiddenByCreator:
            {
                return ZZFriendshipStatusTypeHiddenByBoth;
            } break;
            case ZZFriendshipStatusTypeHiddenByTarget:
            {
                return ZZFriendshipStatusTypeEstablished;
            } break;
            case ZZFriendshipStatusTypeHiddenByBoth:
            {
                return ZZFriendshipStatusTypeHiddenByCreator;
            } break;
            default: break;
        }
    }
    else
    {
        switch (friendModel.friendshipStatusValue)
        {
            case ZZFriendshipStatusTypeEstablished:
            {
                return ZZFriendshipStatusTypeHiddenByCreator;
            } break;
            case ZZFriendshipStatusTypeHiddenByTarget:
            {
                return ZZFriendshipStatusTypeHiddenByBoth;
            } break;
            case ZZFriendshipStatusTypeHiddenByCreator:
            {
                return ZZFriendshipStatusTypeEstablished;
            } break;
            case ZZFriendshipStatusTypeHiddenByBoth:
            {
                return ZZFriendshipStatusTypeHiddenByTarget;
            } break;
            default: break;
        }
    }
    return ZZFriendshipStatusTypeVoided;
}

+ (BOOL)shouldFriendBeVisible:(ZZFriendDomainModel*)friendModel
{
    BOOL visible;
    if ([friendModel isCreator])
    {
        switch (friendModel.friendshipStatusValue)
        {
            case ZZFriendshipStatusTypeEstablished:
            {
                visible = YES;
            } break;
            case ZZFriendshipStatusTypeHiddenByCreator:
            {
                visible = YES;
            } break;
                
            case ZZFriendshipStatusTypeHiddenByTarget:
            {
                visible = NO;
            } break;
                
            case ZZFriendshipStatusTypeHiddenByBoth:
            {
                visible = NO;
            } break;
                
            default: break;
        }
    }
    else
    {
        switch (friendModel.friendshipStatusValue)
        {
            case ZZFriendshipStatusTypeEstablished:
            {
                visible = YES;
            } break;
                
            case ZZFriendshipStatusTypeHiddenByTarget:
            {
                visible = YES;
            } break;
                
            case ZZFriendshipStatusTypeHiddenByCreator:
            {
                visible = NO;
            } break;
            case ZZFriendshipStatusTypeHiddenByBoth:
            {
                visible = NO;
            } break;
                
            default: break;
        }
    }
    return visible;
}

@end
