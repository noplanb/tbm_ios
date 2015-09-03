//
//  ZZAuthModuleInterface.h
//  Zazo
//
//  Created by ANODA on 1/12/15.
//  Copyright (c) 2015 ANODA. All rights reserved.
//

@protocol ZZAuthModuleInterface <NSObject>

- (void)registrationWithFirstName:(NSString*)firstName
                         lastName:(NSString*)lastName
                      countryCode:(NSString*)countryCode
                            phone:(NSString*)phoneNumber;

- (void)verifySMSCode:(NSString*)code;

@end
