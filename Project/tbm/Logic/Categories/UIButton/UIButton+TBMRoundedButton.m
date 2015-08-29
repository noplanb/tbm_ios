//
// Created by Maksim Bazarov on 22.05.15.
// Copyright (c) 2015 No Plan B. All rights reserved.
//

#import "UIButton+TBMRoundedButton.h"

@implementation UIButton (TBMRoundedButton)

- (void)setupRoundedButtonWithColor:(UIColor *)color {
    self.layer.borderColor = [color CGColor];
    self.layer.borderWidth = 1.f;
    self.layer.cornerRadius = 5.f;
    [self setTitleColor:color forState:UIControlStateNormal];
}

@end