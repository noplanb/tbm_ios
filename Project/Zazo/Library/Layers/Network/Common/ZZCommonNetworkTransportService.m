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

@implementation ZZCommonNetworkTransportService

+ (RACSignal*)logMessage:(NSString*)message
{
    NSString* version = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
    NSString* buildNumber = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleVersion"];
    
    NSDictionary* parameters = @{@"msg"                 : [NSObject an_safeString:message],
                                 @"device_model"        : [NSObject an_safeString:[[UIDevice currentDevice] model]],
                                 @"os_version"          : [NSObject an_safeString:[[UIDevice currentDevice] systemVersion]],
                                 @"zazo_version"        : [NSObject an_safeString:version],
                                 @"zazo_version_number" : [NSObject an_safeString:buildNumber]};
    
    return [ZZCommonNetworkTransport logMessageWithParameters:parameters];
}

+ (RACSignal*)checkApplicationVersion
{
    NSString* version = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleVersion"];
    version = [NSObject an_safeString:[version an_stripAllNonNumericCharacters]];
    NSDictionary* parameters = @{@"device_platform": @"ios",
                                 @"version": @([version integerValue])};
    return [ZZCommonNetworkTransport checkApplicationVersionWithParameters:parameters];
}

+ (RACSignal*)loadS3Credentials
{
    return [ZZCommonNetworkTransport loadS3Credentials];
}

@end
