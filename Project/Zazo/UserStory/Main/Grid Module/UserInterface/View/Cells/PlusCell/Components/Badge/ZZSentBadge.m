//
//  ZZSentBadge.m
//  Zazo
//
//  Created by Rinat on 04/03/16.
//  Copyright © 2016 No Plan B. All rights reserved.
//

#import "ZZSentBadge.h"
#import "UIView+ZZAdditions.h"

@interface ZZSentBadge ()

@property (nonatomic, strong) UIImageView *imageView;

@end

@implementation ZZSentBadge

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        self.imageView = [UIImageView new];
        [self addSubview:self.imageView];
        self.imageView.contentMode = UIViewContentModeCenter;

        _state = NSUIntegerMax;
        self.state = ZZSentBadgeStateSent;
        [self.imageView sizeToFit];

        [self.imageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self);
        }];

        self.shapeLayer.fillColor = [UIColor whiteColor].CGColor;

    }
    return self;
}

- (void)setState:(ZZSentBadgeState)state
{
    if (_state == state)
    {
        return;
    }

    _state = state;

//    self.imageView.alpha = 1;

    [UIView transitionWithView:self.imageView duration:1 options:0 animations:^{
        self.imageView.image = [UIImage imageNamed:[self _imageFilenameForState:state]];

    }               completion:^(BOOL finished) {
        if (state == ZZSentBadgeStateViewed)
        {
            [self.imageView blinkAnimatedTimes:3];
        }
    }];
}

- (NSString *)_imageFilenameForState:(ZZSentBadgeState)state
{
    switch (state)
    {
        case ZZSentBadgeStateSent:
            return @"paper-plane";

        case ZZSentBadgeStateViewed:
            return @"seen-eye";
    }

    return nil;
}


@end
