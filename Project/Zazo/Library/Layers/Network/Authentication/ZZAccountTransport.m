//
//  ZZAuthenticationTransport.m
//  Zazo
//
//  Created by ANODA on 8/11/15.
//  Copyright (c) 2015 ANODA. All rights reserved.
//

#import "ZZAccountTransport.h"
#import "ZZNetworkTransport.h"
#import "AFHTTPRequestOperationManager.h"

@implementation ZZAccountTransport

+ (RACSignal *)registerUserWithParameters:(NSDictionary *)parameters
{
    NSParameterAssert(parameters);
    return [[ZZNetworkTransport shared] requestWithPath:kApiAuthRegistration parameters:parameters httpMethod:ANHttpMethodTypeGET];
}

+ (RACSignal *)verifyCodeWithParameters:(NSDictionary *)parameters
{
    NSParameterAssert(parameters);

    NSString *username = [[NSUserDefaults standardUserDefaults] objectForKey:@"mkey"];
    NSString *password = [[NSUserDefaults standardUserDefaults] objectForKey:@"auth"];

    NSURLCredential *cred = [[NSURLCredential alloc] initWithUser:username
                                                         password:password
                                                      persistence:NSURLCredentialPersistenceForSession];
    if (!ANIsEmpty(username))
    {
        [ZZNetworkTransport shared].session.credential = cred;
    }
    return [[ZZNetworkTransport shared] requestWithPath:kApiAuthVerifyCode parameters:parameters httpMethod:ANHttpMethodTypeGET];
}

@end
