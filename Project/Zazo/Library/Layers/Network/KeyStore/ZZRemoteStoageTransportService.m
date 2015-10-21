//
//  ZZRemoteStoageTransportService.m
//  Zazo
//
//  Created by Oksana Kovalchuk on 9/2/15.
//  Copyright (c) 2015 No Plan B. All rights reserved.
//

#import "ZZRemoteStoageTransportService.h"
#import "ZZRemoteStorageTransport.h"
#import "ZZStringUtils.h"

#import "ZZRemoteStorageValueGenerator.h"
#import "ZZRemoteStorageConstants.h"

@implementation ZZRemoteStoageTransportService


#pragma mark - Update / Create

+ (RACSignal*)addRemoteOutgoingVideoWithItemID:(NSString*)itemID
                                    friendMkey:(NSString*)friendMkey
                                    friendCKey:(NSString*)friendCKey
{
    if (!ANIsEmpty(itemID) && !ANIsEmpty(friendMkey) && !ANIsEmpty(friendCKey))
    {
        NSDictionary *value = @{ZZRemoteStorageParameters.videoID : itemID};
        NSString *key1 = [ZZRemoteStorageValueGenerator outgoingVideoIDRemoteKVWithFriendMKey:friendMkey
                                                                                   friendCKey:friendCKey];
        
        return [self updateKey1:key1
                           key2:itemID
                          value:[ZZStringUtils jsonWithDictionary:value]];
    }
    return [RACSignal error:nil];
}

+ (RACSignal*)deleteRemoteIncomingVideoWithItemID:(NSString*)itemID
                                       friendMkey:(NSString*)friendMkey
                                       friendCKey:(NSString*)friendCKey
{
    NSString *key1 = [ZZRemoteStorageValueGenerator outgoingVideoIDRemoteKVWithFriendMKey:friendMkey
                                                                               friendCKey:friendCKey];
    return [self deleteValueWithKey1:key1 key2:itemID];
}

+ (RACSignal*)updateRemoteStatusForVideoWithItemID:(NSString*)itemID
                                          toStatus:(ZZRemoteStorageVideoStatus)status
                                        friendMkey:(NSString*)friendMkey
                                        friendCKey:(NSString*)friendCKey
{
    if (!ANIsEmpty(itemID) && !ANIsEmpty(friendCKey) && !ANIsEmpty(friendMkey))
    {
        NSString* statusString = ZZRemoteStorageVideoStatusStringFromEnumValue(status);
        NSDictionary *value = @{ZZRemoteStorageParameters.videoID : itemID,
                                ZZRemoteStorageParameters.status  : statusString};
        
        NSString *key = [ZZRemoteStorageValueGenerator incomingVideoStatusRemoteKVKeyWithFriendMKey:friendMkey
                                                                                         friendCKey:friendCKey];
        return [self updateKey1:key
                           key2:NULL
                          value:[ZZStringUtils jsonWithDictionary:value]];
    }
    return [RACSignal error:nil];
}


#pragma mark - Load

+ (RACSignal*)loadRemoteIncomingVideoIDsWithFriendMkey:(NSString*)friendMkey
                                            friendCKey:(NSString*)friendCKey
{
    NSString *key1 = [ZZRemoteStorageValueGenerator outgoingVideoIDRemoteKVWithFriendMKey:friendMkey
                                                                               friendCKey:friendCKey];

    return [[[self loadValueWithKey1:key1] map:^id(NSArray* value) {
        
        return [[value.rac_sequence map:^id(NSDictionary* object) { //TODO: additional checks and safety
            
            NSString *valueJson = object[ZZRemoteStorageParameters.value];
            NSDictionary *valueObj = [ZZStringUtils dictionaryWithJson:valueJson];
            return valueObj[ZZRemoteStorageParameters.videoID];
            
        }] array];
    }] doError:^(NSError *error) {
        OB_WARN(@"getRemoteIncomingVideoIdsWithFriend: failure: %@", error);
    }];
}

+ (RACSignal*)loadRemoteOutgoingVideoStatusForFriendMkey:(NSString*)friendMkey
                                              friendCKey:(NSString*)friendCKey
{
    NSString *key = [ZZRemoteStorageValueGenerator outgoingVideoStatusRemoteKVKeyWithFriendMKey:friendMkey
                                                                                     friendCKey:friendCKey];
    
    return [[self loadValueWithKey1:key] map:^id(id value) {
        
        if ([value isKindOfClass:[NSDictionary class]])
        {
            NSString *valueJson = value[ZZRemoteStorageParameters.value];
            return [ZZStringUtils dictionaryWithJson:valueJson];
        }
        return nil;
    }];
}

+ (RACSignal*)loadRemoteEverSentFriendsIDsForUserMkey:(NSString*)mKey
{
    NSString *key = [NSString stringWithFormat:@"%@-WelcomedFriends", mKey];
    return [[self loadValueWithKey1:key] map:^id(NSDictionary* object) {
        
        if ([object isKindOfClass:[NSDictionary class]])
        {
            id value = object[ZZRemoteStorageParameters.value];
            return [value componentsSeparatedByString:kRemoteStorageArraySeparator];
        }
        return nil;
    }];
}


#pragma mark - Update

+ (RACSignal*)updateRemoteEverSentKVForFriendMkeys:(NSArray *)mkeys forUserMkey:(NSString*)mKey
{
    NSString *mkeyArrayString = [mkeys componentsJoinedByString:kRemoteStorageArraySeparator];
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
        parameters[ZZRemoteStorageParameters.key1] = key1;
        parameters[ZZRemoteStorageParameters.value] = [NSObject an_safeString:value];
        if (key2)
        {
            parameters[ZZRemoteStorageParameters.key2] = key2;
        }
        return [ZZRemoteStorageTransport updateKeyValueWithParameters:parameters];
    }
    return [RACSignal error:nil];
}

+ (RACSignal*)deleteValueWithKey1:(NSString*)key1 key2:(NSString*)key2
{
    if (!ANIsEmpty(key1))
    {
        NSMutableDictionary* parameters = [NSMutableDictionary new];
        parameters[ZZRemoteStorageParameters.key1] = key1;
        if (key2)
        {
            parameters[ZZRemoteStorageParameters.key2] = key2;
        }
        return [ZZRemoteStorageTransport deleteKeyValueWithParameters:parameters];
    }
    return [RACSignal error:nil];
}

+ (RACSignal*)loadValueWithKey1:(NSString*)key1
{
    if (!ANIsEmpty(key1))
    {
        return [[ZZRemoteStorageTransport loadKeyValueWithParameters:@{ZZRemoteStorageParameters.key1 : key1}] map:^id(NSArray* value) {
            return [value firstObject];
        }];
    }
    return [RACSignal error:nil];
}

@end

