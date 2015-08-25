//
//  ZZAccountTransportService.h
//  Zazo
//
//  Created by ANODA on 8/11/15.
//  Copyright (c) 2015 ANODA. All rights reserved.
//

@class ZZUserDomainModel;

@interface ZZAccountTransportService : NSObject

+ (RACSignal*)registerUserWithModel:(ZZUserDomainModel *)user;
+ (RACSignal*)registerUserFromModel:(ZZUserDomainModel *)user withVerificationCode:(NSString *)code;

@end
