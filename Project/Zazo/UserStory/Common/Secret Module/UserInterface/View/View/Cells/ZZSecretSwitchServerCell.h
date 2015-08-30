//
//  ZZSecretSwitchServerCell.h
//  Zazo
//
//  Created by ANODA on 8/29/15.
//  Copyright (c) 2015 No Plan B. All rights reserved.
//

#import "ANTableViewCell.h"
#import "ZZSecretSwitchServerCellViewModel.h"

@interface ZZSecretSwitchServerCell : ANTableViewCell <ANModelTransfer>

@property (nonatomic, strong) UISegmentedControl* serverTypeControl;

@end
