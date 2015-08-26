//
//  ZZSecretLabelsInfoView.m
//  Zazo
//
//  Created by ANODA on 23/08/15.
//  Copyright (c) 2015 ANODA. All rights reserved.
//

#import "ZZSecretScreenLabelsInfoView.h"

@implementation ZZSecretScreenLabelsInfoView

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        [self versionLabel];
        [self firstNameLabel];
        [self lastNameLabel];
        [self phoneNumberLabel];
        [self addressTextField];
    }
    return self;
}

- (UILabel *)versionLabel
{
    if (!_versionLabel)
    {
        _versionLabel = [UILabel new];
        _versionLabel.text = @"Version:";
        
        [self addSubview:_versionLabel];
        [_versionLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self);
            make.right.equalTo(self);
            make.left.equalTo(self).with.offset(labelLeftPadding());
            make.height.equalTo(@(labelHeight()));
        }];
    }
    return _versionLabel;
}

- (UILabel *)firstNameLabel
{
    if (!_firstNameLabel)
    {
        _firstNameLabel = [UILabel new];
        _firstNameLabel.text = @"First Name";
        [self addSubview:_firstNameLabel];
        
        [_firstNameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.versionLabel.mas_bottom);
            make.left.equalTo(self.versionLabel.mas_left);
            make.right.equalTo(self);
            make.height.equalTo(self.versionLabel.mas_height);
        }];
    }
    return _firstNameLabel;
}

- (UILabel *)lastNameLabel
{
    if (!_lastNameLabel)
    {
        _lastNameLabel = [UILabel new];
        _lastNameLabel.text = @"Last Name:";
        [self addSubview:_lastNameLabel];
        
        [_lastNameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.firstNameLabel.mas_bottom);
            make.left.equalTo(self.versionLabel.mas_left);
            make.right.equalTo(self);
            make.height.equalTo(self.versionLabel.mas_height);
        }];
    }
    return _lastNameLabel;
}

- (UILabel *)phoneNumberLabel
{
    if (!_phoneNumberLabel)
    {
        _phoneNumberLabel = [UILabel new];
        _phoneNumberLabel.text = @"Phone:";
        [self addSubview:_phoneNumberLabel];
        
        [_phoneNumberLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.lastNameLabel.mas_bottom);
            make.left.equalTo(self.versionLabel.mas_left);
            make.right.equalTo(self);
            make.height.equalTo(self.versionLabel.mas_height);
        }];
    }
    return  _phoneNumberLabel;
}

- (ZZGrayBorderTextField *)addressTextField
{
    if (!_addressTextField)
    {
        _addressTextField = [ZZGrayBorderTextField new];
        _addressTextField.text = @"http://";
        _addressTextField.enabled = NO;
        
        [self addSubview:_addressTextField];
        
        [_addressTextField mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.phoneNumberLabel.mas_bottom);
            make.left.equalTo(self.versionLabel.mas_left);
            make.right.equalTo(self).with.offset(-labelLeftPadding());
            make.height.equalTo(@(serverAddressTextFieldHeigh()));
        }];
    }
    return _addressTextField;
}

@end
