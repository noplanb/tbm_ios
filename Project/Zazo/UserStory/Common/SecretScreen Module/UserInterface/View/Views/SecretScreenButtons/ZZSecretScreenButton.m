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
        [self setTitleColor:[ZZColorTheme shared].secretScreenBlueColor forState:UIControlStateNormal];
        self.layer.borderWidth = 2/[UIScreen mainScreen].scale;
        self.layer.cornerRadius = 6;
        self.layer.borderColor = [ZZColorTheme shared].secretScreenBlueColor.CGColor;
    }
    return self;
}

@end
