//
//  ZZKeyStoreTransportService.m
//  Zazo
//
//  Created by Oksana Kovalchuk on 9/2/15.
//  Copyright (c) 2015 No Plan B. All rights reserved.
//

#import "ZZKeyStoreTransportService.h"
#import "ZZKeyStoreTransport.h"
#import "ZZStringUtils.h"

static const struct
{
    __unsafe_unretained NSString *key1;
    __unsafe_unretained NSString *key2;
    __unsafe_unretained NSString *value;
    
} ZZKeyStoreParameters =
{
    .key1 = @"key1",
    .key2 = @"key2",
    .value = @"value",
};

@implementation ZZKeyStoreTransportService

+ (RACSignal*)updateKey1:(NSString*)key1 key2:(NSString*)key2 value:(NSString*)value
{
    if (!ANIsEmpty(key1))
    {
        NSMutableDictionary* parameters = [NSMutableDictionary new];
        parameters[ZZKeyStoreParameters.key1] = key1;
        parameters[ZZKeyStoreParameters.value] = [NSObject an_safeString:value];
        if (key2)
        {
            parameters[ZZKeyStoreParameters.key2] = key2;
        }
        return [ZZKeyStoreTransport updateKeyValueWithParameters:parameters];
    }
    return [RACSignal error:nil];
}

+ (RACSignal*)deleteValueWithKey1:(NSString*)key1 key2:(NSString*)key2
{
    if (!ANIsEmpty(key1))
    {
        NSMutableDictionary* parameters = [NSMutableDictionary new];
        parameters[ZZKeyStoreParameters.key1] = key1;
        if (key2)
        {
            parameters[ZZKeyStoreParameters.key2] = key2;
        }
        return [ZZKeyStoreTransport deleteKeyValueWithParameters:parameters];
    }
    return [RACSignal error:nil];
}

+ (RACSignal*)loadValueWithKey1:(NSString*)key1
{
    if (!ANIsEmpty(key1))
    {
        return [ZZKeyStoreTransport loadKeyValueWithParameters:@{ZZKeyStoreParameters.key1 : key1}];
    }
    return [RACSignal error:nil];
}

@end

