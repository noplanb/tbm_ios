//
//  ZZAuthVC.m
//  Zazo
//
//  Created by ANODA on 1/3/15.
//  Copyright (c) 2015 ANODA. All rights reserved.
//

#import "ZZAuthVC.h"
#import "ZZAuthContentView.h"
#import "ZZKeyboardObserver.h"
#import "ZZTextFieldsDelegate.h"
#import "NSObject+ANSafeValues.h"
#import "TBMVerificationAlertHandler.h"

@interface ZZAuthVC ()<ZZKeyboardObserverProtocol, TBMVerificationAlertDelegate>

@property (nonatomic, strong) ZZAuthContentView* contentView;
@property (nonatomic, strong) ZZKeyboardObserver* keyboardObserver;
@property (nonatomic, strong) NSNumber* animationDuration;
@property (nonatomic, strong) ZZTextFieldsDelegate* textFieldDelegate;

@end

@implementation ZZAuthVC

- (instancetype)init
{
    if (self = [super init])
    {
        self.contentView = [ZZAuthContentView new];
        self.keyboardObserver = [[ZZKeyboardObserver alloc] initWithDelegate:self];
        self.textFieldDelegate = [ZZTextFieldsDelegate new];
        
        ZZAuthRegistrationView* view = self.contentView.registrationView;
        
        [self.textFieldDelegate addTextFieldsWithArray:@[view.firstNameTextField,
                                                         view.lastNameTextField,
                                                         view.phoneCodeTextField,
                                                         view.phoneNumberTextField]];
        
        
        self.contentView.registrationView.signInButton.rac_command = [RACCommand commandWithBlock:^{
            
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

- (void)dealloc
{
    [self.keyboardObserver removeKeyboardNotification];
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
       
        view.firstNameTextField.text = [NSObject an_safeString:firstName];
        view.lastNameTextField.text = [NSObject an_safeString:lastName];
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
    
    
    
    
//    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:phoneNumber
//                                                    message:@"Enter verification code:"
//                                                   delegate:self
//                                          cancelButtonTitle:@"Cancel"
//                                          otherButtonTitles:@"Verify", nil];
//    alert.alertViewStyle = UIAlertViewStylePlainTextInput;
//    [alert show];
//    
//    @weakify(alert);
//    [alert.rac_buttonClickedSignal subscribeNext:^(NSNumber* x) {
//        
//        @strongify(alert);
//        if ([x integerValue] == 1)
//        {
//            NSString *code = [alert textFieldAtIndex:0].text;
//            if (!ANIsEmptyStringByTrimmingWhitespaces(code))
//            {
//                [self.eventHandler verifySMSCode:code];
//            }
//        }
//    }];
//    
//#ifdef DEBUG_LOGIN_USER
//    UITextField *textField = [alert textFieldAtIndex:0];
//    textField.text = @"0000";
//#endif
}

- (void)didEnterVerificationCode:(NSString*)code
{
    [self.eventHandler verifySMSCode:code];
}

- (void)didTapCallMe
{
    [self.eventHandler requestCall];
}


#pragma mark - Keyboard observer

- (void)keyboardChangeFrameWithAnimationDuration:(NSNumber*)animationDuration
                              withKeyboardHeight:(CGFloat)keyboardHeight
                               withKeyboardFrame:(CGRect)keyboarFrame
{
    self.animationDuration = animationDuration;
    if (CGRectIntersectsRect(self.contentView.registrationView.phoneNumberTextField.frame, keyboarFrame))
    {
        CGRect intersectionFrame =  CGRectIntersection(self.contentView.registrationView.signInButton.frame, keyboarFrame);
        [self changeRegistartionViewPositionWithKeyboardHeight:(CGRectGetHeight(intersectionFrame) + CGRectGetHeight(self.contentView.registrationView.phoneNumberTextField.frame))];
    }
    
    if (CGRectIntersectsRect(self.contentView.registrationView.signInButton.frame, keyboarFrame))
    {
        self.contentView.registrationScrollBottomConstraint.offset = -keyboardHeight;
        self.contentView.scrollView.scrollEnabled = YES;
    }
    else
    {
        self.contentView.registrationScrollBottomConstraint.offset = 0;
        self.contentView.scrollView.scrollEnabled = NO;
    }
}

- (void)keyboardWillHide
{
    [self scrollDownRegistrationView];
}

- (void)changeRegistartionViewPositionWithKeyboardHeight:(CGFloat)keyboardHeight
{
    [UIView animateWithDuration:[self.animationDuration doubleValue] animations:^{
       
        self.contentView.registrationScrollBottomConstraint.offset = -keyboardHeight / 2;
        [self.view layoutIfNeeded];
    } completion:^(BOOL finished) {
        
        self.contentView.scrollView.scrollEnabled = YES;
//        [self.contentView scrollToBottom];
    }];
}

- (void)scrollDownRegistrationView
{
    [UIView animateWithDuration:[self.animationDuration doubleValue] animations:^{
        
        self.contentView.registrationScrollBottomConstraint.offset = 0;
        [self.view layoutIfNeeded];
    } completion:^(BOOL finished) {
        
        self.contentView.scrollView.scrollEnabled = NO;
    }];
}

@end
