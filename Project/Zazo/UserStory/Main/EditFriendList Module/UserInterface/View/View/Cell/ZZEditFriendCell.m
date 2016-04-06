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
@property (nonatomic, strong) UILabel *abbrevationLabel;
@property (nonatomic, strong) UILabel* nameLabel;
//@property (nonatomic, strong) UILabel* phoneNumberLabel;
@property (nonatomic, strong) UIView* separator;

@property (nonatomic, strong) ZZEditFriendCellViewModel* currentModel;

@end

@implementation ZZEditFriendCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self)
    {
        [self separator];
        self.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    return self;
}

- (void)updateWithModel:(ZZEditFriendCellViewModel *)model
{
    //    self.phoneNumberLabel.text = [model phoneNumber];
    self.nameLabel.text = [model username];
    self.deleteSwitch.enabled = ![model isUpdating];
    self.abbrevationLabel.text = [model abbreviation];
    
    [model updatePhotoImageView:self.photoImageView];
    [model updateSwitch:self.deleteSwitch];
    
    self.currentModel = model;
}

- (void)_deleteButtonSelected
{
    self.deleteSwitch.enabled = NO;
    [self.currentModel switchStateChanged];
}

#pragma mark - Lazy load

- (UIImageView*)photoImageView
{
    if (!_photoImageView)
    {
        _photoImageView = [UIImageView new];
        _photoImageView.clipsToBounds = YES;
        _photoImageView.contentMode = UIViewContentModeScaleAspectFill;
        _photoImageView.layer.cornerRadius = 18;
        
        [self.contentView addSubview:_photoImageView];
        
        [_photoImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.contentView).offset(28);
            make.height.width.equalTo(@36);
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
        _nameLabel.font = [UIFont zz_regularFontWithSize:18];
        _nameLabel.highlightedTextColor = [UIColor whiteColor];
        _nameLabel.textColor = [UIColor an_colorWithHexString:@"202020"];
        _nameLabel.adjustsFontSizeToFitWidth = YES;
        [self addSubview:_nameLabel];
        
        [_nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.photoImageView.mas_right).offset(12);
            make.right.equalTo(self.deleteSwitch.mas_left).offset(-5);
            make.centerY.equalTo(self);
        }];
    }
    return _nameLabel;
}

//- (UILabel *)phoneNumberLabel
//{
//    if (!_phoneNumberLabel)
//    {
//        _phoneNumberLabel = [UILabel new];
//        _phoneNumberLabel.font = [UIFont zz_regularFontWithSize:15];
//        _phoneNumberLabel.highlightedTextColor = [UIColor whiteColor];
//        _phoneNumberLabel.textColor = [UIColor colorWithRed:0.45 green:0.45 blue:0.42 alpha:1];
//        [self addSubview:_phoneNumberLabel];
//        
//        [_phoneNumberLabel mas_makeConstraints:^(MASConstraintMaker *make) {
//            make.left.right.equalTo(self.nameLabel);
//            make.top.equalTo(self.nameLabel.mas_bottom);
//            make.bottom.equalTo(self.contentView.mas_bottom).offset(-10);
//        }];
//    }
//    return _phoneNumberLabel;
//}

- (UISwitch *)deleteSwitch
{
    if (!_deleteSwitch)
    {
        _deleteSwitch = [UISwitch new];
        
        [_deleteSwitch addTarget:self action:@selector(_deleteButtonSelected) forControlEvents:UIControlEventValueChanged];
        [self.contentView addSubview:_deleteSwitch];
        
        [_deleteSwitch mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(self.contentView);
            make.right.equalTo(self.contentView).with.offset(-12);
        }];
    }
    
    return _deleteSwitch;
}

- (UIView *)separator
{
    if (!_separator)
    {
        _separator = [UIView new];
        _separator.backgroundColor = [UIColor lightGrayColor];
        [self.contentView addSubview:_separator];
        
        CGFloat separatorHeight = 1 / [UIScreen mainScreen].scale;
        
        [_separator mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.nameLabel);
            make.right.equalTo(self);
            make.bottom.equalTo(self.contentView.mas_bottom);
            make.height.equalTo(@(separatorHeight));
        }];
    }
    return _separator;
}

- (UILabel *)abbrevationLabel
{
    if (!_abbrevationLabel)
    {
        _abbrevationLabel = [UILabel new];
        _abbrevationLabel.font = [UIFont zz_regularFontWithSize:18];
        _abbrevationLabel.textColor = [UIColor whiteColor];
        _abbrevationLabel.textAlignment = NSTextAlignmentCenter;
        [self.contentView addSubview:_abbrevationLabel];
        
        [_abbrevationLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.center.equalTo(self.photoImageView);
        }];
    }
    return _abbrevationLabel;
    
}

@end
