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
                                             httpMethod:ANHttpMethodTypePOST];
}

+ (RACSignal*)loadS3CredentialsWithParameters:(NSDictionary*)parameters
{
    return [[ZZNetworkTransport shared] requestWithPath:kApiS3Credentials
                                             parameters:parameters
                                             httpMethod:ANHttpMethodTypeGET];
}

@end
