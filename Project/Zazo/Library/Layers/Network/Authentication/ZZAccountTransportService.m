//
//  ZZAccountTransportService.m
//  Zazo
//
//  Created by ANODA on 8/11/15.
//  Copyright (c) 2015 ANODA. All rights reserved.
//

#import "ZZAccountTransportService.h"
#import "ZZAccountTransport.h"
#import "ZZUserDomainModel.h"
#import "NSObject+ANSafeValues.h"
#import "AFNetworking.h"
#import "ZZAPIRoutes.h"

static const struct {
    __unsafe_unretained NSString *firstName;
    __unsafe_unretained NSString *lastName;
    __unsafe_unretained NSString *mobileNumber;
    __unsafe_unretained NSString *devicePlatform;
    __unsafe_unretained NSString *verificationCode;
    __unsafe_unretained NSString *verificationCodeTypeKey;
    __unsafe_unretained NSString *verificationCodeTypeSMS;
    __unsafe_unretained NSString *verificationCodeTypeCall;
} ZZAccountParameters = {
    .firstName = @"first_name",
    .lastName = @"last_name",
    .mobileNumber = @"mobile_number",
    .devicePlatform = @"device_platform",
    .verificationCode = @"verification_code",
    .verificationCodeTypeKey = @"via",
    .verificationCodeTypeSMS = @"sms",
    .verificationCodeTypeCall = @"call",
};

@implementation ZZAccountTransportService

+ (RACSignal*)registerUserWithModel:(ZZUserDomainModel *)user
{
    NSDictionary *params = [self _generateRegistrationParametersFromUserModel:user];
    NSParameterAssert(params);
    
    return [ZZAccountTransport registerUserWithParameters:params];
}

+ (RACSignal*)registerUserFromModel:(ZZUserDomainModel *)user withVerificationCode:(NSString *)code
{
    NSMutableDictionary* params = [NSMutableDictionary dictionaryWithDictionary:[self _generateRegistrationParametersFromUserModel:user]];
    [params setObject:code forKey:ZZAccountParameters.verificationCode];
    [params removeObjectForKey:ZZAccountParameters.verificationCodeTypeKey];
    NSParameterAssert(params);
    
    return [ZZAccountTransport verifyCodeWithParameters:params];
}

#pragma mark - Private

+ (NSDictionary*)_generateRegistrationParametersFromUserModel:(ZZUserDomainModel *)user
{
    NSString *formattedMobileNumber = [NSString stringWithFormat:@"%%2B%@", [NSObject an_safeString:user.mobileNumber]];
    
    return @{ZZAccountParameters.firstName                  : [NSObject an_safeString:user.firstName],
             ZZAccountParameters.lastName                   : [NSObject an_safeString:user.lastName],
             ZZAccountParameters.verificationCodeTypeKey    : ZZAccountParameters.verificationCodeTypeSMS,
             ZZAccountParameters.devicePlatform             : @"ios",
             ZZAccountParameters.mobileNumber               : formattedMobileNumber};
}

@end
