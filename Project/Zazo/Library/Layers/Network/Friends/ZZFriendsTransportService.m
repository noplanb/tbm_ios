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
#import "ZZPhoneHelper.h"

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

static const struct
{
    __unsafe_unretained NSString *phoneNumber;
    __unsafe_unretained NSString *firstName;
    __unsafe_unretained NSString *lastName;
    
} ZZInvitationsServerParameters =
{
    .phoneNumber = @"mobile_number",
    .firstName = @"first_name",
    .lastName = @"last_name",
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

+ (RACSignal *)changeModelContactStatusForUser:(NSString *)userKey toVisible:(BOOL)visible
{
    NSParameterAssert(userKey);
    
    NSString* isVisible = visible ? @"visible" : @"hidden";
    
    NSDictionary* parameters = @{ZZFriendsServerParameters.friendMkey : [NSObject an_safeString:userKey],
                                 ZZFriendsServerParameters.visibility : isVisible};
    
    return [ZZFriendsTransport changeContactVisibilityStatusWithParameters:parameters];
}


#pragma mark - Invitations

+ (RACSignal*)checkIsUserHasProfileWithPhoneNumber:(NSString*)phoneNumber
{
    NSParameterAssert(phoneNumber);
    
    NSString *formattedNumber = [ZZPhoneHelper formatMobileNumberToE164AndServerFormat:phoneNumber];
    NSDictionary* parameters = @{ZZFriendsServerParameters.phoneNumber : [NSObject an_safeString:formattedNumber]};
    return [ZZFriendsTransport checkIsUserHasProfileWithParameters:parameters];
}

+ (RACSignal*)inviteUserWithPhoneNumber:(NSString*)phoneNumber
                              firstName:(NSString*)firstName
                            andLastName:(NSString*)lastName
{
    NSParameterAssert(phoneNumber);
    NSParameterAssert(firstName);
    NSParameterAssert(lastName);
    
    NSString* formattedNumber = [ZZPhoneHelper formatMobileNumberToE164AndServerFormat:phoneNumber];
    
    firstName = [NSObject an_safeString:firstName];
    lastName = [NSObject an_safeString:lastName];
    
    firstName = [firstName stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    lastName = [lastName stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];

    NSDictionary* parameters = @{ZZInvitationsServerParameters.phoneNumber : [NSObject an_safeString:formattedNumber],
                                 ZZInvitationsServerParameters.firstName   : firstName,
                                 ZZInvitationsServerParameters.lastName    : lastName};
    
    return [ZZFriendsTransport inviteUserWithParameters:parameters];
}


@end
