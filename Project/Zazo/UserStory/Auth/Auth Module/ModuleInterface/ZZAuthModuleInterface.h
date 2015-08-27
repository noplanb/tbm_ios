//
//  ZZAuthModuleInterface.h
//  Zazo
//
//  Created by ANODA on 1/12/15.
//  Copyright (c) 2015 ANODA. All rights reserved.
//

@protocol ZZAuthModuleInterface <NSObject>

- (void)registrationFilledWithFirstName:(NSString*)firstName
                           withLastName:(NSString*)lastName
                        withCountryCode:(NSString*)countryCode
                        withPhoneNumber:(NSString*)phoneNumber;

- (void)verifySMSCode:(NSString *)code;

@end
