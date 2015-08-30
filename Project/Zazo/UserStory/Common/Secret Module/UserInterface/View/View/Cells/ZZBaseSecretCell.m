//
//  ZZBaseSecretCell.m
//  Zazo
//
//  Created by ANODA on 8/28/15.
//  Copyright (c) 2015 No Plan B. All rights reserved.
//

#import "ZZBaseSecretCell.h"

@implementation ZZBaseSecretCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self)
    {
        self.selectionColor = [ZZColorTheme shared].baseColor;
    }
    return self;
}

- (UILabel *)titleLabel
{
    if (!_titleLabel)
    {
        _titleLabel = [UILabel new];
        _titleLabel.font = [UIFont an_regularFontWithSize:14];
        _titleLabel.highlightedTextColor = [UIColor whiteColor];
        _titleLabel.textColor = [ZZColorTheme shared].baseCellTextColor;
//        _titleLabel.numberOfLines = 0;
        [self addSubview:_titleLabel];
        
        [_titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.contentView).offset(10);
            make.top.bottom.equalTo(self);
            make.right.equalTo(self.contentView).offset(-100);
        }];
    }
    return _titleLabel;
}

@end
