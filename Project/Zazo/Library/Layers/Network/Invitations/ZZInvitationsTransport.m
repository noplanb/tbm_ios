//
//  ZZInvitationsTransport.m
//  Zazo
//
//  Created by Oleg Panforov on 9/9/15.
//  Copyright (c) 2015 No Plan B. All rights reserved.
//

#import "ZZInvitationsTransport.h"
#import "ZZNetworkTransport.h"

@implementation ZZInvitationsTransport

+ (RACSignal*)checkIfAnInvitedUserHasAppWithParameters:(NSDictionary*)parameters
{
    return [[ZZNetworkTransport shared] requestWithPath:kApiUserHapApp
                                             parameters:parameters
                                             httpMethod:ANHttpMethodTypeGET];
}


+ (RACSignal*)inviteUserWithParameters:(NSDictionary*)parameters
{
    return [[ZZNetworkTransport shared] requestWithPath:kApiLoadFriendProfile
                                             parameters:parameters
                                             httpMethod:ANHttpMethodTypeGET];
}


@end
