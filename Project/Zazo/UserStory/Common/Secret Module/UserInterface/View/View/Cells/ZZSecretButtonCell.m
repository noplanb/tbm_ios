//
//  ZZSecretButtonCell.m
//  Zazo
//
//  Created by ANODA on 8/28/15.
//  Copyright (c) 2015 No Plan B. All rights reserved.
//

typedef NS_ENUM(NSInteger, ZZButtonCellType)
{
    ZZSecretButtonCellTypeButton,
    ZZSecretButtonCellTypeTextAndButton,
    ZZSecretButtonCellTypeButtonText
};

#import "ZZSecretButtonCell.h"

static UIEdgeInsets const kButtonInsets = {5, 5, 5, 5};

@interface ZZSecretButtonCell ()

@property (nonatomic, strong) ZZSecretButtonCellViewModel* currentModel;

@end

@implementation ZZSecretButtonCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self)
    {
        [self button];
        self.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    return self;
}

- (void)updateWithModel:(ZZSecretButtonCellViewModel *)model
{
    self.currentModel = model;
    self.titleLabel.text = model.title;
    [self _updateButtonTitleWithType:model.type];
}

- (void)_updateButtonTitleWithType:(ZZSecretButtonCellType)type
{
    switch (type)
    {
        case ZZSecretButtonCellTypeNone:
        {
            [self _updateConstraintsWithType:ZZSecretButtonCellTypeButtonText];
        } break;
            
        case ZZSecretButtonCellTypeDispatchButton:
        {
            [self _updateConstraintsWithType:ZZSecretButtonCellTypeButton];
            [self.button setTitle:NSLocalizedString(@"secret-controller.dispatch.button.title", nil) forState:UIControlStateNormal];
        } break;
            
        case ZZSecretButtonCellTypeClearData:
        {
            [self _updateConstraintsWithType:ZZSecretButtonCellTypeTextAndButton];
            [self.button setTitle:NSLocalizedString(@"secret-controller.clear.button.title", nil) forState:UIControlStateNormal];
        } break;
            
        case ZZSecretButtonCellTypeResetTutorial:
        {
            [self _updateConstraintsWithType:ZZSecretButtonCellTypeTextAndButton];
            [self.button setTitle:NSLocalizedString(@"secret-controller.reset.button.title", nil) forState:UIControlStateNormal];
        } break;
            
        case ZZSecretButtonCellTypeFeatureOptions:
        {
            [self _updateConstraintsWithType:ZZSecretButtonCellTypeTextAndButton];
            [self.button setTitle:NSLocalizedString(@"secret-controller.open.button.title", nil) forState:UIControlStateNormal];
        } break;
            
        default:
            break;
    }
}

- (void)_updateConstraintsWithType:(ZZButtonCellType)type
{
    switch (type) {
        case ZZSecretButtonCellTypeButton:
        {
            [_button mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.edges.equalTo(self.contentView).with.insets(kButtonInsets);
            }];
        } break;
            
        case ZZSecretButtonCellTypeTextAndButton:
        {
            [_button mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.width.equalTo(@60);
                make.top.bottom.right.equalTo(self.contentView).with.insets(kButtonInsets);
            }];
        } break;
            
        case ZZSecretButtonCellTypeButtonText:
        {
            [_button mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.width.equalTo(@0);
                make.top.bottom.right.equalTo(self.contentView).with.insets(kButtonInsets);
            }];
        } break;
            
        default:
            break;
    }

}


#pragma mark - Actions

- (void)buttonClicked
{
    [self.currentModel buttonSelected];
}

#pragma mark - Lazy Load

- (UILabel *)titleLabel
{
    if (!_titleLabel)
    {
        _titleLabel = [UILabel new];
        _titleLabel.font = [UIFont an_regularFontWithSize:14];
        _titleLabel.highlightedTextColor = [UIColor whiteColor];
        _titleLabel.textColor = [ZZColorTheme shared].baseCellTextColor;
        [self.contentView addSubview:_titleLabel];
        
        [_titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.contentView).offset(10);
            make.top.bottom.equalTo(self);
            make.right.equalTo(self.button).offset(-5);
        }];
    }
    return _titleLabel;
}

- (ZZSecretButton *)button
{
    if (!_button)
    {
        _button = [ZZSecretButton new];
        [_button addTarget:self action:@selector(buttonClicked) forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:_button];
    }
    
    return _button;
}

@end
