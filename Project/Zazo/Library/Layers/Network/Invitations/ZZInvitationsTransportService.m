//
//  ZZInvitationsTransportService.m
//  Zazo
//
//  Created by ANODA on 9/9/15.
//  Copyright (c) 2015 No Plan B. All rights reserved.
//

#import "ZZInvitationsTransportService.h"
#import "ZZInvitationsTransport.h"
#import "TBMPhoneUtils.h"
#import "ZZPhoneHelper.h"

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

@implementation ZZInvitationsTransportService

+ (RACSignal*)checkIfAnInvitedUserHasApp:(NSString*)phoneNumber
{
    NSParameterAssert(phoneNumber);
    
    NSString *formattedNumber = [ZZPhoneHelper formatMobileNumberToE164AndServerFormat:phoneNumber];
    
    NSDictionary* parameters = @{ZZInvitationsServerParameters.phoneNumber : [NSObject an_safeString:formattedNumber]};
    
    return [ZZInvitationsTransport checkIfAnInvitedUserHasAppWithParameters:parameters];
}

+ (RACSignal*)inviteUserWithPhoneNumber:(NSString*)phoneNumber
                              firstName:(NSString*)firstName
                            andLastName:(NSString*)lastName
{
    NSParameterAssert(phoneNumber);
    NSParameterAssert(firstName);
    NSParameterAssert(lastName);
    
    NSString *formattedNumber = [ZZPhoneHelper formatMobileNumberToE164AndServerFormat:phoneNumber];
    
    NSDictionary* parameters = @{ZZInvitationsServerParameters.phoneNumber : [NSObject an_safeString:formattedNumber],
                                 ZZInvitationsServerParameters.firstName   : [NSObject an_safeString:firstName],
                                 ZZInvitationsServerParameters.lastName    : [NSObject an_safeString:lastName]};
    
    return [ZZInvitationsTransport inviteUserWithParameters:parameters];
}


@end
