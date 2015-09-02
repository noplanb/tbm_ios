//
//  ZZAuthRegistrationView.m
//  Zazo
//
//  Created by ANODA on 10/08/15.
//  Copyright (c) 2015 ANODA. All rights reserved.
//

#import "ZZAuthRegistrationView.h"

#pragma mark - Content height
static CGFloat const kContentHeight = 350;

#pragma mark - ImageView Constants
static CGFloat const kTitleImageViewWidth = 136;
static CGFloat const kTitleImageViewHeight = 38;

#pragma mark - TextField Constants
static CGFloat const kFirstNameTopPadding = 40;
static CGFloat const kTextFieldSideScaleValue = 9;
static CGFloat const kTextFieldHeight = 40;
static CGFloat const kBetweenElementPadding = 10.0;

#pragma mark - Phone Code TextField
static CGFloat const kPhoneCodeTextFieldWidthScaleValue =5.5;

#pragma mark - Plus Label
static CGFloat const kPlusLabelWidthScaleValue = 4;

#pragma mark - SignIn Button
static CGFloat const kSignInButtonTopPadding = 40;
static CGFloat const kSignInButtonCornerRadius = 4;
static CGFloat const kSignInButtonHeight = 50;
static CGFloat const kSignInButtonWidthScaleValue = 3;

#pragma mark - Phone Code
static CGFloat const kCodeLableLeftPadding = 1;


@interface ZZAuthRegistrationView ()

@property (nonatomic, strong) UITapGestureRecognizer* tapRecognizer;
@property (nonatomic, assign) CGFloat textFieldSidePadding;

@end

@implementation ZZAuthRegistrationView

- (instancetype)init
{
    if (self = [super init])
    {
        self.textFieldSidePadding = CGRectGetWidth([UIScreen mainScreen].bounds)/kTextFieldSideScaleValue;
        [self titleImageView];
        [self firstNameTextField];
        [self lastNameTextField];
        [self phoneCodeTextField];
        [self phoneNumberTextField];
        [self signInButton];
        [self countryCodeLabel];
        [self addRecognizer];
        
#ifdef DEBUG_LOGIN_USER
        self.firstNameTextField.text = @"Elena";
        self.lastNameTextField.text = @"M";
        self.phoneCodeTextField.text = @"380";
        self.phoneNumberTextField.text = @"662578748";
#endif
    }
    return self;
}

- (UIImageView *)titleImageView
{
    if (!_titleImageView)
    {
        _titleImageView = [UIImageView new];
        _titleImageView.image = [UIImage imageNamed:@"logotype"];
        [self addSubview:_titleImageView];
        [_titleImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self.mas_centerX);
            make.width.equalTo(@(kTitleImageViewWidth));
            make.height.equalTo(@(kTitleImageViewHeight));
            make.top.equalTo(self).with.offset((CGRectGetHeight([UIScreen mainScreen].bounds) - kContentHeight)/2);
        }];
    }
    
    return _titleImageView;
}


#pragma mark - Auth Text Fields


- (ZZAuthTextField *)firstNameTextField
{
    if (!_firstNameTextField)
    {
        _firstNameTextField = [ZZAuthTextField new];
        _firstNameTextField.userInteractionEnabled = YES;
        [_firstNameTextField updatePlaceholderWithText:NSLocalizedString(@"auth-controller.firstname.placeholder.title",nil)];
        _firstNameTextField.accessibilityLabel = @"firstName";
        [self addSubview:_firstNameTextField];
        
        [_firstNameTextField mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.titleImageView.mas_bottom).with.offset(kFirstNameTopPadding);
            make.centerX.equalTo(self.mas_centerX);
            make.left.equalTo(self).with.offset(self.textFieldSidePadding);
            make.right.equalTo(self).with.offset(-self.textFieldSidePadding);
            make.height.equalTo(@(kTextFieldHeight));
        }];
    }
    return _firstNameTextField;
}

- (ZZAuthTextField *)lastNameTextField
{
    if (!_lastNameTextField)
    {
        _lastNameTextField = [ZZAuthTextField new];
        [_lastNameTextField updatePlaceholderWithText:NSLocalizedString(@"auth-controller.lastname.placeholder.title", nil)];
        _lastNameTextField.accessibilityLabel = @"lastName";
        [self addSubview:_lastNameTextField];
        
        [_lastNameTextField mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.firstNameTextField.mas_bottom).with.offset(kBetweenElementPadding);
            make.centerX.equalTo(self.mas_centerX);
            make.left.equalTo(self).with.offset(self.textFieldSidePadding);
            make.right.equalTo(self).with.offset(-self.textFieldSidePadding);
            make.height.equalTo(@(kTextFieldHeight));
        }];
    }
    
    return _lastNameTextField;
}

- (ZZAuthTextField *)phoneCodeTextField
{
    if (!_phoneCodeTextField)
    {
        _phoneCodeTextField = [ZZAuthTextField new];
        _phoneCodeTextField.keyboardType = UIKeyboardTypePhonePad;
        _phoneCodeTextField.accessibilityLabel = @"phoneCode";
        [self addSubview:_phoneCodeTextField];
        
        [_phoneCodeTextField mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.lastNameTextField.mas_left);
            make.width.equalTo(@(CGRectGetWidth([UIScreen mainScreen].bounds)/kPhoneCodeTextFieldWidthScaleValue));
            make.height.equalTo(@(kTextFieldHeight));
            make.top.equalTo(self.lastNameTextField.mas_bottom).with.offset(kBetweenElementPadding);
            make.right.equalTo(self.phoneNumberTextField.mas_left).with.offset(-kBetweenElementPadding);
        }];
        
        
        
        UILabel* plusLabel = [UILabel new];
        plusLabel.textColor = [UIColor whiteColor];
        plusLabel.text = @"+";
        [_phoneCodeTextField addSubview:plusLabel];
        
        [plusLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.bottom.equalTo(_phoneCodeTextField);
            make.width.equalTo(@((CGRectGetWidth([UIScreen mainScreen].bounds)/kPhoneCodeTextFieldWidthScaleValue)/kPlusLabelWidthScaleValue));
            make.left.equalTo(@(kCodeLableLeftPadding));
        }];
    }
    
    return _phoneCodeTextField;
}

- (ZZAuthTextField *)phoneNumberTextField
{
    if (!_phoneNumberTextField)
    {
        _phoneNumberTextField = [ZZAuthTextField new];
        _phoneNumberTextField.keyboardType = UIKeyboardTypePhonePad;
        [_phoneNumberTextField updatePlaceholderWithText:NSLocalizedString(@"auth-controller.phone.placeholder.title", nil)];
        _phoneNumberTextField.accessibilityLabel = @"phoneNumber";
        [self addSubview:_phoneNumberTextField];
        
        [_phoneNumberTextField mas_makeConstraints:^(MASConstraintMaker *make) {
            make.height.equalTo(self.phoneCodeTextField);
            make.right.equalTo(self.lastNameTextField.mas_right);
            make.top.equalTo(self.phoneCodeTextField);
        }];
    }
    
    return _phoneNumberTextField;
}

- (UIButton *)signInButton
{
    if (!_signInButton)
    {
        _signInButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_signInButton setTitle:NSLocalizedString(@"auth-controller.signIn.button.title", nil) forState:UIControlStateNormal];
        _signInButton.backgroundColor = [UIColor blackColor];
        _signInButton.layer.cornerRadius = kSignInButtonCornerRadius;
        _signInButton.accessibilityLabel = @"SignIn";
        [self addSubview:_signInButton];

        [_signInButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.phoneNumberTextField.mas_bottom).with.offset(kSignInButtonTopPadding);
            make.centerX.equalTo(self.mas_centerX);
            make.width.equalTo(@(CGRectGetWidth([UIScreen mainScreen].bounds)/kSignInButtonWidthScaleValue));
            make.height.equalTo(@(kSignInButtonHeight));
        }];

    }
    return _signInButton;
}

- (UILabel *)countryCodeLabel
{
    if (!_countryCodeLabel)
    {
        _countryCodeLabel = [UILabel new];
        _countryCodeLabel.textColor = [UIColor whiteColor];
        _countryCodeLabel.numberOfLines = 0;
        _countryCodeLabel.textAlignment = NSTextAlignmentCenter;
        _countryCodeLabel.text = NSLocalizedString(@"auth-controller.country.code.example.title", nil);
        _countryCodeLabel.font = [UIFont an_lightFontWithSize:9];
        [self addSubview:_countryCodeLabel];
        
        [_countryCodeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.firstNameTextField.mas_left);
            make.top.equalTo(self.phoneCodeTextField.mas_bottom);
            make.width.equalTo(self.phoneCodeTextField.mas_width);
            make.height.equalTo(self.phoneCodeTextField.mas_height);
        }];
    }
    
    return _countryCodeLabel;
}

- (void)addRecognizer
{
    self.tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideKeyboard)];
    [self addGestureRecognizer:self.tapRecognizer];
}

- (void)hideKeyboard
{
    [self endEditing:YES];
}

@end
