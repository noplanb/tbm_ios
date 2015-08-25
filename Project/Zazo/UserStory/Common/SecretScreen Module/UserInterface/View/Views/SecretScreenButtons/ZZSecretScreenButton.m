//
//  ZZSecretScreenButton.m
//  Zazo
//
//  Created by ANODA on 21/08/15.
//  Copyright (c) 2015 ANODA. All rights reserved.
//

#import "ZZSecretScreenButton.h"

@implementation ZZSecretScreenButton

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        [self setTitleColor:[ANAppColorTheme shared].secretScreenBlueColor forState:UIControlStateNormal];
        self.layer.borderWidth = 2/[UIScreen mainScreen].scale;
        self.layer.cornerRadius = 6;
        self.layer.borderColor = [ANAppColorTheme shared].secretScreenBlueColor.CGColor;
    }
    return self;
}

@end
