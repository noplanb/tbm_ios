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

@interface ZZAuthVC () <ZZKeyboardObserverProtocol>

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
        [self.textFieldDelegate addTextFieldsWithArray:@[self.contentView.registrationView.firstNameTextField,
                                                         self.contentView.registrationView.lastNameTextField,
                                                         self.contentView.registrationView.phoneCodeTextField,
                                                         self.contentView.registrationView.phoneNumberTextField]];
        @weakify(self);
        [[self.contentView.registrationView.signInButton rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
            @strongify(self);
            [self.eventHandler registrationFilledWithFirstName:self.contentView.registrationView.firstNameTextField.text
                                                  withLastName:self.contentView.registrationView.lastNameTextField.text
                                               withCountryCode:self.contentView.registrationView.phoneCodeTextField.text
                                               withPhoneNumber:self.contentView.registrationView.phoneNumberTextField.text];
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
}

- (void)showVerificationCodeInputViewWithPhoneNumber:(NSString *)phoneNumber
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:phoneNumber
                                                    message:@"Enter verification code:"
                                                   delegate:self
                                          cancelButtonTitle:@"Cancel"
                                          otherButtonTitles:@"Verify", nil];
    alert.alertViewStyle = UIAlertViewStylePlainTextInput;
    [alert show];
}

#pragma mark - Keyboard observer

- (void)keyboardChangeFrameWithAnimationDuration:(NSNumber *)animationDuration
                              withKeyboardHeight:(CGFloat)keyboardHeight
                               withKeyboardFrame:(CGRect)keyboarFrame
{
    self.animationDuration = animationDuration;
    if (CGRectIntersectsRect(self.contentView.registrationView.phoneNumberTextField.frame, keyboarFrame))
    {
        CGRect intersectionFrame =  CGRectIntersection(self.contentView.registrationView.signInButton.frame, keyboarFrame);
        [self chagneRegistartionViewPositionWithKeyboardHeight:(CGRectGetHeight(intersectionFrame) + CGRectGetHeight(self.contentView.registrationView.phoneNumberTextField.frame))];
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
    [self downRegistrationView];
}

- (void)chagneRegistartionViewPositionWithKeyboardHeight:(CGFloat)keyboardHeight
{
    [UIView animateWithDuration:[self.animationDuration doubleValue] animations:^{
        self.contentView.registrationScrollBottomConstraint.offset = -keyboardHeight;
        [self.view layoutIfNeeded];
    } completion:^(BOOL finished) {
        self.contentView.scrollView.scrollEnabled = YES;
        [self.contentView scrollToBottom];
    }];
}

- (void)downRegistrationView
{
    [UIView animateWithDuration:[self.animationDuration doubleValue] animations:^{
        self.contentView.registrationScrollBottomConstraint.offset = 0;
        [self.view layoutIfNeeded];
    } completion:^(BOOL finished) {
        self.contentView.scrollView.scrollEnabled = NO;
    }];
}

#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 1) {
        NSString *code = [alertView textFieldAtIndex:0].text;
        if (!ANIsEmptyStringByTrimmingWhitespaces(code)) {
            [self.eventHandler verifySMSCode:code];
        }
    }
}

@end
