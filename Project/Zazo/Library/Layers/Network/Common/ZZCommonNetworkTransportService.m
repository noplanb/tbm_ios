//
//  ZZCommonNetworkTransportService.m
//  Zazo
//
//  Created by ANODA on 8/11/15.
//  Copyright (c) 2015 ANODA. All rights reserved.
//

#import "ZZCommonNetworkTransportService.h"

@implementation ZZCommonNetworkTransportService

+ (RACSignal*)logMessage
{
    return [RACSignal empty];
}

+ (RACSignal*)checkApplicationVersion
{
    return [RACSignal empty];
}

+ (RACSignal*)loadS3Credentials
{
    return [RACSignal empty];
}

//+ (void) dispatch: (NSString *)msg{
//    [[TBMHttpManager manager] POST:
//                        parameters:@{SERVER_PARAMS_DISPATCH_MSG_KEY: msg,
//                                     SERVER_PARAMS_DISPATCH_DEVICE_MODEL_KEY: [[UIDevice currentDevice] model],
//                                     SERVER_PARAMS_DISPATCH_OS_VERSION_KEY: [[UIDevice currentDevice] systemVersion],
//                                     SERVER_PARAMS_DISPATCH_ZAZO_VERSION_KEY: CONFIG_VERSION_STRING,
//                                     SERVER_PARAMS_DISPATCH_ZAZO_VERSION_NUMBER_KEY: CONFIG_VERSION_NUMBER}
//                           success:nil
//                           failure:nil];
//}
//
//
//- (void) checkVersionCompatibility{
//    [[TBMHttpManager manager]
//     GET:@"version/check_compatibility"
//     parameters:@{@"device_platform": @"ios", @"version": CONFIG_VERSION_NUMBER}
//     success:^(AFHTTPRequestOperation *operation, id responseObject){
//         OB_INFO(@"checkVersionCompatibility: success: %@", [responseObject objectForKey:@"result"]);
//         if (_delegate)
//             [_delegate versionCheckCallback:[responseObject objectForKey:VH_RESULT_KEY]];
//     }
//     failure:^(AFHTTPRequestOperation *operation, NSError *error) {
//         OB_WARN(@"checkVersionCompatibility: %@", error);
//     }];
//}
//
//
//
//+ (void) refreshFromServer:(void (^)(BOOL))completionHandler{
//    OB_INFO(@"getS3Credentials");
//    [[TBMHttpManager manager] GET:@"s3_credentials/info"
//                       parameters:nil
//                          success:^(AFHTTPRequestOperation *operation, id responseObject) {
//                              if (![self validateServerResponse:responseObject]){
//                                  if (completionHandler != nil)
//                                      completionHandler(NO);
//                                  return;
//                              }
//                              [self storeS3CredentialsInKeychain:responseObject];
//                              if (completionHandler != nil)
//                                  completionHandler(YES);
//                          }
//                          failure:^(AFHTTPRequestOperation *operation, NSError *error){
//                              OB_WARN(@"Attempt to get s3 credentials failed.");
//                              if (completionHandler != nil)
//                                  completionHandler(NO);
//                          }];
//}

@end
