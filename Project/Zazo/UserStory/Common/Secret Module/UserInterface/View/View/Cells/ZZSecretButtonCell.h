//
//  ZZSecretButtonCell.h
//  Zazo
//
//  Created by ANODA on 8/28/15.
//  Copyright (c) 2015 No Plan B. All rights reserved.
//

#import "ANTableViewCell.h"
#import "ZZSecretButtonCellViewModel.h"
#import "ZZSecretButton.h"

@interface ZZSecretButtonCell : ANTableViewCell <ANModelTransfer>

@property (nonatomic, strong) ZZSecretButton* button;
@property (nonatomic, strong) UILabel* titleLabel;

@end
