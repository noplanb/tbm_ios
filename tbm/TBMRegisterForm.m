//
//  TBMRegisterForm.m
//  FormUsingCode
//
//  Created by Sani Elfishawy on 11/12/14.
//  Copyright (c) 2014 No Plan B. All rights reserved.
//
#import <UIKit/UIKit.h>
#import "TBMRegisterForm.h"

@interface TBMRegisterForm()
@property (nonatomic) float screenWidth;
@property (nonatomic) BOOL isWaiting;

@property (nonatomic) UIView *topView;
@property (nonatomic) id delegate;

@property (nonatomic) UIScrollView *scrollView;
@property (nonatomic) UIView *contentView;
@property (nonatomic) UILabel *title;
@property (nonatomic) UILabel *plus;
@property (nonatomic) UILabel *countryCodeLbl;
@property (nonatomic) UIButton *submit;
@property (nonatomic) UIButton *debug;
@end

static const float TBMRegisterMargin = 25.0;
static const float TBMRegisterVertSpacing = 20.0;
static const float TBMRegisterHorizSpacing = 10.0;
static const float TBMRegisterTextFieldHeight = 40.0;
static const float TBMRegisterTextFieldFontSize = 18.0;

@implementation TBMRegisterForm

- (instancetype)initWithView:(UIView *)view delegate:(id <TBMRegisterFormDelegate>)delegate{
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
- (void)startWaitingForServer{
    self.isWaiting = YES;
    [self.spinner startAnimating];

}
- (void)stopWaitingForServer{
    self.isWaiting = NO;
    [self.spinner stopAnimating];
}

//------------
// Form events
//------------
- (void)submitClick{
    [self.topView endEditing:YES];
    [self.delegate didClickSubmit];
}

- (void)debugClick{
    [self.topView endEditing:YES];
    [self.delegate didClickDebug];
}

- (BOOL) textFieldShouldReturn:(TBMTextField *) textField {
    BOOL didResign = [textField resignFirstResponder];
    if (!didResign) return NO;
    
    TBMTextField *nextField = [(TBMTextField *)textField nextField];
    if ([textField isKindOfClass:[TBMTextField class]] && nextField != nil){
        [nextField becomeFirstResponder];
    }
    return YES;
}

- (BOOL) textFieldShouldBeginEditing:(UITextField *)textField{
    if (self.isWaiting)
        return NO;
    else
        return YES;
}

//----------------
// Set up the form
//----------------
- (void)setupRegisterForm{
    [self addScrollView];
    [self addContentView];
    [self addTitle];
    [self addFirstName];
    [self addLastName];
    [self addPlus];
    [self addCountryCode];
    [self addCountryCodeLabel];
    [self addMobileNumber];
    [self addSubmit];
    [self addSpinner];
    [self addDebug];
    [self setScrollViewSize];
    [self addNextFields];
    [self.topView setNeedsDisplay];
}

- (void)addScrollView{
    self.scrollView = [[UIScrollView alloc] initWithFrame:self.topView.frame];
    [self.topView addSubview:self.scrollView];
}

- (void)addContentView{
    self.contentView = [[UIView alloc] initWithFrame:self.topView.frame];
    [self.scrollView addSubview:self.contentView];
}

- (void)addTitle{
    CGRect f;
    f.origin.x = self.topView.frame.origin.x;
    f.origin.y = 40;
    f.size.width = self.topView.frame.size.width;
    f.size.height = 40;
    self.title = [[UILabel alloc] initWithFrame:f];
    self.title.textAlignment = NSTextAlignmentCenter;
    self.title.font = [UIFont systemFontOfSize:30];
    [self.title setText:@"Sign In"];
    [self.contentView addSubview:self.title];
}

- (void)addFirstName{
    CGRect f;
    f.origin.x = TBMRegisterMargin;
    f.origin.y = self.title.frame.origin.y + self.title.frame.size.height + TBMRegisterVertSpacing;
    f.size.width = self.screenWidth - 2 * TBMRegisterMargin;
    f.size.height = TBMRegisterTextFieldHeight;
    self.firstName = [[TBMTextField alloc] initWithFrame:f];
    self.firstName.placeholder = @"First Name";
    [self.firstName setKeyboardType:UIKeyboardTypeAlphabet];
    [self setCommonAttributesForTextField:self.firstName];
    [self.contentView addSubview:self.firstName];
}

- (void)addLastName{
    CGRect f;
    f.origin.x = TBMRegisterMargin;
    f.origin.y = self.firstName.frame.origin.y + self.firstName.frame.size.height + TBMRegisterVertSpacing;
    f.size.height = TBMRegisterTextFieldHeight;
    f.size.width = self.screenWidth - 2 * TBMRegisterMargin;
    self.lastName = [[TBMTextField alloc] initWithFrame:f];
    self.lastName.placeholder = @"Last Name";
    [self.lastName setKeyboardType:UIKeyboardTypeAlphabet];
    [self setCommonAttributesForTextField:self.lastName];
    [self.contentView addSubview:self.lastName];
}

- (void)addPlus{
    CGRect f;
    f.origin.x = TBMRegisterMargin;
    f.origin.y = self.lastName.frame.origin.y + self.lastName.frame.size.height + TBMRegisterVertSpacing;
    f.size.width = 15;
    f.size.height = TBMRegisterTextFieldHeight;
    self.plus = [[UILabel alloc] initWithFrame:f];
    [self.plus setText:@"+"];
    self.plus.font = [UIFont systemFontOfSize:TBMRegisterTextFieldFontSize];
    self.plus.textAlignment = NSTextAlignmentCenter;
    [self.contentView addSubview:self.plus];
}

- (void)addCountryCode{
    CGRect f;
    f.origin.x = self.plus.frame.origin.x + self.plus.frame.size.width + 5;
    f.origin.y = self.plus.frame.origin.y;
    f.size.width = 50;
    f.size.height = TBMRegisterTextFieldHeight;
    self.countryCode = [[TBMTextField alloc] initWithFrame:f];
    [self.countryCode setKeyboardType:UIKeyboardTypeNumberPad];
    [self setCommonAttributesForTextField:self.countryCode];
    [self.contentView addSubview:self.countryCode];
}

- (void)addCountryCodeLabel{
    CGRect f;
    f.origin.x = TBMRegisterMargin;
    f.origin.y = self.plus.frame.origin.y + self.plus.frame.size.height + 5;
    f.size.width = self.plus.frame.size.width + self.countryCode.frame.size.width + 5;
    f.size.height = 10;
    UILabel *cclbl = [[UILabel alloc] initWithFrame:f];
    cclbl.font = [UIFont systemFontOfSize:8];
    cclbl.textAlignment = NSTextAlignmentCenter;
    [cclbl setText:@"Country Code"];
    [self.contentView addSubview:cclbl];
}

- (void)addMobileNumber{
    CGRect f;
    f.origin.x = self.countryCode.frame.origin.x + self.countryCode.frame.size.width + TBMRegisterHorizSpacing;
    f.origin.y = self.plus.frame.origin.y;
    f.size.width = self.screenWidth - 2*(TBMRegisterMargin+TBMRegisterHorizSpacing) - self.plus.frame.size.width - self.countryCode.frame.size.width;
    f.size.height = TBMRegisterTextFieldHeight;
    self.mobileNumber = [[TBMTextField alloc] initWithFrame:f];
    self.mobileNumber.placeholder = @"Phone Number";
    [self.mobileNumber setKeyboardType:UIKeyboardTypeNumberPad];
    [self setCommonAttributesForTextField:self.mobileNumber];
    [self.contentView addSubview:self.mobileNumber];
}

- (void)setCommonAttributesForTextField:(TBMTextField *)tf{
    tf.delegate = self;
    tf.font = [UIFont systemFontOfSize:TBMRegisterTextFieldFontSize];
    tf.borderStyle = UITextBorderStyleRoundedRect;
    tf.autocorrectionType = UITextAutocorrectionTypeNo;
    tf.layer.borderWidth = 1.0;
    tf.layer.borderColor = [[UIColor colorWithRed:0.25f green:0.25f blue:0.25f alpha:1.0f] CGColor];
    tf.layer.cornerRadius = 8.0;
    tf.layer.masksToBounds = YES;
}

- (void)addSubmit{
    CGRect f;
    f.origin.x = TBMRegisterMargin;
    f.origin.y = self.plus.frame.origin.y + self.plus.frame.size.height + TBMRegisterVertSpacing;
    f.size.width = self.screenWidth - 2*TBMRegisterMargin;
    f.size.height = TBMRegisterTextFieldHeight;
    self.submit = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [self.submit addTarget:self action:@selector(submitClick) forControlEvents:UIControlEventTouchUpInside];
    self.submit.frame = f;
    [self setCommonAttributesForButton:self.submit];
    [self.submit setTitle:@"Submit" forState:UIControlStateNormal];
    [self.contentView addSubview:self.submit];
}

- (void)addSpinner{
    CGRect f;
    f.origin.x = (self.screenWidth/2) - 50;
    f.origin.y = self.submit.frame.origin.y + self.submit.frame.size.height + TBMRegisterVertSpacing/2;
    f.size.width = 100;
    f.size.height = TBMRegisterTextFieldHeight;
    self.spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    self.spinner.frame = f;
    [self.contentView addSubview:self.spinner];
    [self.spinner stopAnimating];
}

- (void)addDebug{
    CGRect f;
    f.origin.x = TBMRegisterMargin;
    f.origin.y = self.spinner.frame.origin.y + self.spinner.frame.size.height + TBMRegisterVertSpacing/2;
    f.size.width = self.screenWidth - 2*TBMRegisterMargin;
    f.size.height = TBMRegisterTextFieldHeight;
    self.debug = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [self.debug addTarget:self action:@selector(debugClick) forControlEvents:UIControlEventTouchUpInside];
    self.debug.frame = f;
    [self.debug setTitle:@"Debug" forState:UIControlStateNormal];
    [self setCommonAttributesForButton:self.debug];
    [self.contentView addSubview:self.debug];
}

- (void)setCommonAttributesForButton:(UIButton *)b{
    [b.titleLabel setFont:[UIFont systemFontOfSize:22]];
    b.titleLabel.textAlignment = NSTextAlignmentCenter;
}

- (void)setScrollViewSize{
    CGSize s;
    s.width = self.screenWidth;
    s.height = [[UIScreen mainScreen] bounds].size.height + self.plus.frame.origin.y;
    self.scrollView.contentSize = s;
}

- (void)addNextFields{
    self.firstName.nextField = self.lastName;
    self.lastName.nextField = self.countryCode;
    self.countryCode.nextField = self.mobileNumber;
    self.mobileNumber.nextField = nil;
}

@end
