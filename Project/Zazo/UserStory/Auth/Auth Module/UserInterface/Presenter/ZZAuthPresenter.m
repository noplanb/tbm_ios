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
#import "ZZAlertController.h"
#import "ZZAuthInteractorConstants.h"
#import "RollbarReachability.h"

@interface ZZAuthPresenter ()

@property (nonatomic, strong) RollbarReachability* reachability;

@end

@implementation ZZAuthPresenter

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        self.reachability = [RollbarReachability reachabilityForInternetConnection];
    }
    
    return self;
}

- (void)configurePresenterWithUserInterface:(UIViewController<ZZAuthViewInterface>*)userInterface
{
    self.userInterface = userInterface;
    [self.interactor loadUserData];
    
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"debug_enabled"])
    {
        [self.userInterface enableLogoTapRecognizer];
    }
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

- (void)handleLogoTap
{
    static NSUInteger tapCount;
    
    tapCount++;
    
    if (tapCount > 3)
    {
        [self.wireframe showSecretScreen];
    }
}

#pragma mark - Output

- (BOOL)isNetworkEnabled
{
    return [self.reachability isReachable];
}

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
        
        #ifdef DEBUG_LOGIN_USER
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self.interactor validateSMSCode:@"0000"];
        });
        #endif
    });
}

- (void)registrationDidFailWithError:(NSError *)error
{
    [self.userInterface updateStateToLoading:NO message:nil];
    
    if (error.code == kErrorWrongMobileErrorCode)
    {
        [ZZErrorHandler showErrorAlertWithLocalizedTitle:NSLocalizedString(@"auth-error.bad.mobile.number.title", nil)
                                                 message:NSLocalizedString(@"auth-error.bad.phone.number.type.message", nil)];
    }
    else
    {
        [ZZErrorHandler showErrorAlertWithLocalizedTitle:NSLocalizedString(@"auth-error.try.again.title", nil)
                                             message:NSLocalizedString(@"auth-error.bad.connection.message", nil)];
    }
}

- (void)smsCodeValidationCompletedWithError:(NSError*)error
{
    [self.userInterface updateStateToLoading:NO message:nil];
    
    //TODO: separate errors with server invalid code error + bad connection and other
    
    if ([self isNetworkEnabled] && ![self _isServerConnectionError:error])
    {
        [ZZErrorHandler showErrorAlertWithLocalizedTitle:@"auth-controller.bad-code.alert.title"
                                                 message:@"auth-controller.bad-code.alert.text"];
    }
    else
    {
        [ZZErrorHandler showErrorAlertWithLocalizedTitle:NSLocalizedString(@"auth-error.try.again.title", nil)
                                                 message:NSLocalizedString(@"auth-error.bad.connection.message", nil)];
    }
    
}

- (BOOL)_isServerConnectionError:(NSError*)error
{
    return (error.code == kErrorServerConnectionErrorCode);
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
    [self.userInterface hideVerificationCodeInputView:^{
        [self smsCodeValidationCompletedWithError:error];
    }];
}

- (void)loadedFriendsSuccessfully
{
    // TODO:
}

- (void)loadFriendsDidFailWithError:(NSError *)error
{
    ZZAlertController *alert = [ZZAlertController badConnectionAlert];
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

- (void)registrationFlowCompletedSuccessfully
{
#ifdef NETTEST
        [self.wireframe presentNetworkTestController];
#else
        [self.wireframe presentGridController];
#endif
}

@end
