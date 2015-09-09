//
//  ZZInvitationsTransportService.h
//  Zazo
//
//  Created by ANODA on 9/9/15.
//  Copyright (c) 2015 No Plan B. All rights reserved.
//

@interface ZZInvitationsTransportService : NSObject

+ (RACSignal*)checkIfAnInvitedUserHasApp:(NSString*)phoneNumber;
+ (RACSignal*)inviteUserWithPhoneNumber:(NSString*)phoneNumber
                              firstName:(NSString*)firstName
                            andLastName:(NSString*)lastName;

@end
