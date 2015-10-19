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

#import "TBMFriend.h"
#import "ZZRemoteStorageValueGenerator.h"

static const struct
{
    __unsafe_unretained NSString *key1;
    __unsafe_unretained NSString *key2;
    __unsafe_unretained NSString *value;
    __unsafe_unretained NSString *videoID;
    __unsafe_unretained NSString *status;
    
} ZZKeyStoreParameters =
{
    .key1 = @"key1",
    .key2 = @"key2",
    .value = @"value",
    .videoID = @"videoID",
    .status = @"status",
};

static NSString *const kArraySeparator = @",";

@implementation ZZKeyStoreTransportService


#pragma mark - Update / Create

+ (RACSignal*)addRemoteOutgoingVideoWithItemID:(NSString*)itemID friend:(TBMFriend*)friend
{
    if (!ANIsEmpty(itemID) && !ANIsEmpty(friend))
    {
        NSDictionary *value = @{ZZKeyStoreParameters.videoID : itemID};
        NSString *key1 = [ZZRemoteStorageValueGenerator outgoingVideoIDRemoteKVKey:friend];
        
        return [self updateKey1:key1
                           key2:itemID
                          value:[ZZStringUtils jsonWithDictionary:value]];
    }
    return [RACSignal error:nil];
}

+ (RACSignal*)deleteRemoteIncomingVideoWithItemID:(NSString*)itemID friend:(TBMFriend*)friend
{
    NSString *key1 = [ZZRemoteStorageValueGenerator incomingVideoIDRemoteKVKey:friend];
    return [self deleteValueWithKey1:key1 key2:itemID];
}

+ (RACSignal*)updateRemoteStatusForVideoWithItemID:(NSString*)itemID toStatus:(NSString*)status friend:(TBMFriend*)friend
{
    if (!ANIsEmpty(itemID) && !ANIsEmpty(friend))
    {
        NSDictionary *value = @{ZZKeyStoreParameters.videoID : itemID,
                                ZZKeyStoreParameters.status  : status};
        
        NSString *key = [ZZRemoteStorageValueGenerator incomingVideoStatusRemoteKVKey:friend];
        return [self updateKey1:key
                           key2:NULL
                          value:[ZZStringUtils jsonWithDictionary:value]];
    }
    return [RACSignal error:nil];
}


#pragma mark - Load

+ (RACSignal*)loadRemoteIncomingVideoIDsWithFriend:(TBMFriend*)friend
{
    NSString *key1 = [ZZRemoteStorageValueGenerator incomingVideoIDRemoteKVKey:friend];
    
    return [[[self loadValueWithKey1:key1] map:^id(NSArray* value) {
        
        return [[value.rac_sequence map:^id(NSDictionary* object) { //TODO: additional checks and safety
            
            NSString *valueJson = object[ZZKeyStoreParameters.value];
            NSDictionary *valueObj = [ZZStringUtils dictionaryWithJson:valueJson];
            return valueObj[ZZKeyStoreParameters.videoID];
            
        }] array];
    }] doError:^(NSError *error) {
        OB_WARN(@"getRemoteIncomingVideoIdsWithFriend: failure: %@", error);
    }];
}

+ (RACSignal*)loadRemoteOutgoingVideoStatusForFriend:(TBMFriend*)friend
{
    NSString *key = [ZZRemoteStorageValueGenerator outgoingVideoStatusRemoteKVKey:friend];
    
    return [[self loadValueWithKey1:key] map:^id(id value) {
        
        NSString *valueJson = value[ZZKeyStoreParameters.value];
        return [ZZStringUtils dictionaryWithJson:valueJson];
    }];
}

+ (RACSignal*)loadRemoteEverSentFriendsIDsForUserMkey:(NSString*)mKey
{
    NSString *key = [NSString stringWithFormat:@"%@-WelcomedFriends", mKey];
    return [[self loadValueWithKey1:key] map:^id(NSDictionary* object) {
        
        if ([object isKindOfClass:[NSDictionary class]])
        {
            id value = object[ZZKeyStoreParameters.value];
            return [value componentsSeparatedByString:kArraySeparator];
        }
        else
        {
            NSAssert(NO, @"something wrong with result type");
        }
        return nil;
    }];
}


#pragma mark - Update

+ (RACSignal*)updateRemoteEverSentKVForFriendMkeys:(NSArray *)mkeys forUserMkey:(NSString*)mKey
{
    NSString *mkeyArrayString = [mkeys componentsJoinedByString:kArraySeparator];
    NSString *key = [NSString stringWithFormat:@"%@-WelcomedFriends", mKey];
    
    return [[[self updateKey1:key key2:nil value:mkeyArrayString] doNext:^(id x) {
        
        OB_INFO(@"setRemoteEverSentKVForFriendMkey - success for friends %@", mkeys);
        
    }] doError:^(NSError *error) {
        
        OB_ERROR(@"setRemoteEverSentKVForFriendMkey - error for friends %@ : %@", mkeys, error);
    }];
}


#pragma mark - Basic CRUD

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

