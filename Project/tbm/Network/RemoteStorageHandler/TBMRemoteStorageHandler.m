//
//  TBMRemoteStorageHandler.m
//  tbm
//
//  Created by Sani Elfishawy on 7/29/14.
//  Copyright (c) 2014 No Plan B. All rights reserved.
//

#import "TBMRemoteStorageHandler.h"
#import "TBMFriend.h"
#import "TBMUser.h"
#import "OBLogger.h"

#import "ZZAPIRoutes.h"
#import "ZZUserDomainModel.h"
#import "ZZUserDataProvider.h"
#import "ZZKeychainDataProvider.h"
#import "ZZS3CredentialsDomainModel.h"
#import "NSString+ZZAdditions.h"
#import "ZZStringUtils.h"
#import "ZZKeyStoreTransportService.h"
#import "ZZRemoteStorageValueGenerator.h"

static NSString *const kArraySeparator = @",";

@implementation TBMRemoteStorageHandler

// Convenience setters
+ (void)addRemoteOutgoingVideoId:(NSString*)videoId friend:(TBMFriend*)friend
{
    OB_INFO(@"addRemoteOutgoingVideoId");
    NSDictionary *value = @{REMOTE_STORAGE_VIDEO_ID_KEY : videoId};
    NSString *key1 = [ZZRemoteStorageValueGenerator outgoingVideoIDRemoteKVKey:friend];
    
    [[ZZKeyStoreTransportService updateKey1:key1
                                       key2:videoId
                                      value:[ZZStringUtils jsonWithDictionary:value]] subscribeNext:^(id x) {}];
}

+ (void)deleteRemoteIncomingVideoId:(NSString *)videoId friend:(TBMFriend *)friend
{
    OB_INFO(@"deleteRemoteIncomingVideoId");
    NSString *key1 = [ZZRemoteStorageValueGenerator incomingVideoIDRemoteKVKey:friend];
    [[ZZKeyStoreTransportService deleteValueWithKey1:key1 key2:videoId] subscribeNext:^(id x) {}];
}

+ (void)setRemoteIncomingVideoStatus:(NSString *)status videoId:(NSString *)videoId friend:(TBMFriend *)friend
{
    OB_INFO(@"setRemoteIncomingVideoStatus");
    if (!ANIsEmpty(videoId) && !ANIsEmpty(friend))
    {
        NSDictionary *value = @{REMOTE_STORAGE_VIDEO_ID_KEY : videoId, REMOTE_STORAGE_STATUS_KEY : status};
        NSString *key = [ZZRemoteStorageValueGenerator incomingVideoStatusRemoteKVKey:friend];
        [[ZZKeyStoreTransportService updateKey1:key
                                           key2:NULL
                                          value:[ZZStringUtils jsonWithDictionary:value]] subscribeNext:^(id x) {}];
    }
}


// Convenience getters
+ (void)getRemoteIncomingVideoIdsWithFriend:(TBMFriend *)friend gotVideoIds:(void (^)(NSArray *videoIds))gotVideoIds
{
//    __block TBMFriend* someFriend = friend;
    OB_INFO(@"getRemoteIncomingVideoIdsWithFriend:");
    NSString *key1 = [ZZRemoteStorageValueGenerator incomingVideoIDRemoteKVKey:friend];
    
    [[ZZKeyStoreTransportService loadValueWithKey1:key1] subscribeNext:^(id x) {
        
        NSArray *vIds = [self getVideoIdsWithResponseObjects:x];
        gotVideoIds(vIds);
        
    } error:^(NSError *error) {
        OB_WARN(@"getRemoteIncomingVideoIdsWithFriend: failure: %@", error);
    }];
}

+ (NSArray *)getVideoIdsWithResponseObjects:(NSArray *)responseObjects
{
    NSMutableArray *vIds = [[NSMutableArray alloc] init];
    for (NSDictionary *r in responseObjects)
    {
        NSString *valueJson = [r objectForKey:@"value"];
        NSDictionary *valueObj = [ZZStringUtils dictionaryWithJson:valueJson];
        [vIds addObject:[valueObj objectForKey:REMOTE_STORAGE_VIDEO_ID_KEY]];
    }
    return vIds;
}

+ (void)getRemoteOutgoingVideoStatus:(TBMFriend *)friend
                             success:(void (^)(NSDictionary *response))success
                             failure:(void (^)(NSError *error))failure
{
    OB_INFO(@"getRemoteOutgoingVideoStatus");
    NSString *key = [ZZRemoteStorageValueGenerator outgoingVideoStatusRemoteKVKey:friend];
    
    [[ZZKeyStoreTransportService loadValueWithKey1:key] subscribeNext:^(id x) {
        success([self getStatusWithResponseObject:x]);
    } error:^(NSError *error) {
        failure(error);
    }];
}

+ (NSDictionary *)getStatusWithResponseObject:(NSDictionary *)response
{
    NSString *valueJson = response[@"value"];
    return [ZZStringUtils dictionaryWithJson:valueJson];
}

+ (void)getRemoteEverSentFriendsWithSuccess:(void (^)(NSArray *response))success
                                    failure:(void (^)(NSError *error))failure
{
    OB_INFO(@"getRemoteEverSentVideoStatus");

    NSString *key = [self _welcomedFriendsKey];
    [[ZZKeyStoreTransportService loadValueWithKey1:key] subscribeNext:^(id x) {
        
        NSArray *parsedArray = [self _parseEverSentFriendsResponse:x];
        if (success && parsedArray)
        {
            success(parsedArray);
        }
        
    } error:^(NSError *error) {
        if (failure)
        {
            failure(error);
        }
    }];
}

#pragma mark - KV Store set values

+ (void)setRemoteEverSentKVForFriendMkeys:(NSArray *)mkeys
{
    NSString *mkeyArrayString = [mkeys componentsJoinedByString:kArraySeparator];
    
    [[ZZKeyStoreTransportService updateKey1:[self _welcomedFriendsKey] key2:nil value:mkeyArrayString] subscribeNext:^(id x) {
        
        OB_INFO(@"setRemoteEverSentKVForFriendMkey - success for friends %@", mkeys);
        
    } error:^(NSError *error) {
        
        OB_ERROR(@"setRemoteEverSentKVForFriendMkey - error for friends %@ : %@", mkeys, error);
    }];
}



//----------------------------
// Conversion of status values
//----------------------------
+ (int)outgoingVideoStatusWithRemoteStatus:(NSString *)remoteStatus
{
    if ([remoteStatus isEqualToString:REMOTE_STORAGE_STATUS_DOWNLOADED])
        return OUTGOING_VIDEO_STATUS_DOWNLOADED;

    if ([remoteStatus isEqualToString:REMOTE_STORAGE_STATUS_VIEWED])
        return OUTGOING_VIDEO_STATUS_VIEWED;

    return -1;
}

#pragma mark Private

+ (NSArray *)_parseEverSentFriendsResponse:(id)object
{
    if (![object isKindOfClass:[NSDictionary class]])
    {
        return nil;
    }

    NSDictionary *response = (NSDictionary *) object;
    id value = response[@"value"];

    if (!value)
    {
        return nil;
    }

    if ([value isKindOfClass:[NSString class]])
    {
        return [value componentsSeparatedByString:kArraySeparator];
    }

    if ([value isKindOfClass:[NSArray class]])
    {
        return (NSArray *)value;
    }

    return nil;
}

+ (NSString *)_welcomedFriendsKey
{
    ZZUserDomainModel* model = [ZZUserDataProvider authenticatedUser];
    return [NSString stringWithFormat:@"%@-WelcomedFriends", model.mkey];
}


@end
