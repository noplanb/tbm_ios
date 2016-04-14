//
// Created by Rinat on 25/03/16.
// Copyright (c) 2016 No Plan B. All rights reserved.
//

#import "ZZMenuHeaderView.h"

@interface ZZMenuHeaderView ()

@property (nonatomic, strong, readonly) UIImageView *patternView;
@property (nonatomic, strong) UILabel *titleLabel;

@end

@implementation ZZMenuHeaderView

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        self.clipsToBounds = YES;
        self.layoutMargins = UIEdgeInsetsMake(16, 16, 16, 16);
        
        [self _makeBackground];
        [self _makePattern];
        [self _makeTitle];
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

    [self addSubview:_titleLabel];
    [_titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.mas_leftMargin);
        make.right.equalTo(self.mas_rightMargin);
        make.bottom.equalTo(self.mas_bottomMargin);
    }];
}

- (void)setTitle:(NSString *)title
{
    self.titleLabel.text = title;
}

- (CGSize)intrinsicContentSize
{
    return CGSizeMake(UIViewNoIntrinsicMetric, 150);
}

@end