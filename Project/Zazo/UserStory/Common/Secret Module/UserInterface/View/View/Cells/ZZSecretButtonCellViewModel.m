//
//  ZZSecretButtonCellViewModel.m
//  Zazo
//
//  Created by ANODA on 8/28/15.
//  Copyright (c) 2015 No Plan B. All rights reserved.
//

#import "ZZSecretButtonCellViewModel.h"

@implementation ZZSecretButtonCellViewModel

- (void)buttonSelected
{
    [self.delegate buttonSelectedWithType:self.type];
}

@end
