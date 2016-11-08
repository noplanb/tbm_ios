//
// Created by Rinat on 25/03/16.
// Copyright (c) 2016 No Plan B. All rights reserved.
//

#import "ZZMenuHeaderView.h"

CGFloat const ZZDefaultAvatarRadius = 60;

@interface ZZMenuHeaderView ()


@end

@implementation ZZMenuHeaderView

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        _avatarRadius = ZZDefaultAvatarRadius;
        
        self.clipsToBounds = YES;
        self.layoutMargins = UIEdgeInsetsMake(24, 24, 24, 24);

        [self _makeBackground];
        [self _makePattern];
        [self _makeTitle];
        [self _makeImageView];
        [self _makeImageViewButton];
    }

    return self;
}

- (void)setAvatarRadius:(CGFloat)avatarRadius
{
    _avatarRadius = avatarRadius;
    [self _remakeLayout];    
}

- (void)_makeBackground
{
    self.backgroundColor = [UIColor an_colorWithHexString:@"1976d2"];
}

- (void)_makePattern
{
    _patternView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"pattern"]];
    [_patternView setTintAdjustmentMode:UIViewTintAdjustmentModeNormal];
    [self addSubview:_patternView];

    [_patternView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.equalTo(self);
    }];
}

- (void)_makeTitle
{
    _titleLabel = [UILabel new];
    _titleLabel.font = [UIFont zz_mediumFontWithSize:21];
    _titleLabel.textColor = [UIColor whiteColor];
    _titleLabel.textAlignment = NSTextAlignmentCenter;
    
    [self addSubview:_titleLabel];
    [_titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.mas_leftMargin);
        make.right.equalTo(self.mas_rightMargin);
        make.bottom.equalTo(self.mas_bottomMargin);
    }];
}

- (void)_makeImageView
{
    
    _imageView = [UIImageView new];
    _imageView.contentMode = UIViewContentModeScaleAspectFill;
    _imageView.clipsToBounds = YES;
    
    
    
    [self addSubview:_imageView];
}

- (void)_makeImageViewButton
{
    UILabel *noAvatarText = [UILabel new];
    noAvatarText.text = @"Tap to Set Profile Photo";
    noAvatarText.numberOfLines = 2;
    noAvatarText.textAlignment = NSTextAlignmentCenter;
    noAvatarText.textColor = [UIColor an_colorWithHexString:@"DBE6FF"];
    noAvatarText.font = [UIFont boldSystemFontOfSize:13];
    self.noImageLabel = noAvatarText;
    
    UIImage *emptyAvatarImage = [UIImage imageNamed:@"empty-avatar"];
    
    _imageViewButton = [UIButton new];
    _imageViewButton.backgroundColor = [UIColor an_colorWithHexString:@"1976d2"];
    [_imageViewButton setImage:emptyAvatarImage forState:UIControlStateNormal];
    [_imageViewButton setTintAdjustmentMode:UIViewTintAdjustmentModeNormal];
    
    [self insertSubview:_imageViewButton belowSubview:self.imageView];
    [_imageViewButton addSubview:noAvatarText];
    
    [noAvatarText mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(_imageViewButton).centerOffset(CGPointMake(0, 4));
        make.width.equalTo(_imageViewButton).offset(-40);
    }];

    [self _remakeLayout];
}

- (void)_remakeLayout
{
    CGFloat radius = self.avatarRadius + 4;

    [_imageViewButton mas_remakeConstraints:^(MASConstraintMaker *make) {
        CGSize avatarSize = CGSizeMake(radius*2, radius*2);
        make.size.equalTo([NSValue valueWithCGSize:avatarSize]);
        make.center.equalTo(self.imageView);
    }];
    
    _imageViewButton.layer.cornerRadius = radius;
    
    [_imageView mas_remakeConstraints:^(MASConstraintMaker *make) {
        CGSize avatarSize = CGSizeMake(self.avatarRadius * 2, self.avatarRadius * 2);
        make.size.equalTo([NSValue valueWithCGSize:avatarSize]);
        make.centerX.equalTo(self);
        make.top.equalTo(self.mas_topMargin);
        make.bottom.equalTo(self.titleLabel.mas_top).offset(-18);
    }];
    
    _imageView.layer.cornerRadius = self.avatarRadius;
}

- (void)setTitle:(NSString *)title
{
    self.titleLabel.text = title;
}

@end
