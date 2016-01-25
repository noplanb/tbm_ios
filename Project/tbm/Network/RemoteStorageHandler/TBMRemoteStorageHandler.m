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
#import "TBMHttpManager.h"
#import "OBLogger.h"

#import "ZZAPIRoutes.h"
#import "ZZUserDomainModel.h"
#import "ZZUserDataProvider.h"
#import "ZZKeychainDataProvider.h"
#import "ZZS3CredentialsDomainModel.h"
#import "NSString+ZZAdditions.h"
#import "ZZStringUtils.h"

static NSString *const kArraySeparator = @",";

@implementation TBMRemoteStorageHandler


//------------------------
// Keys for remote storage
//------------------------
+ (NSString *)incomingVideoRemoteFilename:(TBMVideo *)video
{
    return [self incomingVideoRemoteFilenameWithFriend:video.friend videoId:video.videoId];
}

+ (NSString *)incomingVideoRemoteFilenameWithFriend:(TBMFriend *)friend videoID:(NSString *)videoID
{
    return [NSString stringWithFormat:@"%@-%@",
                                      [self incomingPrefix:friend],
                                      [[friend.ckey stringByAppendingString:videoID] zz_md5]];
}

+ (NSString *)outgoingVideoRemoteFilename:(TBMFriend *)friend videoID:(NSString *)videoID
{
    return [NSString stringWithFormat:@"%@-%@",
                                      [self outgoingPrefix:friend],
                                      [[friend.ckey stringByAppendingString:videoID] zz_md5]];
}

+ (NSString *)incomingVideoIDRemoteKVKey:(TBMFriend *)friend
{
    return [NSString stringWithFormat:@"%@-%@",
                                      [self incomingPrefix:friend],
                                      [self incomingSuffix:friend withTypeSuffix:REMOTE_STORAGE_VIDEO_ID_SUFFIX]];
}

+ (NSString *)outgoingVideoIDRemoteKVKey:(TBMFriend *)friend
{
    return [NSString stringWithFormat:@"%@-%@",
                                      [self outgoingPrefix:friend],
                                      [self outgoingSuffix:friend withTypeSuffix:REMOTE_STORAGE_VIDEO_ID_SUFFIX]];
}

+ (NSString *)incomingVideoStatusRemoteKVKey:(TBMFriend *)friend
{
    return [NSString stringWithFormat:@"%@-%@",
                                      [self incomingPrefix:friend],
                                      [self incomingSuffix:friend withTypeSuffix:REMOTE_STORAGE_STATUS_SUFFIX]];
}

+ (NSString *)outgoingVideoStatusRemoteKVKey:(TBMFriend *)friend
{
    return [NSString stringWithFormat:@"%@-%@",
                                      [self outgoingPrefix:friend],
                                      [self outgoingSuffix:friend withTypeSuffix:REMOTE_STORAGE_STATUS_SUFFIX]];
}

// Helpers

+ (NSString *)incomingPrefix:(TBMFriend *)friend
{
    ZZUserDomainModel* model = [ZZUserDataProvider authenticatedUser];
    return [NSString stringWithFormat:@"%@-%@", friend.mkey, model.mkey];
}

+ (NSString *)outgoingPrefix:(TBMFriend *)friend
{
     ZZUserDomainModel* model = [ZZUserDataProvider authenticatedUser];
    return [NSString stringWithFormat:@"%@-%@", model.mkey, friend.mkey];
}

+ (NSString *)incomingSuffix:(TBMFriend *)friend withTypeSuffix:(NSString *)typeSuffix
{
     ZZUserDomainModel* model = [ZZUserDataProvider authenticatedUser];
    NSString *md5 = [[[friend.mkey stringByAppendingString:model.mkey] stringByAppendingString:friend.ckey] zz_md5];
    return [md5 stringByAppendingString:typeSuffix];
}

+ (NSString *)outgoingSuffix:(TBMFriend *)friend withTypeSuffix:(NSString *)typeSuffix
{
     ZZUserDomainModel* model = [ZZUserDataProvider authenticatedUser];
    NSString *md5 = [[[model.mkey stringByAppendingString:friend.mkey] stringByAppendingString:friend.ckey] zz_md5];
    return [md5 stringByAppendingString:typeSuffix];
}


//-----------------------
// URLs for file transfer
//-----------------------
+ (NSString *)fileTransferRemoteUrlBase
{
    return REMOTE_STORAGE_USE_S3 ? REMOTE_STORAGE_S3_BASE_URL_STRING : apiBaseURL();
}

+ (NSString *)fileTransferUploadPath
{
    return REMOTE_STORAGE_USE_S3 ? [self s3Bucket] : REMOTE_STORAGE_SERVER_VIDEO_UPLOAD_PATH;
}

+ (NSString *)fileTransferDownloadPath
{
    return REMOTE_STORAGE_USE_S3 ? [self s3Bucket] : REMOTE_STORAGE_SERVER_VIDEO_DOWNLOAD_PATH;
}

+ (NSString *)fileTransferDeletePath
{
    return [self s3Bucket];
}

+ (NSString *)s3Bucket
{
    return [ZZKeychainDataProvider loadCredentials].bucket;
}

//-------------------------
// Simple http get and post
//-------------------------

+ (void)simpleGet:(NSString *)path params:(NSDictionary *)params
{
    [[TBMHttpManager manager]
            GET:path
     parameters:params
        success:nil
        failure:nil];
}

+ (void)simplePost:(NSString *)path params:(NSDictionary *)params
{
    [[TBMHttpManager manager]
            POST:path
      parameters:params
         success:nil
         failure:nil];
}


//------------------
// set and delete kv
//------------------
+ (void)setRemoteKVWithKey1:(NSString *)key1 key2:(NSString *)key2 value:(NSDictionary *)value
{
    NSString *jsonValue = [ZZStringUtils jsonWithDictionary:value];
    NSMutableDictionary *params = [[NSMutableDictionary alloc] initWithDictionary:@{@"key1" : key1, @"value" : jsonValue}];
    if (key2 != nil)
        [params setObject:key2 forKey:@"key2"];
    [TBMRemoteStorageHandler simplePost:@"kvstore/set" params:params];
}

+ (void)deleteRemoteKVWithKey1:(NSString *)key1 key2:(NSString *)key2
{
    NSMutableDictionary *params = [[NSMutableDictionary alloc] initWithDictionary:@{@"key1" : key1}];
    if (key2 != nil)
        [params setObject:key2 forKey:@"key2"];
    [TBMRemoteStorageHandler simpleGet:@"kvstore/delete" params:params];
}

// Convenience setters
+ (void)addRemoteOutgoingVideoID:(NSString *)videoID friend:(TBMFriend *)friend
{
    OB_INFO(@"addRemoteOutgoingVideoId");
    NSDictionary *value = @{REMOTE_STORAGE_VIDEO_ID_KEY : videoID};
    NSString *key1 = [TBMRemoteStorageHandler outgoingVideoIDRemoteKVKey:friend];
    [TBMRemoteStorageHandler setRemoteKVWithKey1:key1 key2:videoID value:value];
}

+ (void)deleteRemoteIncomingVideoID:(NSString *)videoID friend:(TBMFriend *)friend
{
    OB_INFO(@"deleteRemoteIncomingVideoId");
    NSString *key1 = [TBMRemoteStorageHandler incomingVideoIDRemoteKVKey:friend];
    [TBMRemoteStorageHandler deleteRemoteKVWithKey1:key1 key2:videoID];
}

+ (void)setRemoteIncomingVideoStatus:(NSString *)status videoID:(NSString *)videoID friend:(TBMFriend *)friend
{
    OB_INFO(@"setRemoteIncomingVideoStatus");
    if (!ANIsEmpty(videoID) && !ANIsEmpty(friend))
    {
        NSDictionary *value = @{REMOTE_STORAGE_VIDEO_ID_KEY : videoID, REMOTE_STORAGE_STATUS_KEY : status};
        NSString *key = [TBMRemoteStorageHandler incomingVideoStatusRemoteKVKey:friend];
        [TBMRemoteStorageHandler setRemoteKVWithKey1:key key2:NULL value:value];
    }
    
}


// Convenience getters
+ (void)getRemoteIncomingVideoIdsWithFriend:(TBMFriend *)friend gotVideoIds:(void (^)(NSArray *videoIds))gotVideoIds
{
//    __block TBMFriend* someFriend = friend;
    OB_INFO(@"getRemoteIncomingVideoIdsWithFriend:");
    NSString *key1 = [TBMRemoteStorageHandler incomingVideoIDRemoteKVKey:friend];
    
    [TBMRemoteStorageHandler getRemoteKVsWithKey:key1 success:^(NSArray *response) {
    
        NSArray *vIds = [TBMRemoteStorageHandler getVideoIdsWithResponseObjects:response];
        gotVideoIds(vIds);
    
    } failure:^(NSError *error) {
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
    NSString *key = [TBMRemoteStorageHandler outgoingVideoStatusRemoteKVKey:friend];
    [[TBMHttpManager manager] GET:@"kvstore/get"
                       parameters:@{@"key1" : key}
                          success:^(AFHTTPRequestOperation *operation, id responseObject)
                          {
                              success([self getStatusWithResponseObject:responseObject]);
                          }
                          failure:^(AFHTTPRequestOperation *operation, NSError *error)
                          {
                              failure(error);
                          }];
}

+ (NSDictionary *)getStatusWithResponseObject:(NSDictionary *)response
{
    NSString *valueJson = response[@"value"];
    return [ZZStringUtils dictionaryWithJson:valueJson];
}


#pragma mark - Single Request Polling
+ (void)getAllRemoteIncomingVideoIds
{
    [[TBMHttpManager manager] GET:@"kvstore/received_videos"
                       parameters:nil
                          success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject)
                          {
                              OB_INFO(@"Success");
                          }
                          failure:^(AFHTTPRequestOperation * _Nonnull operation, NSError * _Nonnull error)
                          {
                                OB_INFO(@"Success");
                          }
     ];
}

+ (void)getAllRemoteOutgoingVideoStatus
{
    [[TBMHttpManager manager] GET:@"kvstore/video_status"
                       parameters:nil
                          success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject)
                          {
                              OB_INFO(@"Success");
                          }
                          failure:^(AFHTTPRequestOperation * _Nonnull operation, NSError * _Nonnull error)
                          {
                              OB_INFO(@"Success");

                          }
     ];

}

#pragma mark - EverSentFriends

+ (void)getRemoteEverSentFriendsWithSuccess:(void (^)(NSArray *response))success
                                    failure:(void (^)(NSError *error))failure
{
    OB_INFO(@"getRemoteEverSentVideoStatus");

    NSString *key = [self _welcomedFriendsKey];
    [[TBMHttpManager manager] GET:@"kvstore/get"
                       parameters:@{@"key1" : key}
                          success:^(AFHTTPRequestOperation *operation, id responseObject)
                          {
                              NSArray *parsedArray = [self _parseEverSentFriendsResponse:responseObject];
                              if (success && parsedArray)
                              {
                                  success(parsedArray);
                              }
                          }
                          failure:^(AFHTTPRequestOperation *operation, NSError *error)
                          {
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
    NSDictionary *parameters = @{
            @"key1" : [self _welcomedFriendsKey],
            @"value" : mkeyArrayString
    };
    [[TBMHttpManager manager] POST:@"kvstore/set"
                        parameters:parameters
                           success:^(AFHTTPRequestOperation *operation, id responseObject)
                           {

                               OB_INFO(@"setRemoteEverSentKVForFriendMkey - success for friends %@", mkeys);
                           }
                           failure:^(AFHTTPRequestOperation *operation, NSError *error)
                           {
                               OB_ERROR(@"setRemoteEverSentKVForFriendMkey - error for friends %@ : %@", mkeys, error);
                           }];

}

//------------
// GetRemoteKV
//------------
+ (void)getRemoteKVsWithKey:(NSString *)key1
                    success:(void (^)(NSArray *response))success
                    failure:(void (^)(NSError *error))failure
{
    [[TBMHttpManager manager] GET:@"kvstore/get_all"
                       parameters:@{@"key1" : key1}
                          success:^(AFHTTPRequestOperation *operation, id responseObject)
                          {
                              success(responseObject);
                          }
                          failure:^(AFHTTPRequestOperation *operation, NSError *error)
                          {
                              OB_WARN(@"ERROR: getRemoteKVWithKey: %@", [error localizedDescription]);
                              failure(error);
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
