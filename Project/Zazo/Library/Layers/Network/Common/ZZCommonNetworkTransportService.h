//
//  ZZCommonNetworkTransportService.h
//  Zazo
//
//  Created by ANODA on 8/11/15.
//  Copyright (c) 2015 ANODA. All rights reserved.
//

@interface ZZCommonNetworkTransportService : NSObject

+ (RACSignal*)logMessage:(NSString*)message;
+ (RACSignal*)checkApplicationVersion;
+ (RACSignal*)loadS3Credentials;

@end

