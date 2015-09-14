//
//  ZZMenuCell.m
//  Zazo
//
//  Created by ANODA on 8/11/15.
//  Copyright (c) 2015 ANODA. All rights reserved.
//

#import "ZZMenuCell.h"

static CGFloat const kLeftOffset = 20;
static CGFloat const kSeparatorHeight = 1;


@interface ZZMenuCell ()

@property (nonatomic, strong) UIImageView* photoImageView;
@property (nonatomic, strong) UILabel* username;

@end

@implementation ZZMenuCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier])
    {
        self.backgroundColor = [UIColor clearColor];

        UIView* bottomBorder = [UIView new];
        bottomBorder.backgroundColor = [UIColor colorWithRed:0.34 green:0.34 blue:0.33 alpha:1.0f];
        [self addSubview:bottomBorder];
        
        [bottomBorder mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self).with.offset(kLeftOffset);
            make.bottom.right.equalTo(self);
            make.height.equalTo(@(kSeparatorHeight));
        }];
        UIView* topBorderView = [UIView new];
        topBorderView.backgroundColor = [UIColor colorWithRed:0.01 green:0.01 blue:0.01 alpha:1.0f];
        [self addSubview:topBorderView];
        
        [topBorderView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(bottomBorder.mas_left);
            make.bottom.equalTo(bottomBorder.mas_top).with.offset(0);
            make.right.equalTo(self);
            make.height.equalTo(@(kSeparatorHeight));
        }];
    }
    return self;
}


- (void)updateWithModel:(ZZMenuCellViewModel*)model
{
    self.username.text = [model username];
    [model updateImageView:self.photoImageView];
    
    if (ANIsEmpty(self.photoImageView.image))
    {
        [self.photoImageView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.width.equalTo(@0);
        }];
        
        [self.username mas_updateConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.photoImageView.mas_right);
        }];
    }
    else
    {
        [self.photoImageView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.width.equalTo(@36);
        }];
        
        [self.username mas_updateConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.photoImageView.mas_right).with.offset(10);
        }];
    }
}


#pragma mark - Lazy Load

- (UIImageView*)photoImageView
{
    if (!_photoImageView)
    {
        _photoImageView = [UIImageView new];
        _photoImageView.clipsToBounds = YES;
        _photoImageView.contentMode = UIViewContentModeScaleAspectFill;
        _photoImageView.backgroundColor = [UIColor clearColor];
        [self.contentView addSubview:_photoImageView];
        
        [_photoImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.contentView).offset(20);
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
        _username.font = [UIFont an_lightFontWithSize:18];
        _username.textColor = [UIColor an_colorWithHexString:@"a8a294"];
        [self.contentView addSubview:_username];
        
        [_username mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.photoImageView.mas_right).offset(10);
            make.right.equalTo(self.contentView).offset(-20);
            make.top.bottom.equalTo(self);
        }];
    }
    return _username;
}

@end
