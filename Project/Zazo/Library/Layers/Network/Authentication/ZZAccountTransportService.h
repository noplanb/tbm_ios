//
//  ZZAccountTransportService.h
//  Zazo
//
//  Created by ANODA on 8/11/15.
//  Copyright (c) 2015 ANODA. All rights reserved.
//

@class ZZUserDomainModel;

@interface ZZAccountTransportService : NSObject

+ (RACSignal*)registerUserWithModel:(ZZUserDomainModel*)user shouldForceCall:(BOOL)shouldForceCall;

+ (RACSignal*)verifySMSCodeWithUserModel:(ZZUserDomainModel*)user code:(NSString*)code;

@end
