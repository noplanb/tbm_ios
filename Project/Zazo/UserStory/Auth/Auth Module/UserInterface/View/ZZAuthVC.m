//
//  ZZAuthVC.m
//  Zazo
//
//  Created by ANODA on 1/3/15.
//  Copyright (c) 2015 ANODA. All rights reserved.
//

#import "ZZAuthVC.h"
#import "ZZAuthContentView.h"
#import "ZZTextFieldsDelegate.h"
#import "NSObject+ANSafeValues.h"
#import "TBMVerificationAlertHandler.h"

@interface ZZAuthVC ()<TBMVerificationAlertDelegate>

@property (nonatomic, strong) ZZAuthContentView* contentView;
@property (nonatomic, strong) NSNumber* animationDuration;
@property (nonatomic, strong) ZZTextFieldsDelegate* textFieldDelegate;
@property (nonatomic, assign) BOOL isKeyboardShown;

@end

@implementation ZZAuthVC

- (instancetype)init
{
    if (self = [super init])
    {
        self.contentView = [ZZAuthContentView new];
        self.textFieldDelegate = [ZZTextFieldsDelegate new];
        
        ZZAuthRegistrationView* view = self.contentView.registrationView;
        
        [self.textFieldDelegate addTextFieldsWithArray:@[view.firstNameTextField,
                                                         view.lastNameTextField,
                                                         view.phoneCodeTextField,
                                                         view.phoneNumberTextField]];
        
        
        self.contentView.registrationView.signInButton.rac_command = [RACCommand commandWithBlock:^{
            
            ANDispatchBlockToMainQueue(^{
                [self.view endEditing:YES];
            });
            [self.eventHandler registrationWithFirstName:view.firstNameTextField.text
                                                lastName:view.lastNameTextField.text
                                             countryCode:view.phoneCodeTextField.text
                                                   phone:view.phoneNumberTextField.text];
        }];
    }
    return self;
}

- (void)loadView
{
    self.view = self.contentView;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [UIApplication sharedApplication].statusBarHidden = YES;
    
    self.view.backgroundColor = [ZZColorTheme shared].authBackgroundColor;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [[self navigationController] setNavigationBarHidden:YES animated:YES];
}

- (void)updateFirstName:(NSString*)firstName lastName:(NSString*)lastName
{
    ZZAuthRegistrationView* view = self.contentView.registrationView;
    ANDispatchBlockToMainQueue(^{
       
#ifdef DEBUG
        view.firstNameTextField.text = @"DEBUG";
#else
    #ifdef RELEASE
        view.firstNameTextField.text = @"RELEASE";
    #else
        view.firstNameTextField.text = @"AD-HOC";
    #endif
#endif
        
//        view.firstNameTextField.text = [NSObject an_safeString:firstName];
//        view.lastNameTextField.text = [NSObject an_safeString:lastName];
    });
}

- (void)updateCountryCode:(NSString*)countryCode phoneNumber:(NSString*)phoneNumber
{
    ZZAuthRegistrationView* view = self.contentView.registrationView;
    ANDispatchBlockToMainQueue(^{
        
        view.phoneCodeTextField.text = [NSObject an_safeString:countryCode];
        view.phoneNumberTextField.text = [NSObject an_safeString:phoneNumber];
    });
}

- (void)showVerificationCodeInputViewWithPhoneNumber:(NSString*)phoneNumber
{
    [[[TBMVerificationAlertHandler alloc] initWithPhoneNumber:phoneNumber
                                                     delegate:self] presentAlert];
}

- (void)didEnterVerificationCode:(NSString*)code
{
    [self.eventHandler verifySMSCode:code];
}

- (void)didTapCallMe
{
    [self.eventHandler requestCall];
}

@end
