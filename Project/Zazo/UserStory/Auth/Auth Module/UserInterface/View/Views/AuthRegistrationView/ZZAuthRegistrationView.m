//
//  ZZAuthRegistrationView.m
//  Zazo
//
//  Created by ANODA on 10/08/15.
//  Copyright (c) 2015 ANODA. All rights reserved.
//

#import "ZZAuthRegistrationView.h"
#import "UIImage+PDF.h"

#pragma mark - TextField Constants

static CGFloat const kFirstNameTopPadding = 40;
static CGFloat const kTextFieldSideScaleValue = 9;
static CGFloat const kTextFieldHeight = 45;
static CGFloat const kBetweenElementPadding = 10.0;


#pragma mark - Phone Code TextField

static CGFloat const kPhoneCodeTextFieldWidthScaleValue = 4;


#pragma mark - SignIn Button

static CGFloat const kSignInButtonTopPaddingIphone4 = 15;
static CGFloat const kSignInButtonTopPadding = 40;

static CGFloat const kSignInButtonCornerRadius = 4;
static CGFloat const kSignInButtonHeight = 55;

#pragma mark - Phone Code
static CGFloat const kCodeLableLeftPadding = 3;


@interface ZZAuthRegistrationView ()

@property (nonatomic, strong) UITapGestureRecognizer *tapRecognizer;
@property (nonatomic, strong) UILabel *plusLabel;
@property (nonatomic, strong) UILabel *countryCodeLabel;

@end

@implementation ZZAuthRegistrationView

- (instancetype)init
{
    if (self = [super init])
    {
        [self titleImageView];
        [self plusLabel];

        [self signInButton];
        [self countryCodeLabel];
        [self addRecognizer];

    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];

    self.countryCodeLabel.preferredMaxLayoutWidth = self.phoneCodeTextField.bounds.size.width;
    self.plusLabel.frame = CGRectMake(kCodeLableLeftPadding, 0, 10, self.phoneCodeTextField.height);
}

- (CGFloat)_textFieldSidePadding
{
    return CGRectGetWidth([UIScreen mainScreen].bounds) / kTextFieldSideScaleValue;
}

- (UIImageView *)titleImageView
{
    if (!_titleImageView)
    {
        _titleImageView = [UIImageView new];
        CGFloat scale = [UIScreen mainScreen].scale;
        UIImage *logo = [UIImage imageWithPDFNamed:@"app_logo" atHeight:IS_IPAD ? 60 : 20 * scale];
        _titleImageView.image = [logo an_imageByTintingWithColor:[UIColor whiteColor]];
        [_titleImageView sizeToFit];
        [self addSubview:_titleImageView];
        [_titleImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self.mas_centerX);
            make.top.equalTo(self).offset(106);
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
        [_firstNameTextField updatePlaceholderWithText:NSLocalizedString(@"auth-controller.firstname.placeholder.title", nil)];
        _firstNameTextField.accessibilityLabel = @"firstName";
        [self addSubview:_firstNameTextField];

        [_firstNameTextField mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.titleImageView.mas_bottom).with.offset(kFirstNameTopPadding);
            make.centerX.equalTo(self.mas_centerX);
            make.left.equalTo(self).with.offset([self _textFieldSidePadding]);
            make.right.equalTo(self).with.offset(-[self _textFieldSidePadding]);
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
            make.left.equalTo(self).with.offset([self _textFieldSidePadding]);
            make.right.equalTo(self).with.offset(-[self _textFieldSidePadding]);
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
            make.height.equalTo(@(kTextFieldHeight));
            make.top.equalTo(self.lastNameTextField.mas_bottom).with.offset(kBetweenElementPadding);
            make.right.equalTo(self.phoneNumberTextField.mas_left).with.offset(-kBetweenElementPadding);
            make.width.equalTo(@(CGRectGetWidth([UIScreen mainScreen].bounds) / kPhoneCodeTextFieldWidthScaleValue));
        }];
    }
    return _phoneCodeTextField;
}

- (UILabel *)plusLabel
{
    if (!_plusLabel)
    {
        _plusLabel = [UILabel new];
        _plusLabel.textColor = [UIColor whiteColor];
        _plusLabel.text = @"+";
        _plusLabel.font = [UIFont zz_lightFontWithSize:18];
        [self.phoneCodeTextField addSubview:_plusLabel];
    }
    return _plusLabel;
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
        _signInButton.titleLabel.font = [UIFont zz_regularFontWithSize:21];
        _signInButton.backgroundColor = [UIColor an_colorWithHexString:@"#2F2E28"];
        _signInButton.layer.cornerRadius = kSignInButtonCornerRadius;
        _signInButton.accessibilityLabel = @"SignIn";
        [self addSubview:_signInButton];

        [_signInButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.countryCodeLabel.mas_bottom).with.offset(IS_IPHONE_4 ? kSignInButtonTopPaddingIphone4 : kSignInButtonTopPadding);
            make.centerX.equalTo(self.mas_centerX);
            make.width.equalTo(@(CGRectGetWidth([UIScreen mainScreen].bounds) / 2));
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


        NSString *titleString = NSLocalizedString(@"auth-controller.country.code.example.title", nil);
        NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:titleString];
        NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
        [paragraphStyle setLineSpacing:5];
        [attributedString addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, [titleString length])];
        _countryCodeLabel.attributedText = attributedString;
        _countryCodeLabel.font = [UIFont zz_regularFontWithSize:11];
        _countryCodeLabel.textAlignment = NSTextAlignmentCenter;
        [self addSubview:_countryCodeLabel];

        [_countryCodeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self.phoneCodeTextField);
            make.top.equalTo(self.phoneCodeTextField.mas_bottom).with.offset(2);
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
