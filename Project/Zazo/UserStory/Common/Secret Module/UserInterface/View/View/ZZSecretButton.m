//
//  ZZSecretButton.m
//  Zazo
//
//  Created by ANODA on 8/28/15.
//  Copyright (c) 2015 No Plan B. All rights reserved.
//

#import "ZZSecretButton.h"

@implementation ZZSecretButton

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        [self setTitleColor:[ZZColorTheme shared].secretScreenBlueColor forState:UIControlStateNormal];
        self.layer.borderWidth = 2 / [UIScreen mainScreen].scale;
        self.layer.cornerRadius = 6;
        self.layer.borderColor = [ZZColorTheme shared].secretScreenBlueColor.CGColor;
    }
    return self;
}

@end
