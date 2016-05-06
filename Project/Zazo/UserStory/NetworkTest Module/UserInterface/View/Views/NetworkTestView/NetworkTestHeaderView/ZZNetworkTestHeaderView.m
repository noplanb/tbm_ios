//
//  ZZNetworkTestHeaderView.m
//  Zazo
//
//  Created by ANODA on 12/9/15.
//  Copyright © 2015 No Plan B. All rights reserved.
//

#import "ZZNetworkTestHeaderView.h"
#import "ZZNetworkTestViewUiConstants.h"

@interface ZZNetworkTestHeaderView ()

@property (nonatomic, strong) UIImageView *zazoImageView;
@property (nonatomic, strong) UIView *topBorderView;

@end

@implementation ZZNetworkTestHeaderView

@synthesize zazoApplicationTitle = _zazoApplicationTitle;

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        [self zazoImageView];
        [self topBorderView];
        [self zazoApplicationTitle];

    }
    return self;
}


- (UIImageView *)zazoImageView
{
    if (!_zazoImageView)
    {
        _zazoImageView = [UIImageView new];
        CGSize size = kZazoIconImageSize();
        UIImage *image = [UIImage imageWithPDFNamed:@"edit-friends-user-has-app" atSize:size];
        _zazoImageView.image = image;
        [self addSubview:_zazoImageView];

        [_zazoImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self).offset(kAppImageLeftOffset());
            make.top.equalTo(self).offset(kAppImageTopOffset());
            make.width.equalTo(@(size.width));
            make.height.equalTo(@(size.height));
        }];
    }

    return _zazoImageView;
}

- (UIView *)topBorderView
{
    if (!_topBorderView)
    {
        _topBorderView = [UIView new];
        _topBorderView.backgroundColor = [UIColor whiteColor];
        [self addSubview:_topBorderView];

        [_topBorderView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.zazoImageView.mas_bottom).offset(5);
            make.left.equalTo(self);
            make.right.equalTo(self);
            make.height.equalTo(@(2));

        }];

    }
    return _topBorderView;
}

- (UILabel *)zazoApplicationTitle
{
    if (!_zazoApplicationTitle)
    {
        _zazoApplicationTitle = [UILabel new];
        _zazoApplicationTitle.text = NSLocalizedString(@"network-test-view.app.title", nil);
        _zazoApplicationTitle.textColor = [UIColor whiteColor];


        [self addSubview:_zazoApplicationTitle];

        [_zazoApplicationTitle mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.zazoImageView.mas_right).offset(kAppTitleLeftOffset());
            make.top.equalTo(self).offset(kBetweenInfoLabelOffset());
            make.right.equalTo(self);
            make.height.equalTo(@(kAppTitleHeight()));
        }];
    }

    return _zazoApplicationTitle;
}


@end
