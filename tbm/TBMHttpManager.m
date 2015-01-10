//
//  TBMHttpClient.m
//  tbm
//
//  Created by Sani Elfishawy on 5/3/14.
//  Copyright (c) 2014 No Plan B. All rights reserved.
//

#import "TBMHttpManager.h"
#import "TBMConfig.h"
#import "TBMUser.h"

NSString * const SERVER_PARAMS_STATUS_KEY = @"status";
NSString * const SERVER_PARAMS_ERROR_TITLE_KEY = @"title";
NSString * const SERVER_PARAMS_ERROR_MSG_KEY = @"msg";

NSString * const SERVER_STATUS_VALUE_SUCCESS = @"success";
NSString * const SERVER_STATUS_VALUE_FAILURE = @"failure";

NSString * const SERVER_PARAMS_USER_FIRST_NAME_KEY = @"first_name";
NSString * const SERVER_PARAMS_USER_LAST_NAME_KEY = @"last_name";
NSString * const SERVER_PARAMS_USER_MOBILE_NUMBER_KEY = @"mobile_number";
NSString * const SERVER_PARAMS_USER_ID_KEY = @"id";
NSString * const SERVER_PARAMS_USER_MKEY_KEY = @"mkey";
NSString * const SERVER_PARAMS_USER_AUTH_KEY = @"auth";
NSString * const SERVER_PARAMS_USER_DEVICE_PLATFORM_KEY = @"device_platform";
NSString * const SERVER_PARAMS_USER_VERIFICATION_CODE_KEY = @"verification_code";

NSString * const SERVER_PARAMS_FRIEND_FIRST_NAME_KEY = @"first_name";
NSString * const SERVER_PARAMS_FRIEND_LAST_NAME_KEY = @"last_name";
NSString * const SERVER_PARAMS_FRIEND_MOBILE_NUMBER_KEY = @"mobile_number";
NSString * const SERVER_PARAMS_FRIEND_ID_KEY = @"id";
NSString * const SERVER_PARAMS_FRIEND_MKEY_KEY = @"mkey";
NSString * const SERVER_PARAMS_FRIEND_CKEY_KEY = @"ckey";
NSString * const SERVER_PARAMS_FRIEND_HAS_APP = @"has_app";

NSString * const SERVER_PARAMS_S3_REGION_KEY = @"region";
NSString * const SERVER_PARAMS_S3_BUCKET_KEY = @"bucket";
NSString * const SERVER_PARAMS_S3_ACCESS_KEY = @"access_key";
NSString * const SERVER_PARAMS_S3_SECRET_KEY = @"secret_key";

NSString * const SERVER_PARAMS_DISPATCH_MSG_KEY = @"msg";

@implementation TBMHttpManager

+ (AFHTTPRequestOperationManager *)manager{
    AFHTTPRequestOperationManager *m = [[AFHTTPRequestOperationManager alloc] initWithBaseURL:[TBMConfig tbmBaseUrl]];
    m.credential = [[NSURLCredential alloc] initWithUser:@"username"
                                                password:@"password"
                                             persistence:NSURLCredentialPersistenceForSession];
    return m;
}

+ (BOOL) isSuccess:(NSDictionary *)responseObject{
    return [[responseObject objectForKey:SERVER_PARAMS_STATUS_KEY] isEqualToString:SERVER_STATUS_VALUE_SUCCESS];
}

+ (BOOL) isFailure:(NSDictionary *)responseObject{
    return ![TBMHttpManager isSuccess:responseObject];
}

+ (NSDictionary *)userCredentials{
    return @{
             SERVER_PARAMS_USER_MKEY_KEY: [TBMUser getUser].mkey,
             SERVER_PARAMS_USER_AUTH_KEY: [TBMUser getUser].auth
             };
}
@end
