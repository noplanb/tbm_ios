//
//  ZZAuthInteractorIO.h
//  Zazo
//
//  Created by ANODA on 1/12/15.
//  Copyright (c) 2015 ANODA. All rights reserved.
//

@protocol ZZAuthInteractorInput <NSObject>

- (void)registrationWithFirstName:(NSString *)firstfName
                     withLastName:(NSString *)lastName
                  withCountryCode:(NSString *)countryCode
                  withPhoneNumber:(NSString *)phoneNumber;

- (void)continueRegistrationWithSMSCode:(NSString *)code;

@end


@protocol ZZAuthInteractorOutput <NSObject>

- (void)validationDidFailWithError:(NSError*)error;
- (void)smsCodeValidationCompletedWithError:(NSError*)error;

- (void)authDataRecievedForNumber:(NSString*)phonenumber;
- (void)presentGridModule;

@end