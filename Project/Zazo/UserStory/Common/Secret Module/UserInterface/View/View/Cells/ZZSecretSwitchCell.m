//
//  ZZSecretSwitchCell.m
//  Zazo
//
//  Created by ANODA on 8/28/15.
//  Copyright (c) 2015 No Plan B. All rights reserved.
//

#import "ZZSecretSwitchCell.h"

static NSInteger const kDefaultSwitchWidth = 51;
static NSInteger const kDefaultSwitchHeight = 31;

@interface ZZSecretSwitchCell ()

@property (nonatomic, strong) ZZSecretSwitchCellViewModel *currentModel;
@property (nonatomic, strong) UISwitch *switchControl;

@end

@implementation ZZSecretSwitchCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self)
    {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    return self;
}

- (void)updateWithModel:(ZZSecretSwitchCellViewModel *)model
{
    self.textLabel.text = model.title;
    self.switchControl.on = model.switchState;
    self.currentModel = model;
}


#pragma mark - Actions

- (void)switchChanged
{
    [self.currentModel switchValueChanged];
}


#pragma mark - Lazy Load

- (UISwitch *)switchControl
{
    if (!_switchControl)
    {
        _switchControl = [UISwitch new];
        [_switchControl addTarget:self action:@selector(switchChanged) forControlEvents:UIControlEventValueChanged];
        [self.contentView addSubview:_switchControl];

        [_switchControl mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(self.contentView.mas_centerY);
            make.width.equalTo(@(kDefaultSwitchWidth));
            make.height.equalTo(@(kDefaultSwitchHeight));
            make.right.equalTo(self.contentView).offset(-5);
        }];
    }
    return _switchControl;
}

@end
