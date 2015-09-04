//
//  TBMRegisterForm.m
//  FormUsingCode
//
//  Created by Sani Elfishawy on 11/12/14.
//  Copyright (c) 2014 No Plan B. All rights reserved.
//
#import "TBMRegisterForm.h"
#import "TPKeyboardAvoidingScrollView.h"
#import "TBMConfig.h"
#import "TBMSecretScreenPresenter.h"
#import "TBMRegisterViewController.h"
#import "TBMUser.h"
#import "NBPhoneNumberUtil.h"
#import "NBPhoneNumber.h"
#import "ZZStoredSettingsManager.h"

@interface TBMRegisterForm ()
@property(nonatomic) float screenWidth;
@property(nonatomic) BOOL isWaiting;

@property(nonatomic) UIView *topView;
@property(nonatomic) id delegate;

@property(nonatomic) TPKeyboardAvoidingScrollView *scrollView;
@property(nonatomic) UIView *contentView;
@property(nonatomic) UIImageView *title;
@property(nonatomic) UILabel *plus;
@property(nonatomic) UILabel *countryCodeLbl;
@property(nonatomic) UILabel *countryCodeHint;
@property(nonatomic) UIButton *submit;

//@property(nonatomic, strong) TBMSecretScreenPresenter *secretScreen;
@end

//static const float TBMRegisterLogoTopMargin = 106.0;
//static const float TBMRegisterFieldsTopMargin = 60.0;
//static const float TBMRegisterFieldsVerticalMargin = 10.0;
//static const float TBMRegisterCountryCodeRightMargin = 8.0;
//static const float TBMRegisterSubmitTopMargin = 60.0;
//static const float TBMRegisterSpinnerTopMargin = 10.0;
//
//static const float TBMRegisterTextFieldHeight = 38.0;
//static const float TBMRegisterTextFieldFontSize = 21.0;
static const float TBMRegisterTextFieldMaxWidth = 360.0;
static const float TBMRegisterTextFieldWidthMultiplier = 0.1;

@implementation TBMRegisterForm

- (instancetype)initWithView:(UIView *)view delegate:(id <TBMRegisterFormDelegate>)delegate {
    self = [super init];
    if (self != nil) {
        _topView = view;
        _delegate = delegate;
        _isWaiting = NO;
        _screenWidth = [[UIScreen mainScreen] bounds].size.width;
        [self setupRegisterForm];
    }
    return self;
}

//----------------
// Form control
//----------------
- (void)startWaitingForServer {
    self.isWaiting = YES;
    [self.spinner startAnimating];
    [self.submit setEnabled:NO];

}

- (void)stopWaitingForServer {
    self.isWaiting = NO;
    [self.spinner stopAnimating];
    [self.submit setEnabled:YES];
}

//------------
// Form events
//------------
- (void)submitClick {
    [self.topView endEditing:YES];
    [self.delegate didClickSubmit];
}

- (BOOL)textFieldShouldReturn:(TBMTextField *)textField {
    BOOL didResign = [textField resignFirstResponder];
    if (!didResign) return NO;

    TBMTextField *nextField = [(TBMTextField *) textField nextField];
    if ([textField isKindOfClass:[TBMTextField class]] && nextField != nil) {
        [nextField becomeFirstResponder];
    }
    return YES;
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    if (self.isWaiting)
        return NO;
    else
        return YES;
}

//----------------
// Set up the form
//----------------

- (void)setupRegisterForm {
//    [self addScrollView];
//    [self addContentView];
    [self addTitle];
    [self addFirstName];
    [self addLastName];
    [self addPlus];
    [self addCountryCode];
    [self addCountryCodeLabel];
    [self addCountryCodeHint];
    [self addMobileNumber];
    [self addSubmit];
    [self addSpinner];
    [self setScrollViewSize];
//    [self addNextFields];
    [self.topView setNeedsDisplay];
    [self prefillUserData];
}

- (void)prefillUserData {
    TBMUser *user = [TBMUser getUser];
    if (!user) {
        return;
    }

    self.firstName.text = user.firstName;
    self.lastName.text = user.lastName;

    NSError *error = nil;
    if (user.mobileNumber && user.mobileNumber.length > 0) {
        NBPhoneNumber *phoneNumber = [[NBPhoneNumberUtil new] parse:user.mobileNumber defaultRegion:@"US" error:&error];
        if (!error) {
            self.countryCode.text = [phoneNumber.countryCode stringValue];
            self.mobileNumber.text = [phoneNumber.nationalNumber stringValue];
        }
    }
}
//
//- (void)addScrollView {
//    self.scrollView = [[TPKeyboardAvoidingScrollView alloc] initWithFrame:self.topView.frame];
//    [self.topView addSubview:self.scrollView];
//}
//
//- (void)addContentView {
//    self.contentView = [[UIView alloc] initWithFrame:self.topView.frame];
//    [self.scrollView addSubview:self.contentView];
//}

- (void)addTitle {
//    CGRect f;
//    f.size.width = 136.0;
//    f.size.height = 35.0;
//    f.origin.x = (self.topView.frame.size.width - f.size.width) / 2.0;
//    f.origin.y = TBMRegisterLogoTopMargin;
//
//    self.title = [[UIImageView alloc] initWithFrame:f];
//    self.title.image = [UIImage imageNamed:@"logotype"];
//    [self.title addGestureRecognizer:[[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(titleTapAction:)]];
//    self.title.userInteractionEnabled = YES;
//    [self.contentView addSubview:self.title];
}

- (void)titleTapAction:(id)sender {
//    UILongPressGestureRecognizer *gesture = sender;
//    if (gesture.state == UIGestureRecognizerStateEnded) {
//        NSString *countryCode = self.countryCode.text;
//        if (countryCode && [countryCode rangeOfString:@"000"].location != NSNotFound) {
//            self.countryCode.text = @"";
//            [self.secretScreen presentSecretScreenFromController:self.controller];
//        }
//    }
}

- (float)textFieldLargeWidth {
    float width = self.contentView.frame.size.width - (2 * self.contentView.frame.size.width * TBMRegisterTextFieldWidthMultiplier);
    return (width < TBMRegisterTextFieldMaxWidth ? width : TBMRegisterTextFieldMaxWidth);
}

- (void)addFirstName {
//    CGRect f;
//    f.origin.x = (self.topView.frame.size.width - [self textFieldLargeWidth]) / 2.0;
//    f.origin.y = self.title.frame.origin.y + self.title.frame.size.height + TBMRegisterFieldsTopMargin;
//    f.size.width = [self textFieldLargeWidth];
//    f.size.height = TBMRegisterTextFieldHeight;
//
//    self.firstName = [[TBMTextField alloc] initWithFrame:f];
//    self.firstName.placeholder = @"First Name";
//    [self.firstName setKeyboardType:UIKeyboardTypeDefault];
//    [self.firstName setReturnKeyType:UIReturnKeyNext];
//    [self setCommonAttributesForTextField:self.firstName];
//    [self.contentView addSubview:self.firstName];
}

- (void)addLastName {
//    CGRect f;
//    f.origin.x = (self.topView.frame.size.width - [self textFieldLargeWidth]) / 2.0;
//    f.origin.y = self.firstName.frame.origin.y + self.firstName.frame.size.height + TBMRegisterFieldsVerticalMargin;
//    f.size.height = TBMRegisterTextFieldHeight;
//    f.size.width = [self textFieldLargeWidth];
//
//    self.lastName = [[TBMTextField alloc] initWithFrame:f];
//    self.lastName.placeholder = @"Last Name";
//    [self.lastName setKeyboardType:UIKeyboardTypeDefault];
//    [self.lastName setReturnKeyType:UIReturnKeyNext];
//    [self setCommonAttributesForTextField:self.lastName];
//    [self.contentView addSubview:self.lastName];
}

- (void)addPlus {
//    CGRect f;
//    f.origin.x = self.firstName.frame.origin.x;
//    f.origin.y = self.lastName.frame.origin.y + self.lastName.frame.size.height + TBMRegisterFieldsVerticalMargin - 2;
//    f.size.width = 19.0;
//    f.size.height = TBMRegisterTextFieldHeight;
//
//    self.plus = [[UILabel alloc] initWithFrame:f];
//    self.plus.textColor = [UIColor whiteColor];
//    [self.plus setText:@"+"];
//    self.plus.font = [UIFont systemFontOfSize:TBMRegisterTextFieldFontSize];
//    self.plus.textAlignment = NSTextAlignmentCenter;
//    [self.contentView addSubview:self.plus];
}

- (void)addCountryCode {
//    CGRect f;
//    f.origin.x = self.firstName.frame.origin.x;
//    f.origin.y = self.lastName.frame.origin.y + self.lastName.frame.size.height + TBMRegisterFieldsVerticalMargin;
//    f.size.width = 70.0;
//    f.size.height = TBMRegisterTextFieldHeight;
//
//    self.countryCode = [[TBMTextField alloc] initWithFrame:f];
//    [self.countryCode setKeyboardType:UIKeyboardTypeNumberPad];
//    [self setCommonAttributesForTextField:self.countryCode];
//    [self.contentView addSubview:self.countryCode];
//
//    UIView *spacerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 18, 10)];
//    [self.countryCode setLeftView:spacerView];
}

- (void)addCountryCodeLabel {
//    CGRect f;
//    f.origin.x = self.countryCode.frame.origin.x;
//    f.origin.y = self.plus.frame.origin.y + self.plus.frame.size.height + 5.0;
//    f.size.width = self.countryCode.frame.size.width;
//    f.size.height = 10.0;
//
//    self.countryCodeLbl = [[UILabel alloc] initWithFrame:f];
//    self.countryCodeLbl.font = [UIFont systemFontOfSize:9];
//    self.countryCodeLbl.textAlignment = NSTextAlignmentCenter;
//    self.countryCodeLbl.textColor = [UIColor whiteColor];
//    [self.countryCodeLbl setText:@"Country Code"];
//    [self.contentView addSubview:self.countryCodeLbl];
}

- (void)addCountryCodeHint {
//    CGRect f;
//    f.origin.x = self.countryCode.frame.origin.x;
//    f.origin.y = self.countryCodeLbl.frame.origin.y + self.countryCodeLbl.frame.size.height + 5.0;
//    f.size.width = self.countryCode.frame.size.width;
//    f.size.height = 10.0;
//
//    self.countryCodeHint = [[UILabel alloc] initWithFrame:f];
//    self.countryCodeHint.font = [UIFont systemFontOfSize:9];
//    self.countryCodeHint.textAlignment = NSTextAlignmentCenter;
//    self.countryCodeHint.textColor = [UIColor whiteColor];
//    [self.countryCodeHint setText:@"USA +1"];
//    [self.contentView addSubview:self.countryCodeHint];
}

- (void)addMobileNumber {
//    CGRect f;
//    f.origin.x = self.countryCode.frame.origin.x + self.countryCode.frame.size.width + TBMRegisterCountryCodeRightMargin;
//    f.origin.y = self.countryCode.frame.origin.y;
//    f.size.width = [self textFieldLargeWidth] - self.countryCode.frame.size.width - TBMRegisterCountryCodeRightMargin;
//    f.size.height = TBMRegisterTextFieldHeight;
//
//    self.mobileNumber = [[TBMTextField alloc] initWithFrame:f];
//    self.mobileNumber.placeholder = @"Phone";
//    [self.mobileNumber setKeyboardType:UIKeyboardTypeNumberPad];
//    [self setCommonAttributesForTextField:self.mobileNumber];
//    [self.contentView addSubview:self.mobileNumber];
}

- (void)setCommonAttributesForTextField:(TBMTextField *)tf {
//    tf.delegate = self;
//    tf.font = [UIFont fontWithName:@"Helvetica-Light" size:TBMRegisterTextFieldFontSize];
//    tf.autocorrectionType = UITextAutocorrectionTypeNo;
//    tf.textColor = [UIColor blackColor];
//    tf.backgroundColor = [UIColor clearColor];
//    tf.borderStyle = UITextBorderStyleNone;
//
//    UIView *spacerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 10, 10)];
//    [tf setLeftViewMode:UITextFieldViewModeAlways];
//    [tf setLeftView:spacerView];
}

- (void)addSubmit {
//    CGRect f;
//    f.size.width = 170.0;
//    f.size.height = 55.0;
//    f.origin.x = (self.topView.frame.size.width - f.size.width) / 2.0;
//    f.origin.y = self.plus.frame.origin.y + self.plus.frame.size.height + TBMRegisterSubmitTopMargin;
//
//    self.submit = [UIButton buttonWithType:UIButtonTypeCustom];
//    [self.submit setBackgroundImage:[UIImage imageNamed:@"dark-button-bg"] forState:UIControlStateNormal];
//    [self.submit addTarget:self action:@selector(submitClick) forControlEvents:UIControlEventTouchUpInside];
//    self.submit.frame = f;
//    [self setCommonAttributesForButton:self.submit];
//    [self.submit setTitle:@"Sign In" forState:UIControlStateNormal];
//    self.submit.titleLabel.textColor = [UIColor whiteColor];
//    [self.contentView addSubview:self.submit];
}

- (void)addSpinner {
//    CGRect f;
//    f.origin.x = (self.screenWidth / 2) - 50;
//    f.origin.y = self.submit.frame.origin.y + self.submit.frame.size.height + TBMRegisterSpinnerTopMargin;
//    f.size.width = 100;
//    f.size.height = TBMRegisterTextFieldHeight;
//
//    self.spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
//    self.spinner.frame = f;
//    [self.contentView addSubview:self.spinner];
//    [self.spinner stopAnimating];
}


- (void)setScrollViewSize
{
//    float height = 10.0;
//    self.scrollView.contentSize = CGSizeMake(self.screenWidth, height);
//    CGRect f = self.contentView.frame;
//    f.size.height = height;
//    self.contentView.frame = f;
}


//- (void)setCommonAttributesForButton:(UIButton *)b {
//    [b.titleLabel setFont:[UIFont systemFontOfSize:22]];
//    b.titleLabel.textAlignment = NSTextAlignmentCenter;
//}

//- (void)addNextFields {
//    self.firstName.nextField = self.lastName;
//    self.lastName.nextField = self.countryCode;
//    self.countryCode.nextField = self.mobileNumber;
//    self.mobileNumber.nextField = nil;
//}
//
//- (TBMSecretScreenPresenter *)secretScreen {
//    if (!_secretScreen) {
//        _secretScreen = [[TBMSecretScreenPresenter alloc] init];
//    }
//    return _secretScreen;
//}


@end
