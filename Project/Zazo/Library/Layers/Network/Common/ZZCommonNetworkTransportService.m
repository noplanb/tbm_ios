//
//  ZZCommonNetworkTransportService.m
//  Zazo
//
//  Created by ANODA on 8/11/15.
//  Copyright (c) 2015 ANODA. All rights reserved.
//

#import "ZZCommonNetworkTransportService.h"
#import "ZZCommonNetworkTransport.h"
#import "NSString+ANAdditions.h"
#import "ZZKeychainDataProvider.h"
#import "FEMObjectDeserializer.h"
#import "ZZS3CredentialsDomainModel.h"

@implementation ZZCommonNetworkTransportService

+ (RACSignal *)logMessage:(NSString *)message
{
    NSString *version = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];

    NSDictionary *parameters = @{@"msg" : [NSObject an_safeString:message],
            @"device_model" : [NSObject an_safeString:[[UIDevice currentDevice] model]],
            @"os_version" : [NSObject an_safeString:[[UIDevice currentDevice] systemVersion]],
            @"zazo_version" : [NSObject an_safeString:version],
            @"zazo_version_number" : [NSObject an_safeString:kGlobalApplicationVersion]};

    return [ZZCommonNetworkTransport logMessageWithParameters:parameters];
}

+ (RACSignal *)checkApplicationVersion
{
    NSDictionary *parameters = @{@"device_platform" : @"ios",
            @"version" : @([kGlobalApplicationVersion integerValue])};
    return [ZZCommonNetworkTransport checkApplicationVersionWithParameters:parameters];
}

+ (RACSignal *)loadS3Credentials
{
    return [RACSignal createSignal:^RACDisposable *(id <RACSubscriber> subscriber) {

        ZZLogInfo(@"s3 credentials start updating");

        [[ZZCommonNetworkTransport loadS3Credentials] subscribeNext:^(id x) {

            FEMObjectMapping *mapping = [ZZS3CredentialsDomainModel mapping];
            ZZS3CredentialsDomainModel *model = [FEMObjectDeserializer deserializeObjectExternalRepresentation:x
                                                                                                  usingMapping:mapping];
            if ([model isValid])
            {
                [ZZKeychainDataProvider updateWithCredentials:model];
                [subscriber sendNext:model];
            }
            else
            {
                [subscriber sendError:nil]; // TODO: credentials not valid
            }

        }                                                     error:^(NSError *error) {

            [subscriber sendError:error];
        }];

        return [RACDisposable disposableWithBlock:^{
        }];
    }];
}

@end
