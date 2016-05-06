//
//  ZZStartView.m
//  Zazo
//
//  Created by Oksana Kovalchuk on 9/12/15.
//  Copyright (c) 2015 No Plan B. All rights reserved.
//

#import "ZZStartView.h"

@implementation ZZStartView

- (UIImageView *)backgroundImageView
{
    if (!_backgroundImageView)
    {
        _backgroundImageView = [UIImageView new];
        [self addSubview:_backgroundImageView];

        [_backgroundImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self);
        }];
    }
    return _backgroundImageView;
}

@end
