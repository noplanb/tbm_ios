//
//  ZZFriendsTransport.h
//  Zazo
//
//  Created by ANODA on 8/11/15.
//  Copyright (c) 2015 ANODA. All rights reserved.
//

@interface ZZFriendsTransport : NSObject

+ (RACSignal *)loadFriendList;

+ (RACSignal *)loadFriendProfileWithParameters:(NSDictionary *)parameters;

+ (RACSignal *)changeContactVisibilityStatusWithParameters:(NSDictionary *)parameters;


#pragma mark - Invitations

+ (RACSignal *)checkIsUserHasProfileWithParameters:(NSDictionary *)parameters;

+ (RACSignal *)inviteUserWithParameters:(NSDictionary *)parameters;

+ (RACSignal *)updateUserWithParameters:(NSDictionary *)parameters;

@end
