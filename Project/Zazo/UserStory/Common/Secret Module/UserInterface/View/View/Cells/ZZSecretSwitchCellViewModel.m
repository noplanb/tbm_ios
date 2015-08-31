//
//  ZZSecretSwitchCellViewModel.m
//  Zazo
//
//  Created by ANODA on 8/28/15.
//  Copyright (c) 2015 No Plan B. All rights reserved.
//

#import "ZZSecretSwitchCellViewModel.h"

@implementation ZZSecretSwitchCellViewModel

- (void)switchValueChanged
{
    self.switchState = !self.switchState;
    [self.delegate viewModel:self updatedSwitchValueTo:self.switchState];
}

@end
