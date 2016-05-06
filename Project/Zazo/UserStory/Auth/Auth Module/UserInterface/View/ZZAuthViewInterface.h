//
//  ZZAuthViewInterface.h
//  Zazo
//
//  Created by ANODA on 1/12/15.
//  Copyright (c) 2015 ANODA. All rights reserved.
//

@protocol ZZAuthViewInterface <NSObject>

- (void)showVerificationCodeInputViewWithPhoneNumber:(NSString *)phoneNumber;
- (void)hideVerificationCodeInputView:(ANCodeBlock)completion;

- (void)updateStateToLoading:(BOOL)isLoading message:(NSString*)message;

- (void)updateFirstName:(NSString*)firstName lastName:(NSString*)lastName;
- (void)updateCountryCode:(NSString*)countryCode phoneNumber:(NSString*)phoneNumber;

- (void)enableLogoTapRecognizer;

@end
