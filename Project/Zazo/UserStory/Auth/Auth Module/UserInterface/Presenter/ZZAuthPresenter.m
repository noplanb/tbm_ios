//
//  ZZAuthPresenter.m
//  Zazo
//
//  Created by ANODA on 1/11/15.
//  Copyright (c) 2015 ANODA. All rights reserved.
//

#import "ZZAuthPresenter.h"
#import "ZZErrorHandler.h"

@interface ZZAuthPresenter ()

@end

@implementation ZZAuthPresenter

- (void)configurePresenterWithUserInterface:(UIViewController<ZZAuthViewInterface>*)userInterface
{
    self.userInterface = userInterface;
}

- (void)registrationWithFirstName:(NSString*)firstName
                         lastName:(NSString*)lastName
                      countryCode:(NSString*)countryCode
                            phone:(NSString*)phoneNumber
{
    [self.interactor registrationWithFirstName:firstName lastName:lastName countryCode:countryCode phone:phoneNumber];
}


#pragma mark - Output

- (void)validationDidFailWithError:(NSError*)error
{
    [ZZErrorHandler showAlertWithError:error];
}

- (void)authDataRecievedForNumber:(NSString*)phonenumber
{
    ANDispatchBlockToMainQueue(^{
        [self.userInterface showVerificationCodeInputViewWithPhoneNumber:phonenumber];
    });
}

- (void)smsCodeValidationCompletedWithError:(NSError*)error
{
    [ZZErrorHandler showErrorAlertWithLocalizedTitle:@"auth-controller.bad-code.alert.title"
                                             message:@"auth-controller.bad-code.alert.text"];
}

- (void)presentGridModule
{
    [self.wireframe presentGridModule];
}

#pragma mark - Module Interface

- (void)verifySMSCode:(NSString*)code
{
    [self.interactor validateSMSCode:code];
}

@end
