//
//  ZZRecordButtonView.m
//  Zazo
//
//  Created by Rinat on 25/02/16.
//  Copyright © 2016 No Plan B. All rights reserved.
//

#import "ZZRecordButtonView.h"

static CGFloat padding = 6.0f;

@interface ZZRecordButtonView ()
{
    BOOL _isAnimating;
}

@property (nonatomic, weak) UIView *borderView;
@property (nonatomic, weak) UIView *circleView;

@end

@implementation ZZRecordButtonView

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
    [self addSubview:borderView];
    [borderView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self);
    }];
    self.borderView = borderView;
    
    // circle
    
    UIView *circleView = [UIView new];
    circleView.backgroundColor = [UIColor whiteColor];
    [self addSubview:circleView];
    [circleView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self).with.insets([self _insets]);
    }];
    self.circleView = circleView;
    
    // container for animations
    
    UIView *container = [UIView new];
    [self addSubview:container];
    
    [container mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self);
    }];
    
    // label
    
    UILabel *label = [UILabel new];
    label.font = [UIFont zz_condensedBoldFontWithSize:13];
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
    imageView.tintAdjustmentMode = UIViewTintAdjustmentModeNormal;
    [imageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self).centerOffset(CGPointMake(2, 2));
    }];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGFloat d = self.frame.size.width;
    
    self.borderView.layer.cornerRadius = d /2;
    self.circleView.layer.cornerRadius = (d - 2*padding) /2;
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

//- (CGSize)intrinsicContentSize
//{
//    return CGSizeMake(diameter, diameter);
//}

@end
