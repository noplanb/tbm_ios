//
//  ZZCircleView.m
//  Zazo
//
//  Created by Rinat on 25/02/16.
//  Copyright © 2016 No Plan B. All rights reserved.
//

#import "ZZCircleView.h"

static CGFloat padding = 6.0f;
static CGFloat diameter = 85.0f;

@interface ZZCircleView ()
{
    BOOL _isAnimating;
}
@end

@implementation ZZCircleView

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.translatesAutoresizingMaskIntoConstraints = NO;
        [self makeView];
    }
    return self;
}

- (void)makeView
{
    // border
    
    UIView *borderView = [UIView new];
    borderView.backgroundColor = [UIColor colorWithWhite:1 alpha:0.5];
    borderView.layer.cornerRadius = diameter /2;
    [self addSubview:borderView];
    [borderView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self);
    }];
    
    // circle
    
    UIView *circleView = [UIView new];
    circleView.backgroundColor = [UIColor whiteColor];
    circleView.layer.cornerRadius = (diameter - 2*padding) /2;
    [self addSubview:circleView];
    [circleView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self).with.insets([self _insets]);
    }];
    
    // container for animations
    
    UIView *container = [UIView new];
    [self addSubview:container];
    
    [container mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self);
    }];
    
    // label
    
    UILabel *label = [UILabel new];
    label.font = [UIFont an_condensedBoldFontWithSize:13];
    label.text = @"HOLD TO\nRECORD";
    label.textAlignment = NSTextAlignmentCenter;
    label.numberOfLines = 2;
    label.textColor = [UIColor blackColor];
    label.hidden = YES;
    
    [container addSubview:label];
    self.textLabel = label;
    
    [label mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self).with.insets([self _insets]);
    }];
    
    // camera icon
    
    UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"camera"]];
    [container addSubview:imageView];
    self.imageView = imageView;
    [imageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self).centerOffset(CGPointMake(2, 2));
    }];
}

- (void)animate
{
    if (_isAnimating)
    {
        return;
    }
    
    _isAnimating = YES;
    
    ANCodeBlock flipBack = ^{
        [UIView transitionFromView:self.textLabel toView:self.imageView
                          duration:1.0
                           options:UIViewAnimationOptionTransitionFlipFromLeft | UIViewAnimationOptionShowHideTransitionViews
                        completion:^(BOOL finished) {
                            _isAnimating = NO;
                        }];

    };
    
    ANCodeBlock flipTo = ^{
        [UIView transitionFromView:self.imageView toView:self.textLabel
                          duration:1.0
                           options:UIViewAnimationOptionTransitionFlipFromRight | UIViewAnimationOptionShowHideTransitionViews
                        completion:^(BOOL finished) {
                            
                            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(NSEC_PER_SEC)), dispatch_get_main_queue(), flipBack);
                            
                        }];
    };
    
    
    flipTo();

}



- (UIEdgeInsets)_insets
{
    return UIEdgeInsetsMake(padding, padding, padding, padding);
}

- (void)setTintColor:(UIColor *)tintColor
{
    [super setTintColor:tintColor];
    self.textLabel.textColor = tintColor;
}

- (CGSize)intrinsicContentSize
{
    return CGSizeMake(diameter, diameter);
}

@end
