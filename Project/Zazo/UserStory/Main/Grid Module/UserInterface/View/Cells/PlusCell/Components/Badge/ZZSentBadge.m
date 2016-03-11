//
//  ZZSentBadge.m
//  Zazo
//
//  Created by Rinat on 04/03/16.
//  Copyright © 2016 No Plan B. All rights reserved.
//

#import "ZZSentBadge.h"

@interface ZZSentBadge ()

@property (nonatomic, strong) UIImageView *imageView;

@end

@implementation ZZSentBadge

- (instancetype)init
{
    self = [super init];
    if (self) {

        self.state = ZZSentBadgeStateSent;

        self.imageView = [UIImageView new];
        [self addSubview:self.imageView];

        [self.imageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.center.equalTo(self);
        }];

        self.shapeLayer.fillColor = [UIColor whiteColor].CGColor;

    }
    return self;
}

- (void)setState:(ZZSentBadgeState)state
{
    _state = state;

    self.imageView.image = [UIImage imageNamed:[self _imageFilenameForState:state]];
}

- (NSString *)_imageFilenameForState:(ZZSentBadgeState)state
{
    switch (state)
    {
        case ZZSentBadgeStateSent:
            return @"paper-plane";

        case ZZSentBadgeViewed:
            return @"eye-icon";
    }

    return nil;
}


@end
