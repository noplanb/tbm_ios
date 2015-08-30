//
//  ZZSecretSwitchCell.h
//  Zazo
//
//  Created by ANODA on 8/28/15.
//  Copyright (c) 2015 No Plan B. All rights reserved.
//

#import "ZZBaseSecretCell.h"
#import "ZZSecretSwitchCellViewModel.h"

@interface ZZSecretSwitchCell : ZZBaseSecretCell <ANModelTransfer>

@property (nonatomic, strong) UISwitch* switchControl;

@end
