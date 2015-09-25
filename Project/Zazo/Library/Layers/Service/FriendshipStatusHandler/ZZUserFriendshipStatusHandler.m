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

+ (ZZConnectionStatusType)switchedContactStatusTypeForFriend:(ZZFriendDomainModel*)friendModel
{
    if ([friendModel isCreator])
    {
        switch (friendModel.connectionStatusValue)
        {
            case ZZConnectionStatusTypeEstablished:
            {
                return ZZConnectionStatusTypeHiddenByTarget;
            } break;
            case ZZConnectionStatusTypeHiddenByCreator:
            {
                return ZZConnectionStatusTypeHiddenByBoth;
            } break;
            case ZZConnectionStatusTypeHiddenByTarget:
            {
                return ZZConnectionStatusTypeEstablished;
            } break;
            case ZZConnectionStatusTypeHiddenByBoth:
            {
                return ZZConnectionStatusTypeHiddenByCreator;
            } break;
            default: break;
        }
    }
    else
    {
        switch (friendModel.connectionStatusValue)
        {
            case ZZConnectionStatusTypeEstablished:
            {
                return ZZConnectionStatusTypeHiddenByCreator;
            } break;
            case ZZConnectionStatusTypeHiddenByTarget:
            {
                return ZZConnectionStatusTypeHiddenByBoth;
            } break;
            case ZZConnectionStatusTypeHiddenByCreator:
            {
                return ZZConnectionStatusTypeEstablished;
            } break;
            case ZZConnectionStatusTypeHiddenByBoth:
            {
                return ZZConnectionStatusTypeHiddenByTarget;
            } break;
            default: break;
        }
    }
    return ZZConnectionStatusTypeVoided;
}

+ (BOOL)shouldFriendBeVisible:(ZZFriendDomainModel*)friendModel
{
    BOOL visible;
    if ([friendModel isCreator])
    {
        switch (friendModel.connectionStatusValue)
        {
            case ZZConnectionStatusTypeEstablished:
            {
                visible = YES;
            } break;
            case ZZConnectionStatusTypeHiddenByCreator:
            {
                visible = YES;
            } break;
                
            case ZZConnectionStatusTypeHiddenByTarget:
            {
                visible = NO;
            } break;
                
            case ZZConnectionStatusTypeHiddenByBoth:
            {
                visible = NO;
            } break;
                
            default: break;
        }
    }
    else
    {
        switch (friendModel.connectionStatusValue)
        {
            case ZZConnectionStatusTypeEstablished:
            {
                visible = YES;
            } break;
                
            case ZZConnectionStatusTypeHiddenByTarget:
            {
                visible = YES;
            } break;
                
            case ZZConnectionStatusTypeHiddenByCreator:
            {
                visible = NO;
            } break;
            case ZZConnectionStatusTypeHiddenByBoth:
            {
                visible = NO;
            } break;
                
            default: break;
        }
    }
    return visible;
}

@end
