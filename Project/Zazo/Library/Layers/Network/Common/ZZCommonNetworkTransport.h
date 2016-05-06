//
//  ZZCommonNetworkTransport.h
//  Zazo
//
//  Created by ANODA on 8/11/15.
//  Copyright (c) 2015 ANODA. All rights reserved.
//

@interface ZZCommonNetworkTransport : NSObject

+ (RACSignal *)logMessageWithParameters:(NSDictionary *)parameters;

+ (RACSignal *)checkApplicationVersionWithParameters:(NSDictionary *)parameters;

+ (RACSignal *)loadS3Credentials;

+ (void)setupNetworkCredentials;

@end
