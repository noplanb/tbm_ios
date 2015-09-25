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

+ (RACSignal*)registerUserWithModel:(ZZUserDomainModel*)user shouldForceCall:(BOOL)shouldForceCall
{
    NSDictionary *params = [self _registrationParametersWithUser:user shouldForceCall:shouldForceCall];
    NSParameterAssert(params);
    
    return [ZZAccountTransport registerUserWithParameters:params];
}

+ (RACSignal*)verifySMSCodeWithUserModel:(ZZUserDomainModel*)user code:(NSString*)code
{
    NSMutableDictionary* params = [NSMutableDictionary dictionaryWithDictionary:[self _generateRegistrationParametersFromUserModel:user]];
    [params setObject:code forKey:ZZAccountParameters.verificationCode];
    NSParameterAssert(params);
    
    return [ZZAccountTransport verifyCodeWithParameters:params];
}


#pragma mark - Private

+ (NSDictionary*)_registrationParametersWithUser:(ZZUserDomainModel*)user shouldForceCall:(BOOL)shouldForceCall
{
    NSMutableDictionary* params = [[self _generateRegistrationParametersFromUserModel:user] mutableCopy];
    NSString* verificationType;
    if (shouldForceCall)
    {
        verificationType = ZZAccountParameters.verificationCodeTypeCall;
    }
    else
    {
        verificationType = ZZAccountParameters.verificationCodeTypeSMS;
    }
    params[ZZAccountParameters.verificationCodeTypeKey] = verificationType;
    return params;
}

+ (NSDictionary*)_generateRegistrationParametersFromUserModel:(ZZUserDomainModel*)user
{
    NSString *formattedMobileNumber = [NSString stringWithFormat:@"%%2B%@", [NSObject an_safeString:user.mobileNumber]];
    
    NSString *firstName = [NSObject an_safeString:user.firstName];
    NSString *lastName = [NSObject an_safeString:user.lastName];
    
    if ([firstName isKindOfClass:[NSString class]] && [lastName isKindOfClass:[NSString class]])
    {
        firstName = [firstName stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        lastName = [lastName stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    }

    NSDictionary* params = @{ZZAccountParameters.firstName                  : firstName,
                             ZZAccountParameters.lastName                   : lastName,
                             ZZAccountParameters.devicePlatform             : @"ios",
                             ZZAccountParameters.mobileNumber               : formattedMobileNumber};
    return params;
}

@end
