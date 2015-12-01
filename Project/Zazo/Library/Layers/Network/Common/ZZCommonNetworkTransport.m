//
//  ZZCommonNetworkTransport.m
//  Zazo
//
//  Created by ANODA on 8/11/15.
//  Copyright (c) 2015 ANODA. All rights reserved.
//

#import "ZZCommonNetworkTransport.h"
#import "ZZNetworkTransport.h"

@implementation ZZCommonNetworkTransport

+ (RACSignal*)logMessageWithParameters:(NSDictionary*)parameters
{
    return [[ZZNetworkTransport shared] requestWithPath:kApiLogMessage
                                             parameters:parameters
                                             httpMethod:ANHttpMethodTypePOST];
}

+ (RACSignal*)checkApplicationVersionWithParameters:(NSDictionary*)parameters
{
    return [[ZZNetworkTransport shared] requestWithPath:kApiCheckApplicationVersion
                                             parameters:parameters
                                             httpMethod:ANHttpMethodTypeGET];
}

+ (RACSignal*)loadS3Credentials
{
    return [[ZZNetworkTransport shared] requestWithPath:kApiS3Credentials httpMethod:ANHttpMethodTypeGET];
}

+ (void)setupNetworkCredentials
{
    [ZZNetworkTransport shared];
}

@end
