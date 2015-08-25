//
//  ZZAuthPresenter.m
//  Zazo
//
//  Created by ANODA on 1/11/15.
//  Copyright (c) 2015 ANODA. All rights reserved.
//

#import "ZZAuthPresenter.h"

@interface ZZAuthPresenter ()

@end

@implementation ZZAuthPresenter

- (void)configurePresenterWithUserInterface:(UIViewController<ZZAuthViewInterface>*)userInterface
{
    self.userInterface = userInterface;
}


- (void)registrationFilledWithFirstName:(NSString *)firstName
                           withLastName:(NSString *)lastName
                        withCountryCode:(NSString *)countryCode
                        withPhoneNumber:(NSString *)phoneNumber
{
    [self.interactor registrationWithFirstName:firstName
                                  withLastName:lastName
                               withCountryCode:countryCode
                               withPhoneNumber:phoneNumber];
}


#pragma mark - Output

- (void)validationDidFailWithError:(NSError *)error
{
    [self showAlertMessage:error.localizedDescription];
}

- (void)authDataRecievedForNumber:(NSString *)phonenumber
{
    ANDispatchBlockToMainQueue(^{
        [self.userInterface showVerificationCodeInputViewWithPhoneNumber:phonenumber];
    });
}

- (void)showAlertMessage:(NSString *)messge
{
    [[[UIAlertView alloc] initWithTitle:nil
                                message:messge
                               delegate:nil
                      cancelButtonTitle:@"Ok"
                      otherButtonTitles:nil, nil] show];
}

- (void)presentGridModule
{
    [self.wireframe presentGridModule];
}

#pragma mark - Module Interface

- (void)verifySMSCode:(NSString *)code
{
    [self.interactor continueRegistrationWithSMSCode:code];
}



@end
