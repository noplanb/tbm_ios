//
//  ZZVerificationAlertHandler.m
//  Zazo
//
//  Created by Sani Elfishawy on 5/15/15.
//  Copyright (c) 2015 No Plan B. All rights reserved.
//

#import "ZZVerificationAlertHandler.h"
#import "ZZPhoneHelper.h"
#import "SDCAlertControllerVisualStyle.h"
#import "SDCAlertController.h"

@interface ZZVerificationAlertHandler ()

@property (nonatomic) SDCAlertController *alertController;
@property (nonatomic) UITextField *codeTextField;
@property (nonatomic) SDCAlertAction *confirmationAction;
@property (nonatomic) UIButton *callMeButton;
@property (nonatomic) UILabel *callingLabel;
@property (nonatomic) id <TBMVerificationAlertDelegate> delegate;
@end

static const float LayoutConstContentMargin = 25.0f;
static const float LayoutConstVerticalSpacing = 15.0f;
static const float LayoutConstEnterCodeLabelHeight = 50.0f;
static const float LayoutConstTextFieldHeight = 40.0f;
static const float LayoutConstCallButtonHeight = 40.0f;


@implementation ZZVerificationAlertHandler

static NSString *TITLE = @"Enter Code";
static NSString *MESSAGE = @"We sent a code";


#pragma mark instantiation

- (instancetype)initWithPhoneNumber:(NSString *)phoneNumber delegate:(id <TBMVerificationAlertDelegate>)delegate
{
    self = [super init];
    if (self != nil)
    {
        self.delegate = delegate;
        self.phoneNumber = phoneNumber;
        self.alertController = [self makeAlertController];
        self.confirmationAction = [self makeCodeConfirmationAction];
        self.codeTextField = [self makeCodeTextField];
        self.callMeButton = [self makeCallButton];
        self.callingLabel = [self makeCallingLabel];
        [self addContentAndActionsToAlertController];
    }
    return self;
}


#pragma mark interface

- (void)presentAlert
{
    [self.alertController presentWithCompletion:nil];
}

- (void)dismissAlertWithCompletion:(ANCodeBlock)completion
{
    [self.alertController dismissWithCompletion:completion];
}

#pragma mark alert construction

- (SDCAlertController *)makeAlertController
{
    return [SDCAlertController alertControllerWithTitle:TITLE
                                                message:nil
                                         preferredStyle:SDCAlertControllerStyleAlert];
}

- (void)addContentAndActionsToAlertController
{
    [self.alertController.contentView addSubview:[self contentView]];
    [self.alertController addAction:[SDCAlertAction actionWithTitle:@"Cancel"
                                                              style:SDCAlertActionStyleCancel
                                                            handler:nil]];

    [self.alertController addAction:self.confirmationAction];
}

#pragma mark content view

- (UIView *)contentView
{
    UIView *view = [[UIView alloc] initWithFrame:[self contentFrame]];
    view.backgroundColor = [UIColor clearColor];
    [view addSubview:[self enterCodeLabel]];
    [view addSubview:self.codeTextField];
    [view addSubview:self.callMeButton];
    [view addSubview:self.callingLabel];
    return view;
}

- (CGRect)contentFrame
{
    return CGRectMake(0, 0, [self contentOuterWidth], [self contentHeight]);
}

- (float)contentInnerWidth
{
    return [self contentOuterWidth] - (2 * LayoutConstContentMargin);
}

- (float)contentOuterWidth
{
    
    return self.alertController.visualStyle.width;
}

- (float)contentHeight
{
    float height = LayoutConstEnterCodeLabelHeight +
            LayoutConstTextFieldHeight +
            LayoutConstCallButtonHeight +
            3 * LayoutConstVerticalSpacing;
    return [self isIphoneFour] ? height - 30.0f : height;
}

#pragma mark top label

- (CGRect)enterCodeLabelFrame
{
    float height = LayoutConstEnterCodeLabelHeight;
    return CGRectMake(0, 0, [self contentOuterWidth], height);
}


- (UILabel *)enterCodeLabel
{
    NSString *text = [NSString stringWithFormat:@"We sent a code via text\nto %@.",
                                                [ZZPhoneHelper phone:self.phoneNumber withFormat:ZZPhoneFormatTypeInternational]];
    return [self labelWithText:text frame:[self enterCodeLabelFrame]];
}


#pragma mark text field

- (CGRect)textFieldFrame
{
    float y = [self enterCodeLabelFrame].origin.y + [self enterCodeLabelFrame].size.height + LayoutConstVerticalSpacing;
    return CGRectMake(LayoutConstContentMargin, y, [self contentInnerWidth], LayoutConstTextFieldHeight);
}

- (UITextField *)makeCodeTextField
{
    UITextField *tf = [[UITextField alloc] initWithFrame:[self textFieldFrame]];
#ifdef DEBUG_LOGIN_USER
    tf.text = @"0000";
    self.confirmationAction.enabled = YES;
#endif
    tf.keyboardType = UIKeyboardTypeNumberPad;
    tf.backgroundColor = [UIColor whiteColor];
    tf.borderStyle = UITextBorderStyleRoundedRect;
    NSString *fname = tf.font.fontName;
    tf.font = [UIFont fontWithName:fname size:20.0f];
    [tf addTarget:self
           action:@selector(enterCodeTextFieldDidChange:)
 forControlEvents:UIControlEventEditingChanged];
    return tf;
}

#pragma mark call button

- (CGRect)callButtonFrame
{
    float y = [self textFieldFrame].origin.y + (LayoutConstTextFieldHeight / 2) + LayoutConstVerticalSpacing;
    return CGRectMake(LayoutConstContentMargin, y, [self contentInnerWidth], LayoutConstCallButtonHeight);
}

- (UIButton *)makeCallButton
{
    UIButton *button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [button setTitle:@"Call Me Instead" forState:UIControlStateNormal];
    button.frame = [self callButtonFrame];
    button.enabled = YES;
    [button addTarget:self action:@selector(didTapCallMe) forControlEvents:UIControlEventTouchUpInside];
    return button;
}

#pragma mark calling label

- (UILabel *)makeCallingLabel
{
    UILabel *label = [self labelWithText:@"Calling you now..." frame:[self callButtonFrame]];
    label.hidden = YES;
    return label;
}

#pragma mark confirmation action

- (SDCAlertAction *)makeCodeConfirmationAction
{
    SDCAlertAction *action = [SDCAlertAction actionWithTitle:@"Enter"
                                                       style:SDCAlertActionStyleCancel
                                                     handler:^(SDCAlertAction *action) {
                                                         [self didEnterCode];
                                                     }];
    action.enabled = NO;
    return action;
}


#pragma mark helpers

- (BOOL)isIphoneFour
{
    return [[UIScreen mainScreen] bounds].size.height < 568.0f;
}

- (NSString *)formattedPhoneNumber
{
    return [ZZPhoneHelper phone:self.phoneNumber withFormat:ZZPhoneFormatTypeInternational];
}

- (UILabel *)labelWithText:(NSString *)text frame:(CGRect)frame
{
    UILabel *label = [[UILabel alloc] initWithFrame:frame];
    label.numberOfLines = 2;
    label.text = text;
    label.font = [UIFont fontWithName:@"Helvetica" size:16.0f];
    label.textAlignment = NSTextAlignmentCenter;
    return label;
}

#pragma mark delegate methods

- (void)enterCodeTextFieldDidChange:(UITextField *)tf
{
    self.confirmationAction.enabled = (tf.text.length > 0);
}

- (void)didEnterCode
{
    if (self.delegate != nil && [self.delegate respondsToSelector:@selector(didEnterVerificationCode:)])
        [self.delegate didEnterVerificationCode:[self.codeTextField text]];
}


- (void)didTapCallMe
{
    self.callMeButton.hidden = YES;
    self.callingLabel.hidden = NO;
    if ([self.delegate respondsToSelector:@selector(didTapCallMe)])
    {
        [self.delegate didTapCallMe];
    }
}

@end
