//
//  ZZFriendsTransportService.m
//  Zazo
//
//  Created by ANODA on 8/11/15.
//  Copyright (c) 2015 ANODA. All rights reserved.
//

#import "ZZFriendsTransportService.h"
#import "ZZFriendsTransport.h"
#import "NSObject+ANSafeValues.h"
#import "ZZEditFriendEnumsAdditions.h"

static const struct
{
    __unsafe_unretained NSString *phoneNumber;
    __unsafe_unretained NSString *firstName;
    __unsafe_unretained NSString *lastName;
    __unsafe_unretained NSString *mKey;
    __unsafe_unretained NSString *cKey;
    __unsafe_unretained NSString *itemID;
    __unsafe_unretained NSString *isUserHasApp;
    __unsafe_unretained NSString *friendMkey;
    __unsafe_unretained NSString *visibility;
} ZZFriendsServerParameters =
{
    .phoneNumber = @"mobile_number",
    .firstName = @"first_name",
    .lastName = @"last_name",
    .mKey = @"mkey",
    .cKey = @"ckey",
    .itemID = @"id",
    .isUserHasApp = @"has_app",
    .friendMkey = @"friend_mkey",
    .visibility = @"visibility",
};

@implementation ZZFriendsTransportService

+ (RACSignal*)loadFriendList
{
    return [ZZFriendsTransport loadFriendList];
}

+ (RACSignal*)loadFriendProfileWithPhone:(NSString*)phone firstName:(NSString*)firstName lastName:(NSString*)lastName
{
    NSParameterAssert(phone);
    NSParameterAssert(firstName);
    NSParameterAssert(lastName);
    
    NSDictionary* parameters = @{ZZFriendsServerParameters.phoneNumber : [NSObject an_safeString:phone],
                                 ZZFriendsServerParameters.firstName   : [NSObject an_safeString:firstName],
                                 ZZFriendsServerParameters.lastName    : [NSObject an_safeString:lastName]};
    
    return [ZZFriendsTransport loadFriendProfileWithParameters:parameters];
}

+ (RACSignal*)checkIsUserHasProfileWithPhoneNumber:(NSString*)phoneNumber
{
    NSParameterAssert(phoneNumber);
    NSDictionary* parameters = @{ZZFriendsServerParameters.phoneNumber : [NSObject an_safeString:phoneNumber]};
    return [ZZFriendsTransport checkIsUserHasProfileWithParameters:parameters];
}

+ (RACSignal *)changeModelContactStatusForUser:(NSString *)userKey toVisible:(BOOL)visible
{
    NSParameterAssert(userKey);
    
    NSString* isVisible = visible ? @"visible" : @"hidden";
    
    NSDictionary* parameters = @{ZZFriendsServerParameters.friendMkey : [NSObject an_safeString:userKey],
                                 ZZFriendsServerParameters.visibility : isVisible};
    
    return [ZZFriendsTransport changeContactVisibilityStatusWithParameters:parameters];
}

@end
