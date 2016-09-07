//
// Created by Rinat on 25/03/16.
// Copyright (c) 2016 No Plan B. All rights reserved.
//

#import "ZZMenuHeaderView.h"

CGFloat const ZZAvatarRadius = 60;

@interface ZZMenuHeaderView ()

@property (nonatomic, strong, readonly) UIImageView *patternView;

@end

@implementation ZZMenuHeaderView

- (instancetype)init
{
    self = [super init];
    if (self)
    {
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
    _imageView.layer.cornerRadius = ZZAvatarRadius;
    

    [self addSubview:_imageView];
    [_imageView mas_makeConstraints:^(MASConstraintMaker *make) {
        CGSize avatarSize = CGSizeMake(ZZAvatarRadius*2, ZZAvatarRadius*2);
        make.size.equalTo([NSValue valueWithCGSize:avatarSize]);
        make.centerX.equalTo(self);
        make.top.equalTo(self.mas_topMargin);
        make.bottom.equalTo(self.titleLabel.mas_top).offset(-18);
    }];
}

- (void)_makeImageViewButton
{
    UILabel *noAvatarText = [UILabel new];
    noAvatarText.text = @"Tap to set the avatar";
    noAvatarText.numberOfLines = 2;
    noAvatarText.textAlignment = NSTextAlignmentCenter;
    noAvatarText.textColor = [UIColor grayColor];
    noAvatarText.font = [UIFont systemFontOfSize:13];
    
    CGFloat radius = ZZAvatarRadius + 1;
    
    _imageViewButton = [UIButton new];
    _imageViewButton.layer.cornerRadius = radius;
    _imageViewButton.backgroundColor = [UIColor whiteColor];
    
    [self insertSubview:_imageViewButton belowSubview:self.imageView];
    [_imageViewButton mas_makeConstraints:^(MASConstraintMaker *make) {
        CGSize avatarSize = CGSizeMake(radius*2, radius*2);
        make.size.equalTo([NSValue valueWithCGSize:avatarSize]);
        make.center.equalTo(self.imageView);
    }];
    
    [_imageViewButton addSubview:noAvatarText];
    [noAvatarText mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(_imageViewButton).centerOffset(CGPointMake(0, 4));
        make.width.equalTo(_imageViewButton).offset(-12);
    }];
}

- (void)setTitle:(NSString *)title
{
    self.titleLabel.text = title;
}

@end