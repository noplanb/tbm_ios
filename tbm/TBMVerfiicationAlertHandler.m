//
//  TBMVerificationAlertHandler.m
//  Zazo
//
//  Created by Sani Elfishawy on 5/15/15.
//  Copyright (c) 2015 No Plan B. All rights reserved.
//

#import "TBMVerificationAlertHandler.h"
#import "TBMPhoneUtils.h"
#import "TBMAlertControllerVisualStyle.h"
#import "OBLogger.h"

@interface TBMVerificationAlertHandler()
@property (nonatomic) TBMAlertController *alertController;
@property (nonatomic) UITextField *codeTextField;
@property (nonatomic) SDCAlertAction *confirmationAction;
@end

static const float LayoutConstContentMargin = 25.0f;
static const float LayoutConstVerticalSpacing = 15.0f;
static const float LayoutConstEnterCodeLabelHeight = 50.0f;
static const float LayoutConstTextFieldHeight = 40.0f;
static const float LayoutConstCallButtonHeight = 40.0f;


@implementation TBMVerificationAlertHandler

static NSString *TITLE = @"Enter Code";
static NSString *MESSAGE = @"We sent a code";


#pragma mark instantiation

- (instancetype) initWithPhoneNumber:(NSString *)phoneNumber{
    self = [super init];
    if (self != nil){
        self.phoneNumber = phoneNumber;
        self.alertController = [self makeAlertController];
        self.confirmationAction = [self makeCodeConfirmationAction];
        self.codeTextField = [self textField];
        self.callMeButton = [self callButton];
        [self addContentAndActionsToAlertController];
    }
    return self;
}

#pragma mark interface

- (void)presentAlert{
    [self.alertController presentWithCompletion:nil];
}


#pragma mark alert construction

- (TBMAlertController *)makeAlertController{
    return [TBMAlertController alertControllerWithTitle:@"Enter Code"
                                                message:@""
                                             forcePlain:[self forcePlain]];
}

- (void)addContentAndActionsToAlertController{
    [self.alertController.contentView addSubview:[self contentView]];
    [self.alertController addAction:[SDCAlertAction actionWithTitle:@"Cancel"
                                               style:SDCAlertActionStyleCancel
                                             handler:nil]];
    
    [self.alertController addAction:self.confirmationAction];
}

#pragma mark content view

- (UIView *)contentView{
    UIView *view = [[UIView alloc] initWithFrame: [self contentFrame]];
    view.backgroundColor = [UIColor clearColor];
    [view addSubview:[self enterCodeLabel]];
    [view addSubview:self.textField];
    [view addSubview:[self callButton]];
//    [view addSubview:[self callLabel]];
    return view;
}

- (CGRect)contentFrame{
//    float height = [self forcePlain] ? 130.0f : 90.0f;
    return CGRectMake(0, 0, [self contentOuterWidth] , [self contentHeight]);
}

- (float)contentInnerWidth{
    return [self contentOuterWidth] - (2 * LayoutConstContentMargin);
}

- (float)contentOuterWidth{
    return self.alertController.visualStyle.width;
}

- (float)contentHeight{
    return LayoutConstEnterCodeLabelHeight +
            LayoutConstTextFieldHeight +
            LayoutConstCallButtonHeight +
            3 * LayoutConstVerticalSpacing;
}

#pragma mark top label

- (CGRect)enterCodeLabelFrame{
//    float height = [self forcePlain] ? 40.0f : 20.0f;
    float height = LayoutConstEnterCodeLabelHeight;
    return CGRectMake(0, 0, [self contentOuterWidth], height);
}


- (UILabel *)enterCodeLabel{
    NSString *text = [NSString stringWithFormat:@"We sent a code via text\nto %@.", [TBMPhoneUtils phone:self.phoneNumber withFormat:NBEPhoneNumberFormatINTERNATIONAL]];
    return [self labelWithText:text frame:[self enterCodeLabelFrame]];
}


#pragma mark text field

- (CGRect)textFieldFrame{
    float y = [self enterCodeLabelFrame].origin.y + [self enterCodeLabelFrame].size.height + LayoutConstVerticalSpacing;
    return CGRectMake(LayoutConstContentMargin, y, [self contentInnerWidth], LayoutConstTextFieldHeight);
}

- (UITextField *)textField{
    UITextField *tf = [[UITextField alloc] initWithFrame:[self textFieldFrame]];
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

- (CGRect)callButtonFrame{
    float y = [self textFieldFrame].origin.y + LayoutConstTextFieldHeight + LayoutConstVerticalSpacing;
    return CGRectMake(LayoutConstContentMargin, y, [self contentInnerWidth], LayoutConstCallButtonHeight);
}

- (UIButton *)callButton{
    UIButton *button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [button setTitle:@"Call Me Instead" forState:UIControlStateNormal];
    button.frame = [self callButtonFrame];
    button.enabled = YES;
    [button addTarget:self action:@selector(callClick) forControlEvents:UIControlEventTouchUpInside];
    return button;
}


#pragma mark confirmation action

- (SDCAlertAction *)makeCodeConfirmationAction{
    SDCAlertAction *action = [SDCAlertAction actionWithTitle:@"Enter"
                                                       style:SDCAlertActionStyleCancel
                                                     handler:^(SDCAlertAction *action) {
                                                         [self didEnterCode:[self.textField text]];
                                                     }];
    action.enabled = NO;
    return action;
}


#pragma mark helpers

- (BOOL)isIphoneFour{
    return [[UIScreen mainScreen] bounds].size.height < 568.0f;
}

- (BOOL)forcePlain{
    // GARF: This is a hack to get around a bug we were not able to figure out relating to
    // iPhone 4S with running 8.0 not showing keyboard for code text field.
    // On 3.5" screens (e.g. iPhone 4S), need to force alert into "plain" mode, otherwise
    // the code input text field does not work, the keyboard will never appear
    return [self isIphoneFour];
}

- (NSString *)formattedPhoneNumber{
    return [TBMPhoneUtils phone:self.phoneNumber withFormat:NBEPhoneNumberFormatINTERNATIONAL];
}

- (UILabel *)labelWithText:(NSString *)text frame:(CGRect)frame{
    UILabel *label = [[UILabel alloc] initWithFrame:frame];
    label.numberOfLines = 2;
    label.text = text;
    label.font = [UIFont fontWithName:@"Helvetica" size:16.0f];
    label.textAlignment = NSTextAlignmentCenter;
    return label;
}

#pragma mark delegate methods

-(void)enterCodeTextFieldDidChange:(UITextField *)tf {
    self.confirmationAction.enabled = (tf.text.length > 0);
}

-(void)didEnterCode:(NSString *)text{
    OB_DEBUG(@"didEnterCode: %@", text);
}

-(void)callClick{
    OB_DEBUG(@"callClick");
}

@end
