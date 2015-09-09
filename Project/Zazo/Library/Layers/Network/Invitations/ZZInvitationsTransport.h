//
//  ZZInvitationsTransport.h
//  Zazo
//
//  Created by ANODA on 9/9/15.
//  Copyright (c) 2015 No Plan B. All rights reserved.
//

@interface ZZInvitationsTransport : NSObject

+ (RACSignal*)checkIfAnInvitedUserHasAppWithParameters:(NSDictionary*)parameters;
+ (RACSignal*)inviteUserWithParameters:(NSDictionary*)parameters;


@end
