//
//  ZZSecretScreenNavigationTheme.m
//  Zazo
//
//  Created by ANODA on 24/08/15.
//  Copyright (c) 2015 ANODA. All rights reserved.
//

#import "ZZSecretScreenNavigationTheme.h"
#import "ZZSecretScreenVC.h"

@implementation ZZSecretScreenNavigationTheme

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        self.backgroundColor = [ZZColorTheme shared].secretScreenHeaderColor;
        self.tintColor = [ZZColorTheme shared].secretScreenBlueColor;
        self.titleFontColor = [ZZColorTheme shared].secretScreenBlueColor;
        self.titleFont = [UIFont an_boldFontWithSize:16];
        self.backgroundImage = [UIImage new];
        self.containerClasses = @[[ZZSecretScreenVC class]];
        self.hideShadow = YES;
    }
    return self;
}

@end
