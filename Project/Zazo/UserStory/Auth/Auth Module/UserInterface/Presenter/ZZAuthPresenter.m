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
#import "TBMAlertController.h"

@interface ZZAuthPresenter ()

@end

@implementation ZZAuthPresenter

- (void)configurePresenterWithUserInterface:(UIViewController<ZZAuthViewInterface>*)userInterface
{
    self.userInterface = userInterface;
    [self.interactor loadUserData];
}

#pragma mark - Module Interface

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

- (void)requestCall
{
    [self.interactor userRequestCallInsteadSmsCode];
}

- (void)verifySMSCode:(NSString*)code
{
    [self.userInterface updateStateToLoading:YES message:@"Checking verification code.."];
    [self.interactor validateSMSCode:code];
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
    [self.userInterface updateStateToLoading:YES message:@"Sending verification code..."];
}

- (void)registrationCompletedSuccessfullyWithPhoneNumber:(NSString*)phoneNumber
{
    [self.userInterface updateStateToLoading:NO message:nil];
    ANDispatchBlockToMainQueue(^{
        [self.userInterface showVerificationCodeInputViewWithPhoneNumber:phoneNumber];
    });
}

- (void)registrationDidFailWithError:(NSError *)error
{
    [self.userInterface updateStateToLoading:NO message:nil];
    [ZZErrorHandler showErrorAlertWithLocalizedTitle:@"Try Again" // TODO: localization
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
}

- (void)userRequestCallInsteadSmsCode
{
    [self.interactor userRequestCallInsteadSmsCode];
}

- (void)callRequestCompletedSuccessfully
{
    // TODO: check if we need some UI update here
}

- (void)callRequestDidFailWithError:(NSError *)error
{
    // TODO: check if we need some UI update here, connect supprt with fails not by internet connection
}

- (void)loadedFriendsSuccessfully
{
    // TODO:
}

- (void)loadFriendsDidFailWithError:(NSError *)error
{
    TBMAlertController *alert = [TBMAlertController badConnectionAlert];
    [alert addAction:[SDCAlertAction actionWithTitle:@"Try Again" style:SDCAlertActionStyleDefault handler:^(SDCAlertAction *action) {
        [self.interactor loadFriends];
    }]];
    ANDispatchBlockToMainQueue(^{
       [alert presentWithCompletion:nil]; 
    });
}

- (void)loadedS3CredentialsSuccessfully
{
    //TODO:
}

- (void)loadS3CredentialsDidFailWithError:(NSError *)error
{
    ANDispatchBlockToMainQueue(^{
        NSString* appName = [[NSBundle mainBundle] infoDictionary][@"CFBundleDisplayName"];
        NSString* badConnectiontitle = [NSString stringWithFormat:@"Unable to reach %@ please check your Internet connection and try again.", [NSObject an_safeString:appName]];
        
        UIAlertView *av = [[UIAlertView alloc]
                           initWithTitle:@"Bad Connection"
                           message:badConnectiontitle
                           delegate:nil
                           cancelButtonTitle:@"Try Again"
                           otherButtonTitles:nil];
        
        [av.rac_buttonClickedSignal subscribeNext:^(id x) {
            [self.interactor loadS3Credentials];
        }];
        [av show];
    });
}

- (void)registrationFlowCompletedSuccessfully
{
    [self.wireframe presentGridController];
}

@end
