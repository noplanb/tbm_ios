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

+ (ZZContactStatusType)switchedContactStatusTypeForFriend:(ZZFriendDomainModel*)friendModel
{
    if ([friendModel isCreator])
    {
        switch (friendModel.contactStatusValue)
        {
            case ZZContactStatusTypeEstablished:
            {
                return ZZContactStatusTypeHiddenByTarget;
            } break;
            case ZZContactStatusTypeHiddenByCreator:
            {
                return ZZContactStatusTypeHiddenByBoth;
            } break;
            case ZZContactStatusTypeHiddenByTarget:
            {
                return ZZContactStatusTypeEstablished;
            } break;
            case ZZContactStatusTypeHiddenByBoth:
            {
                return ZZContactStatusTypeHiddenByCreator;
            } break;
            default: break;
        }
    }
    else
    {
        switch (friendModel.contactStatusValue)
        {
            case ZZContactStatusTypeEstablished:
            {
                return ZZContactStatusTypeHiddenByCreator;
            } break;
            case ZZContactStatusTypeHiddenByTarget:
            {
                return ZZContactStatusTypeHiddenByBoth;
            } break;
            case ZZContactStatusTypeHiddenByCreator:
            {
                return ZZContactStatusTypeEstablished;
            } break;
            case ZZContactStatusTypeHiddenByBoth:
            {
                return ZZContactStatusTypeHiddenByTarget;
            } break;
            default: break;
        }
    }
    return ZZContactStatusTypeVoided;
}

+ (BOOL)shouldFriendBeVisible:(ZZFriendDomainModel*)friendModel
{
    BOOL visible;
    if ([friendModel isCreator])
    {
        switch (friendModel.contactStatusValue)
        {
            case ZZContactStatusTypeEstablished:
            {
                visible = NO;
            } break;
            case ZZContactStatusTypeHiddenByCreator:
            {
                visible = NO;
            } break;
                
            case ZZContactStatusTypeHiddenByTarget:
            {
                visible = YES;
            } break;
                
            case ZZContactStatusTypeHiddenByBoth:
            {
                visible = YES;
            } break;
                
            default: break;
        }
    }
    else
    {
        switch (friendModel.contactStatusValue)
        {
            case ZZContactStatusTypeEstablished:
            {
                visible = NO;
            } break;
                
            case ZZContactStatusTypeHiddenByTarget:
            {
                visible = NO;
            } break;
                
            case ZZContactStatusTypeHiddenByCreator:
            {
                visible = YES;
            } break;
            case ZZContactStatusTypeHiddenByBoth:
            {
                visible = YES;
            } break;
                
            default: break;
        }
    }
    return visible;
}

@end
