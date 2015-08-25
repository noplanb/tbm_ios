//
//  ZZAuthenticationTransport.h
//  Zazo
//
//  Created by ANODA on 8/11/15.
//  Copyright (c) 2015 ANODA. All rights reserved.
//

@interface ZZAccountTransport : NSObject

+ (RACSignal *)registerUserWithParameters:(NSDictionary*)parameters;
+ (RACSignal *)verifyCodeWithParameters:(NSDictionary*)parameters;

@end
