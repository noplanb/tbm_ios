//
//  ZZFriendsTransport.m
//  Zazo
//
//  Created by ANODA on 8/11/15.
//  Copyright (c) 2015 ANODA. All rights reserved.
//

#import "ZZFriendsTransport.h"
#import "ZZNetworkTransport.h"

@implementation ZZFriendsTransport

+ (RACSignal*)loadFriendList
{
    return [[ZZNetworkTransport shared] requestWithPath:kApiLoadFriends httpMethod:ANHttpMethodTypeGET];
}

+ (RACSignal*)loadFriendProfileWithParameters:(NSDictionary*)parameters
{
    return [[ZZNetworkTransport shared] requestWithPath:kApiLoadFriendProfile parameters:parameters httpMethod:ANHttpMethodTypeGET];
}

+ (RACSignal*)checkIsUserHasProfileWithParameters:(NSDictionary*)parameters
{
    return [[ZZNetworkTransport shared] requestWithPath:kApiCheckIsFriendHasApp parameters:parameters httpMethod:ANHttpMethodTypeGET];
}

@end
