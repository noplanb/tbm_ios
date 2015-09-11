//
//  TBMS3CredentialsManager.m
//  tbm
//
//  Created by Sani Elfishawy on 1/5/15.
//  Copyright (c) 2015 No Plan B. All rights reserved.
//

#import "TBMS3CredentialsManager.h"
#import "TBMHttpManager.h"
#import "OBLogger.h"
#import "TBMKeyChainWrapper.h"
#import "ZZCommonNetworkTransportService.h"

NSString * const S3_REGION_KEY = @"TBMS3Region";
NSString * const S3_BUCKET_KEY = @"TBMS3Bucket";
NSString * const S3_ACCESS_KEY = @"TBMS3AccessKey";
NSString * const S3_SECRET_KEY = @"TBMS3SecretKey";

@implementation TBMS3CredentialsManager

+ (void) refreshFromServer:(void (^)(BOOL))completionHandler{
    OB_INFO(@"getS3Credentials");
    
    
    [ZZCommonNetworkTransportService s3]
    
    
    
    
    
    [[TBMHttpManager manager] GET:@"s3_credentials/info"
                        parameters:nil
                           success:^(AFHTTPRequestOperation *operation, id responseObject) {
                               if (![self validateServerResponse:responseObject]){
                                   if (completionHandler != nil)
                                       completionHandler(NO);
                                   return;
                               }
                               [self storeS3CredentialsInKeychain:responseObject];
                               if (completionHandler != nil)
                                   completionHandler(YES);
                           }
                           failure:^(AFHTTPRequestOperation *operation, NSError *error){
                               OB_WARN(@"Attempt to get s3 credentials failed.");
                               if (completionHandler != nil)
                                   completionHandler(NO);
                           }];
}

+ (NSMutableDictionary *) credentials
{
    NSMutableDictionary *c = [NSMutableDictionary dictionary];
    NSString *v;
    
    v = [TBMKeyChainWrapper getItem:S3_REGION_KEY];
    if (v == nil){
        OB_ERROR(@"S3CredentialsManager: credentials: got nil from keychain for S3_REGION_KEY. This should never happen");
        return nil;
    }
    c[S3_REGION_KEY] = v;
    
    v = [TBMKeyChainWrapper getItem:S3_BUCKET_KEY];
    if (v == nil){
        OB_ERROR(@"S3CredentialsManager: credentials: got nil from keychain for S3_BUCkET_KEY. This should never happen");
        return nil;
    }
    c[S3_BUCKET_KEY] = v;
    
    v = [TBMKeyChainWrapper getItem:S3_ACCESS_KEY];
    if (v == nil){
        OB_ERROR(@"S3CredentialsManager: credentials: got nil from keychain for S3_ACCESS_KEY. This should never happen");
        return nil;
    }
    c[S3_ACCESS_KEY] = v;
    
    v = [TBMKeyChainWrapper getItem:S3_SECRET_KEY];
    if (v == nil){
        OB_ERROR(@"S3CredentialsManager: credentials: got nil from keychain for S3_SECRET_KEY. This should never happen");
        return nil;
    }
    c[S3_SECRET_KEY] = v;
    
    return c;
}

+ (void) storeS3CredentialsInKeychain:(NSDictionary *)resp{
    [TBMKeyChainWrapper putItem:S3_REGION_KEY value:resp[SERVER_PARAMS_S3_REGION_KEY]];
    [TBMKeyChainWrapper putItem:S3_BUCKET_KEY value:resp[SERVER_PARAMS_S3_BUCKET_KEY]];
    [TBMKeyChainWrapper putItem:S3_ACCESS_KEY value:resp[SERVER_PARAMS_S3_ACCESS_KEY]];
    [TBMKeyChainWrapper putItem:S3_SECRET_KEY value:resp[SERVER_PARAMS_S3_SECRET_KEY]];
}

+ (BOOL) validateServerResponse:(NSDictionary *)resp{
    if ([TBMHttpManager isFailure:resp]){
        OB_ERROR(@"S3CredentialsManager: refreshFromServer: Server Error. This should never happen: %@", resp);
        return NO;
    }
    
    if (resp[SERVER_PARAMS_S3_REGION_KEY] == nil){
        OB_ERROR(@"S3CredentialsManager: refreshFromServer: Got nil region. This should never happen: %@", resp);
        return NO;
    }
    
    if (resp[SERVER_PARAMS_S3_BUCKET_KEY] == nil){
        OB_ERROR(@"S3CredentialsManager: refreshFromServer: Got nil bucket. This should never happen: %@", resp);
        return NO;
    }
    
    if (resp[SERVER_PARAMS_S3_ACCESS_KEY] == nil){
        OB_ERROR(@"S3CredentialsManager: refreshFromServer: Got nil access_key. This should never happen: %@", resp);
        return NO;
    }
    
    if (resp[SERVER_PARAMS_S3_SECRET_KEY] == nil){
        OB_ERROR(@"S3CredentialsManager: refreshFromServer: Got nil secret_key. This should never happen: %@", resp);
        return NO;
    }
    
    return YES;
}
@end
