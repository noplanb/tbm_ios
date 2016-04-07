//
//  ZZContactCell.m
//  Zazo
//
//  Created by ANODA on 8/11/15.
//  Copyright (c) 2015 ANODA. All rights reserved.
//

#import "ZZContactCell.h"

//static CGFloat const kLeftOffset = 20;
//static CGFloat const kSeparatorHeight = 1;


@interface ZZContactCell ()

@property (nonatomic, strong) UIImageView *photoImageView;
@property (nonatomic, strong) UILabel *username;
@property (nonatomic, strong) UILabel *abbrevationLabel;


@end

@implementation ZZContactCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier])
    {
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}


- (void)updateWithModel:(ZZContactCellViewModel *)model
{
    self.username.text = [model username];
    self.abbrevationLabel.text = model.abbreviation;
    
    [model updateImageView:self.photoImageView];
    [self setNeedsUpdateConstraints];
}


#pragma mark - Lazy Load

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
            make.left.equalTo(self.contentView).offset(50);
            make.height.width.equalTo(@36);
            make.centerY.equalTo(self.contentView);
        }];
    }
    return _photoImageView;
}

- (UILabel *)username
{
    if (!_username)
    {
        _username = [UILabel new];
        _username.font = [UIFont zz_regularFontWithSize:18];
        _username.textColor = [UIColor blackColor];
        [self.contentView addSubview:_username];
        
        [_username mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.photoImageView.mas_right).offset(20);
            make.right.equalTo(self.contentView).offset(-20);
            make.top.bottom.equalTo(self);
        }];
    }
    return _username;
}

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated
{
    self.backgroundColor = highlighted ? [UIColor colorWithWhite:0.9 alpha:1] : [ZZColorTheme shared].gridBackgroundColor;
}

@end
