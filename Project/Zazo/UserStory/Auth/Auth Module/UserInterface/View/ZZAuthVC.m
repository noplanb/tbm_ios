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
@property (nonatomic, assign) BOOL isKeyboardShown;

@end

@implementation ZZAuthVC

- (instancetype)init
{
    if (self = [super init])
    {
        self.contentView = [ZZAuthContentView new];
//        self.keyboardObserver = [[ZZKeyboardObserver alloc] initWithDelegate:self];
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
        
        [self setupKeyboard];
    }
    return self;
}

- (void)loadView
{
    self.view = self.contentView;
}

- (void)dealloc
{
    [self prepareForDie];
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
}

- (void)didEnterVerificationCode:(NSString*)code
{
    [self.eventHandler verifySMSCode:code];
}

- (void)didTapCallMe
{
    [self.eventHandler requestCall];
}


#pragma mark - Keyboard

- (void)setupKeyboard
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillChangeFrameNotification
                                               object:nil];
}

- (void)prepareForDie
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)keyboardWillShow:(NSNotification*)aNotification
{
    if (!self.isKeyboardShown)
    {
        self.isKeyboardShown = YES;
        [self handleKeyboardWithNotification:aNotification];
    }
}

- (void)keyboardWillHide:(NSNotification*)aNotification
{
    if (self.isKeyboardShown)
    {
        self.isKeyboardShown = NO;
        [self handleKeyboardWithNotification:aNotification];
    }
}

- (UIView*)findViewThatIsFirstResponderInParent:(UIView*)parent
{
    if (parent.isFirstResponder)
    {
        return parent;
    }
    
    for (UIView *subView in parent.subviews)
    {
        UIView *firstResponder = [self findViewThatIsFirstResponderInParent:subView];
        if (firstResponder != nil)
        {
            return firstResponder;
        }
    }
    
    return nil;
}

- (void)handleKeyboardWithNotification:(NSNotification*)aNotification
{
    NSDictionary* info = [aNotification userInfo];
    CGFloat kbHeight = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size.height;
    CGFloat duration = [info[UIKeyboardAnimationDurationUserInfoKey] floatValue];
    if (IS_IPHONE_4)
    {
        kbHeight = 320;
    }
    kbHeight = self.isKeyboardShown ? kbHeight : -kbHeight;
    
    ANDispatchBlockToMainQueue(^{
        [UIView animateWithDuration:duration animations:^{
            
            UIEdgeInsets contentInsets = UIEdgeInsetsMake(self.contentView.scrollView.contentInset.top,
                                                          0.0,
                                                          self.contentView.scrollView.contentInset.bottom + kbHeight,
                                                          0.0);
            
            self.contentView.scrollView.contentInset = contentInsets;
            self.contentView.scrollView.scrollIndicatorInsets = contentInsets;
            UIView* responder = [self findViewThatIsFirstResponderInParent:self.contentView.scrollView];
            if (responder)
            {
                CGRect rect = [self.contentView.scrollView convertRect:responder.frame
                                                              fromView:responder.superview];
                
                [self.contentView.scrollView scrollRectToVisible:rect animated:NO];
            }
        } completion:^(BOOL finished) {
            
        }];
    });
}

- (void)hideKeyboard
{
    [self.contentView endEditing:YES];
}


//
//
//#pragma mark - Keyboard observer
//
//- (void)keyboardChangeFrameWithAnimationDuration:(NSNumber*)animationDuration
//                              withKeyboardHeight:(CGFloat)keyboardHeight
//                               withKeyboardFrame:(CGRect)keyboarFrame
//{
//    self.animationDuration = animationDuration;
//    if (IS_IPHONE_4)
//    {
//        [UIView animateWithDuration:[self.animationDuration doubleValue] animations:^{
//            
//            UIEdgeInsets insets = UIEdgeInsetsMake(0, 0, 320, 0);
//            self.contentView.scrollView.contentInset = insets;
//            self.contentView.scrollView.scrollIndicatorInsets = insets;
//            [self.view layoutIfNeeded];
//        } completion:^(BOOL finished) {
//            
//            self.contentView.scrollView.scrollEnabled = NO;
//        }];
//    }
//    else
//    {
//        if (CGRectIntersectsRect(self.contentView.registrationView.phoneNumberTextField.frame, keyboarFrame))
//        {
//            CGRect intersectionFrame =  CGRectIntersection(self.contentView.registrationView.signInButton.frame, keyboarFrame);
//            [self changeRegistartionViewPositionWithKeyboardHeight:(CGRectGetHeight(intersectionFrame) + CGRectGetHeight(self.contentView.registrationView.phoneNumberTextField.frame))];
//        }
//        else if (CGRectIntersectsRect(self.contentView.registrationView.signInButton.frame, keyboarFrame))
//        {
//            UIEdgeInsets insets = UIEdgeInsetsMake(0, 0, keyboardHeight, 0);
//            self.contentView.scrollView.contentInset = insets;
//            self.contentView.scrollView.scrollIndicatorInsets = insets;
//            self.contentView.scrollView.scrollEnabled = YES;
//        }
//        else
//        {
//            UIEdgeInsets insets = UIEdgeInsetsZero;
//            self.contentView.scrollView.contentInset = insets;
//            self.contentView.scrollView.scrollIndicatorInsets = insets;
//            
//            self.contentView.scrollView.scrollEnabled = NO;
//        }
//    }
//}
//
//- (void)keyboardWillHide
//{
//    [self scrollDownRegistrationView];
//}
//
//- (void)changeRegistartionViewPositionWithKeyboardHeight:(CGFloat)keyboardHeight
//{
//    [UIView animateWithDuration:[self.animationDuration doubleValue] animations:^{
//       
//        self.contentView.scrollView.contentInset = UIEdgeInsetsMake(0, 0, keyboardHeight / 2, 0);
//        self.contentView.scrollView.scrollIndicatorInsets = UIEdgeInsetsMake(0, 0, keyboardHeight / 2, 0);
//        [self.view layoutIfNeeded];
//    } completion:^(BOOL finished) {
//        
//        self.contentView.scrollView.scrollEnabled = YES;
//    }];
//}
//
//- (void)scrollDownRegistrationView
//{
//    [UIView animateWithDuration:[self.animationDuration doubleValue] animations:^{
//        
//        self.contentView.scrollView.contentInset = UIEdgeInsetsZero;
//        self.contentView.scrollView.scrollIndicatorInsets = UIEdgeInsetsZero;
//        [self.view layoutIfNeeded];
//        
//    } completion:^(BOOL finished) {
//        
//        self.contentView.scrollView.scrollEnabled = NO;
//    }];
//}

@end
