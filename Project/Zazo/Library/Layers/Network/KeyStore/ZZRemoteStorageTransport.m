//
//  ZZKeyStoreTransport.m
//  Zazo
//
//  Created by Oksana Kovalchuk on 9/2/15.
//  Copyright (c) 2015 No Plan B. All rights reserved.
//

#import "ZZRemoteStorageTransport.h"
#import "ZZNetworkTransport.h"

@implementation ZZRemoteStorageTransport

+ (RACSignal*)updateKeyValueWithParameters:(NSDictionary*)parameters
{
    return [[ZZNetworkTransport shared] requestWithPath:kApiKeyUpdate
                                             parameters:parameters
                                             httpMethod:ANHttpMethodTypePOST];
}

+ (RACSignal*)deleteKeyValueWithParameters:(NSDictionary*)parameters
{
    return [[ZZNetworkTransport shared] requestWithPath:kApiKeyDelete
                                             parameters:parameters
                                             httpMethod:ANHttpMethodTypeGET];
}

+ (RACSignal*)loadKeyValueWithParameters:(NSDictionary*)parameters
{
    return [[ZZNetworkTransport shared] requestWithPath:kApiKeyLoad
                                             parameters:parameters
                                             httpMethod:ANHttpMethodTypeGET];
}

+ (RACSignal*)loadAllIncomingVideoIDs
{
    return [[ZZNetworkTransport shared] requestWithPath:kApiGetAllIncomingVideoIDs
                                             httpMethod:ANHttpMethodTypeGET];
}

+ (RACSignal*)loadAllOutgoingVideoStatuses
{
    return [[ZZNetworkTransport shared] requestWithPath:kApiGetAllOutgoingVideoStatus
                                             httpMethod:ANHttpMethodTypeGET];
}

@end
