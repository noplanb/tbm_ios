//
//  ZZAuthRegistrationView.h
//  Zazo
//
//  Created by ANODA on 10/08/15.
//  Copyright (c) 2015 ANODA. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZZAuthTextField.h"

@interface ZZAuthRegistrationView : UIView

@property (nonatomic, strong) UIImageView* titleImageView;
@property (nonatomic, strong) ZZAuthTextField* firstNameTextField;
@property (nonatomic, strong) ZZAuthTextField* lastNameTextField;
@property (nonatomic, strong) ZZAuthTextField* phoneCodeTextField;
@property (nonatomic, strong) ZZAuthTextField* phoneNumberTextField;
@property (nonatomic, strong) UIButton* signInButton;
@property (nonatomic, strong) UILabel* countryCodeLabel;

@end
