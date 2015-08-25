//
//  ZZVideoNetworkTransport.m
//  Zazo
//
//  Created by ANODA on 8/11/15.
//  Copyright (c) 2015 ANODA. All rights reserved.
//

#import "ZZVideoNetworkTransport.h"

@implementation ZZVideoNetworkTransport

#pragma mark - Videos
//
//- (void)deleteRemoteFile:(NSString *)filename {
//    
//    if (REMOTE_STORAGE_USE_S3) {
//        NSString *full = [NSString stringWithFormat:@"%@/%@", [TBMRemoteStorageHandler fileTransferDeletePath], filename];
//        [self performSelectorInBackground:@selector(ftmDelete:) withObject:full];
//    } else {
//        [[TBMHttpManager manager] GET:@"videos/delete"
//                           parameters:@{@"filename" : filename}
//                              success:nil
//                              failure:nil];
//    }
//}
//
//
//
//
//
//
//
//
//
//
//+ (void) getRemoteOutgoingVideoStatus:(TBMFriend *)friend
//                              success:(void(^)(NSDictionary *response))success
//                              failure:(void(^)(NSError *error))failure{
//    OB_INFO(@"getRemoteOutgoingVideoStatus");
//    NSString *key = [TBMRemoteStorageHandler outgoingVideoStatusRemoteKVKey:friend];
//    [[TBMHttpManager manager] GET:@"kvstore/get"
//                       parameters:@{@"key1": key}
//                          success:^(AFHTTPRequestOperation *operation, id responseObject) {
//                              success([self getStatusWithResponseObject:responseObject]);
//                          }
//                          failure:^(AFHTTPRequestOperation *operation, NSError *error) {
//                              failure(error);
//                          }];
//}
//
//
////------------
//// GetRemoteKV
////------------
//+ (void) getRemoteKVsWithKey:(NSString *)key1
//                     success:(void(^)(NSArray *response))success
//                     failure:(void(^)(NSError *error))failure{
//    [[TBMHttpManager manager] GET:@"kvstore/get_all"
//                       parameters:@{@"key1":key1}
//                          success:^(AFHTTPRequestOperation *operation, id responseObject){
//                              success(responseObject);
//                          }
//                          failure:^(AFHTTPRequestOperation *operation, NSError *error) {
//                              OB_WARN(@"ERROR: getRemoteKVWithKey: %@", [error localizedDescription]);
//                              failure(error);
//                          }];
//}
//
//
//
//
//+ (void) setRemoteKVWithKey1:(NSString *)key1 key2:(NSString *)key2 value:(NSDictionary *)value{
//    NSString *jsonValue = [TBMStringUtils jsonWithDictionary:value];
//    NSMutableDictionary *params = [[NSMutableDictionary alloc] initWithDictionary:@{@"key1": key1, @"value": jsonValue}];
//    if (key2 != nil)
//        [params setObject:key2 forKey:@"key2"];
//    [TBMRemoteStorageHandler simplePost:@"kvstore/set" params:params];
//}
//
//+ (void) deleteRemoteKVWithKey1:(NSString *)key1 key2:(NSString *)key2{
//    NSMutableDictionary *params = [[NSMutableDictionary alloc] initWithDictionary:@{@"key1": key1}];
//    if (key2 != nil)
//        [params setObject:key2 forKey:@"key2"];
//    [TBMRemoteStorageHandler simpleGet:@"kvstore/delete" params:params];
//}
//





@end
