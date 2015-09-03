//
//  ZZKeyStoreTransport.m
//  Zazo
//
//  Created by Oksana Kovalchuk on 9/2/15.
//  Copyright (c) 2015 No Plan B. All rights reserved.
//

#import "ZZKeyStoreTransport.h"

@implementation ZZKeyStoreTransport

//+ (RACSignal*)updateValueOnFirstKey:(NSString*)firstKey secondKey:(NSString*)secondKey updatedValue:(NSDictionary*)updatedValue
//{
//    
//}
//





//
////------------------
//// set and delete kv
////------------------
//+ (void)setRemoteKVWithKey1:(NSString *)key1 key2:(NSString *)key2 value:(NSDictionary *)value
//{
//    NSString *jsonValue = [TBMStringUtils jsonWithDictionary:value];
//    NSMutableDictionary *params = [[NSMutableDictionary alloc] initWithDictionary:@{@"key1" : key1, @"value" : jsonValue}];
//    if (key2 != nil)
//        [params setObject:key2 forKey:@"key2"];
//    [TBMRemoteStorageHandler simplePost:@"kvstore/set" params:params];
//}
//
//+ (void)deleteRemoteKVWithKey1:(NSString *)key1 key2:(NSString *)key2
//{
//    NSMutableDictionary *params = [[NSMutableDictionary alloc] initWithDictionary:@{@"key1" : key1}];
//    if (key2 != nil)
//        [params setObject:key2 forKey:@"key2"];
//    [TBMRemoteStorageHandler simpleGet:@"kvstore/delete" params:params];
//}
//
//// Convenience setters
//+ (void)addRemoteOutgoingVideoId:(NSString *)videoId friend:(TBMFriend *)friend
//{
//    OB_INFO(@"addRemoteOutgoingVideoId");
//    NSDictionary *value = @{REMOTE_STORAGE_VIDEO_ID_KEY : videoId};
//    NSString *key1 = [TBMRemoteStorageHandler outgoingVideoIDRemoteKVKey:friend];
//    [TBMRemoteStorageHandler setRemoteKVWithKey1:key1 key2:videoId value:value];
//}
//
//+ (void)deleteRemoteIncomingVideoId:(NSString *)videoId friend:(TBMFriend *)friend
//{
//    OB_INFO(@"deleteRemoteIncomingVideoId");
//    NSString *key1 = [TBMRemoteStorageHandler incomingVideoIDRemoteKVKey:friend];
//    [TBMRemoteStorageHandler deleteRemoteKVWithKey1:key1 key2:videoId];
//}
//
//+ (void)setRemoteIncomingVideoStatus:(NSString *)status videoId:(NSString *)videoId friend:(TBMFriend *)friend
//{
//    OB_INFO(@"setRemoteIncomingVideoStatus");
//    NSDictionary *value = @{REMOTE_STORAGE_VIDEO_ID_KEY : videoId, REMOTE_STORAGE_STATUS_KEY : status};
//    NSString *key = [TBMRemoteStorageHandler incomingVideoStatusRemoteKVKey:friend];
//    [TBMRemoteStorageHandler setRemoteKVWithKey1:key key2:NULL value:value];
//}
//
//
//// Convenience getters
//+ (void)getRemoteIncomingVideoIdsWithFriend:(TBMFriend *)friend gotVideoIds:(void (^)(NSArray *videoIds))gotVideoIds
//{
//    OB_INFO(@"getRemoteIncomingVideoIdsWithFriend:");
//    NSString *key1 = [TBMRemoteStorageHandler incomingVideoIDRemoteKVKey:friend];
//    [TBMRemoteStorageHandler getRemoteKVsWithKey:key1 success:^(NSArray *response)
//    {
//        NSArray *vIds = [TBMRemoteStorageHandler getVideoIdsWithResponseObjects:response];
//        gotVideoIds(vIds);
//    }                                    failure:^(NSError *error)
//    {
//        OB_WARN(@"getRemoteIncomingVideoIdsWithFriend: failure: %@", error);
//    }];
//}
//
//+ (NSArray *)getVideoIdsWithResponseObjects:(NSArray *)responseObjects
//{
//    NSMutableArray *vIds = [[NSMutableArray alloc] init];
//    for (NSDictionary *r in responseObjects)
//    {
//        NSString *valueJson = [r objectForKey:@"value"];
//        NSDictionary *valueObj = [TBMStringUtils dictionaryWithJson:valueJson];
//        [vIds addObject:[valueObj objectForKey:REMOTE_STORAGE_VIDEO_ID_KEY]];
//    }
//    return vIds;
//}
//
//+ (void)getRemoteOutgoingVideoStatus:(TBMFriend *)friend
//                             success:(void (^)(NSDictionary *response))success
//                             failure:(void (^)(NSError *error))failure
//{
//    OB_INFO(@"getRemoteOutgoingVideoStatus");
//    NSString *key = [TBMRemoteStorageHandler outgoingVideoStatusRemoteKVKey:friend];
//    [[TBMHttpManager manager] GET:@"kvstore/get"
//                       parameters:@{@"key1" : key}
//                          success:^(AFHTTPRequestOperation *operation, id responseObject)
//                          {
//                              success([self getStatusWithResponseObject:responseObject]);
//                          }
//                          failure:^(AFHTTPRequestOperation *operation, NSError *error)
//                          {
//                              failure(error);
//                          }];
//}
//
//+ (NSDictionary *)getStatusWithResponseObject:(NSDictionary *)response
//{
//    NSString *valueJson = response[@"value"];
//    return [TBMStringUtils dictionaryWithJson:valueJson];
//}
//
//+ (void)getRemoteEverSentFriendsWithSuccess:(void (^)(NSArray *response))success
//                                    failure:(void (^)(NSError *error))failure
//{
//    OB_INFO(@"getRemoteEverSentVideoStatus");
//
//    NSString *key = [self _welcomedFriendsKey];
//    [[TBMHttpManager manager] GET:@"kvstore/get"
//                       parameters:@{@"key1" : key}
//                          success:^(AFHTTPRequestOperation *operation, id responseObject)
//                          {
//                              NSArray *parsedArray = [self _parseEverSentFriendsResponse:responseObject];
//                              if (success && parsedArray)
//                              {
//                                  success(parsedArray);
//                              }
//                          }
//                          failure:^(AFHTTPRequestOperation *operation, NSError *error)
//                          {
//                              if (failure)
//                              {
//                                  failure(error);
//                              }
//                          }];
//}
//
//#pragma mark - KV Store set values
//
//+ (void)setRemoteEverSentKVForFriendMkeys:(NSArray *)mkeys
//{
//    NSString *mkeyArrayString = [mkeys componentsJoinedByString:kArraySeparator];
//    NSDictionary *parameters = @{
//            @"key1" : [self _welcomedFriendsKey],
//            @"value" : mkeyArrayString
//    };
//    [[TBMHttpManager manager] POST:@"kvstore/set"
//                        parameters:parameters
//                           success:^(AFHTTPRequestOperation *operation, id responseObject)
//                           {
//
//                               OB_INFO(@"setRemoteEverSentKVForFriendMkey - success for friends %@", mkeys);
//                           }
//                           failure:^(AFHTTPRequestOperation *operation, NSError *error)
//                           {
//                               OB_ERROR(@"setRemoteEverSentKVForFriendMkey - error for friends %@ : %@", mkeys, error);
//                           }];
//
//}
//
////------------
//// GetRemoteKV
////------------
//+ (void)getRemoteKVsWithKey:(NSString *)key1
//                    success:(void (^)(NSArray *response))success
//                    failure:(void (^)(NSError *error))failure
//{
//    [[TBMHttpManager manager] GET:@"kvstore/get_all"
//                       parameters:@{@"key1" : key1}
//                          success:^(AFHTTPRequestOperation *operation, id responseObject)
//                          {
//                              success(responseObject);
//                          }
//                          failure:^(AFHTTPRequestOperation *operation, NSError *error)
//                          {
//                              OB_WARN(@"ERROR: getRemoteKVWithKey: %@", [error localizedDescription]);
//                              failure(error);
//                          }];
//}



@end
