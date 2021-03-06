//
//  ZZAuthInteractorIO.h
//  Zazo
//
//  Created by ANODA on 1/12/15.
//  Copyright (c) 2015 ANODA. All rights reserved.
//

@class ZZUserDomainModel;

@protocol ZZAuthInteractorInput <NSObject>

- (void)loadUserData;

- (void)registerUser:(ZZUserDomainModel *)model;

- (void)validateSMSCode:(NSString *)code;

- (void)userRequestCallInsteadSmsCode;

- (void)loadFriends;

@end


@protocol ZZAuthInteractorOutput <NSObject>

- (void)userDataLoadedSuccessfully:(ZZUserDomainModel *)user;

- (void)validationCompletedSuccessfully;

- (void)validationDidFailWithError:(NSError *)error;

- (void)registrationCompletedSuccessfullyWithPhoneNumber:(NSString *)phoneNumber;

- (void)registrationDidFailWithError:(NSError *)error;

- (void)smsCodeValidationCompletedWithError:(NSError *)error;

- (void)smsCodeValidationCompletedSuccessfully;

- (void)callRequestCompletedSuccessfully;

- (void)callRequestDidFailWithError:(NSError *)error;

- (void)loadedFriendsSuccessfully;

- (void)loadFriendsDidFailWithError:(NSError *)error;

- (void)loadedS3CredentialsSuccessfully;

- (void)registrationFlowCompletedSuccessfully;

- (BOOL)isNetworkEnabled;

@end
