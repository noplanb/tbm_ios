//
//  ZZEditFriendCell.m
//  Zazo
//
//  Created by ANODA on 8/25/15.
//  Copyright (c) 2015 ANODA. All rights reserved.
//

#import "ZZEditFriendCell.h"
#import "ZZEditFriendCellViewModel.h"

@interface ZZEditFriendCell ()

@property (nonatomic, strong) UIImageView* photoImageView;
@property (nonatomic, strong) UILabel* nameLabel;
@property (nonatomic, strong) UILabel* phoneNumberLabel;
@property (nonatomic, strong) UIView* separator;
@property (nonatomic, strong) ZZEditFriendCellViewModel* currentModel;

@end

@implementation ZZEditFriendCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self separator];
        [self.deleteAndRestoreButton addTarget:self action:@selector(deleteButtonSelected) forControlEvents:UIControlEventTouchUpInside];
    }
    return self;
}

- (void)updateWithModel:(ZZEditFriendCellViewModel *)model
{
    self.nameLabel.text = [model username];
    self.phoneNumberLabel.text = [model phoneNumber];
    [model updatePhotoImageView:self.photoImageView];
    [model updateDeleteButton:self.deleteAndRestoreButton];
    self.backgroundColor = [model cellBackgroundColor];
    
    self.currentModel = model;
}

- (void)deleteButtonSelected
{
    [self.currentModel deleteAndRestoreButtonSelected];
}

#pragma mark - Lazy load

- (UIImageView*)photoImageView
{
    if (!_photoImageView)
    {
        _photoImageView = [UIImageView new];
        _photoImageView.clipsToBounds = YES;
        _photoImageView.contentMode = UIViewContentModeScaleAspectFit;
        _photoImageView.backgroundColor = [UIColor clearColor];
        [self.contentView addSubview:_photoImageView];
        
        [_photoImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.contentView).offset(8);
            make.height.width.equalTo(@40);
            make.centerY.equalTo(self.contentView);
        }];
    }
    return _photoImageView;
}

- (UILabel *)nameLabel
{
    if (!_nameLabel)
    {
        _nameLabel = [UILabel new];
        _nameLabel.font = [UIFont an_meduimFontWithSize:18];
        _nameLabel.highlightedTextColor = [UIColor whiteColor];
        _nameLabel.textColor = [UIColor an_colorWithHexString:@"202020"];
        [self addSubview:_nameLabel];
        
        [_nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.photoImageView.mas_right).offset(10);
            make.top.equalTo(self.photoImageView.mas_top);
            make.right.equalTo(self.deleteAndRestoreButton.mas_left).offset(-5);
            make.bottom.equalTo(self.contentView.mas_centerY);
        }];
    }
    return _nameLabel;
}

- (UILabel *)phoneNumberLabel
{
    if (!_phoneNumberLabel)
    {
        _phoneNumberLabel = [UILabel new];
        _phoneNumberLabel.font = [UIFont an_regularFontWithSize:15];
        _phoneNumberLabel.highlightedTextColor = [UIColor whiteColor];
        _phoneNumberLabel.textColor = [UIColor colorWithRed:0.45 green:0.45 blue:0.42 alpha:1];
        [self addSubview:_phoneNumberLabel];
        
        [_phoneNumberLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.equalTo(self.nameLabel);
            make.top.equalTo(self.nameLabel.mas_bottom);
            make.bottom.equalTo(self.contentView.mas_bottom).offset(-10);
        }];
    }
    return _phoneNumberLabel;
}

- (UIButton *)deleteAndRestoreButton
{
    if (!_deleteAndRestoreButton)
    {
        _deleteAndRestoreButton = [UIButton new];
        [_deleteAndRestoreButton setTitleColor:[UIColor an_colorWithHexString:@"202020"] forState:UIControlStateNormal];
        _deleteAndRestoreButton.titleLabel.font = [UIFont an_regularFontWithSize:15];
        [self.contentView addSubview:_deleteAndRestoreButton];
        
        [_deleteAndRestoreButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(self.contentView);
            make.height.equalTo(@40);
            make.width.equalTo(@60);
            make.right.equalTo(self.contentView).with.offset(-8);
        }];
    }
    
    return _deleteAndRestoreButton;
}

- (UIView *)separator
{
    if (!_separator)
    {
        _separator = [UIView new];
        _separator.backgroundColor = [UIColor darkGrayColor];
        [self.contentView addSubview:_separator];
        
        CGFloat separatorHeight = 1 / [UIScreen mainScreen].scale;
        [_separator mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.equalTo(self);
            make.bottom.equalTo(self.contentView.mas_bottom);
            make.height.equalTo(@(separatorHeight));
        }];
    }
    return _separator;
}

@end
