//
//  ZZSecretLabelsInfoView.h
//  Zazo
//
//  Created by ANODA on 23/08/15.
//  Copyright (c) 2015 ANODA. All rights reserved.
//

#import "ZZSecretScreenViewSizes.h"
#import "ZZGrayBorderTextField.h"

@interface ZZSecretScreenLabelsInfoView : UIView

@property (nonatomic, strong) UILabel* versionLabel;
@property (nonatomic, strong) UILabel* firstNameLabel;
@property (nonatomic, strong) UILabel* lastNameLabel;
@property (nonatomic, strong) UILabel* phoneNumberLabel;
@property (nonatomic, strong) ZZGrayBorderTextField* addressTextField;

@end
