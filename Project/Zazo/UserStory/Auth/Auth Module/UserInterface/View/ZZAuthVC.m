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
        
//        [self setupKeyboard];
    }
    return self;
}

- (void)loadView
{
    self.view = self.contentView;
}

//- (void)dealloc
//{
//    [self prepareForDie];
//    [self.keyboardObserver removeKeyboardNotification];
//}

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


//#pragma mark - Keyboard
//
//- (void)setupKeyboard
//{
//    [[NSNotificationCenter defaultCenter] addObserver:self
//                                             selector:@selector(keyboardWillShow:)
//                                                 name:UIKeyboardWillShowNotification
//                                               object:nil];
//    
//    [[NSNotificationCenter defaultCenter] addObserver:self
//                                             selector:@selector(keyboardWillHide:)
//                                                 name:UIKeyboardWillHideNotification
//                                               object:nil];
//    
//    [[NSNotificationCenter defaultCenter] addObserver:self
//                                             selector:@selector(keyboardWillShow:)
//                                                 name:UIKeyboardWillChangeFrameNotification
//                                               object:nil];
//}
//
//- (void)prepareForDie
//{
//    [[NSNotificationCenter defaultCenter] removeObserver:self];
//}
//
//- (void)keyboardWillShow:(NSNotification*)aNotification
//{
//    if (!self.isKeyboardShown)
//    {
//        self.isKeyboardShown = YES;
//        [self handleKeyboardWithNotification:aNotification];
//    }
//}
//
//- (void)keyboardWillHide:(NSNotification*)aNotification
//{
//    if (self.isKeyboardShown)
//    {
//        self.isKeyboardShown = NO;
//        [self handleKeyboardWithNotification:aNotification];
//    }
//}
//
//- (UIView*)findViewThatIsFirstResponderInParent:(UIView*)parent
//{
//    if (parent.isFirstResponder)
//    {
//        return parent;
//    }
//    
//    for (UIView *subView in parent.subviews)
//    {
//        UIView *firstResponder = [self findViewThatIsFirstResponderInParent:subView];
//        if (firstResponder != nil)
//        {
//            return firstResponder;
//        }
//    }
//    
//    return nil;
//}
//
//- (void)handleKeyboardWithNotification:(NSNotification*)aNotification
//{
//    NSDictionary* info = [aNotification userInfo];
//    CGFloat kbHeight = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size.height;
//    CGFloat duration = [info[UIKeyboardAnimationDurationUserInfoKey] floatValue];
//    if (IS_IPHONE_4)
//    {
//        kbHeight = 320;
//    }
//    kbHeight = self.isKeyboardShown ? kbHeight : -kbHeight;
//    
//    ANDispatchBlockToMainQueue(^{
//        [UIView animateWithDuration:duration animations:^{
//            
//            UIEdgeInsets contentInsets = UIEdgeInsetsMake(self.contentView.scrollView.contentInset.top,
//                                                          0.0,
//                                                          self.contentView.scrollView.contentInset.bottom + kbHeight,
//                                                          0.0);
//            
//            self.contentView.scrollView.contentInset = contentInsets;
//            self.contentView.scrollView.scrollIndicatorInsets = contentInsets;
//            UIView* responder = [self findViewThatIsFirstResponderInParent:self.contentView.scrollView];
//            if (responder)
//            {
//                CGRect rect = [self.contentView.scrollView convertRect:responder.frame
//                                                              fromView:responder.superview];
//                
//                [self.contentView.scrollView scrollRectToVisible:rect animated:NO];
//            }
//        } completion:^(BOOL finished) {
//            
//        }];
//    });
//}
//
//- (void)hideKeyboard
//{
//    [self.contentView endEditing:YES];
//}

@end
