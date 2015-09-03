//
//  ZZAuthPresenter.m
//  Zazo
//
//  Created by ANODA on 1/11/15.
//  Copyright (c) 2015 ANODA. All rights reserved.
//

#import "ZZAuthPresenter.h"
#import "ZZErrorHandler.h"
#import "ZZUserDomainModel.h"

@interface ZZAuthPresenter ()

@end

@implementation ZZAuthPresenter

- (void)configurePresenterWithUserInterface:(UIViewController<ZZAuthViewInterface>*)userInterface
{
    self.userInterface = userInterface;
    [self.interactor loadUserData];
}

- (void)registrationWithFirstName:(NSString*)firstName
                         lastName:(NSString*)lastName
                      countryCode:(NSString*)countryCode
                            phone:(NSString*)phoneNumber
{
    ZZUserDomainModel* model = [ZZUserDomainModel new];
    model.firstName = firstName;
    model.lastName = lastName;
    model.countryCode = countryCode;
    model.plainPhoneNumber = phoneNumber;
    
    [self.interactor registerUser:model];
}


#pragma mark - Output

- (void)userDataLoadedSuccessfully:(ZZUserDomainModel*)user
{
    [self.userInterface updateFirstName:user.firstName lastName:user.lastName];
    [self.userInterface updateCountryCode:user.countryCode phoneNumber:user.plainPhoneNumber];
}

- (void)validationDidFailWithError:(NSError *)error
{
    [ZZErrorHandler showAlertWithError:error];
}

- (void)validationCompletedSuccessfully
{
    [self.userInterface updateStateToLoading:YES message:@"Sending SMS Code..."];
}

- (void)registrationCompletedSuccessfullyWithPhoneNumber:(NSString *)phoneNumber
{
    [self.userInterface updateStateToLoading:NO message:nil];
    ANDispatchBlockToMainQueue(^{
        [self.userInterface showVerificationCodeInputViewWithPhoneNumber:phoneNumber];
    });
}

- (void)registrationDidFailWithError:(NSError *)error
{
    [self.userInterface updateStateToLoading:NO message:nil];
    [ZZErrorHandler showErrorAlertWithLocalizedTitle:@"Try Again" // TODO: local
                                             message:@"Bad Connection"];
}

- (void)smsCodeValidationCompletedWithError:(NSError*)error
{
    [self.userInterface updateStateToLoading:NO message:nil];
    
    //TODO: separate errors with server invalid code error + bad connection and other
    
    [ZZErrorHandler showErrorAlertWithLocalizedTitle:@"auth-controller.bad-code.alert.title"
                                             message:@"auth-controller.bad-code.alert.text"];
}

- (void)smsCodeValidationCompletedSuccessfully
{
    [self.userInterface updateStateToLoading:NO message:nil];
    [self.wireframe presentGridController];
}

- (void)userRequestCallExtendSmsCode
{
    [self.interactor userRequestCallExtendSmsCode];
}

- (void)callRequestCompletedSuccessfully
{
    // TODO: check if we need some UI update here
}

- (void)callRequestDidFailWithError:(NSError *)error
{
    // TODO: check if we need some UI update here, connect supprt with fails not by internet connection
}

#pragma mark - Module Interface

- (void)verifySMSCode:(NSString*)code
{
    [self.userInterface updateStateToLoading:YES message:@"Checking SMS code..."];
    [self.interactor validateSMSCode:code];
}

@end
