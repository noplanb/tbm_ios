//
// Created by Maksim Bazarov on 10/06/15.
// Copyright (c) 2015 No Plan B. All rights reserved.
//
#define DEGREES_TO_RADIANS(x) (M_PI * (x) / 180.0)

#import <AVFoundation/AVFoundation.h>
#import "TBMTutorialView.h"

//DKCrayonCrumble
NSString *const kTBMTutorialFontName = @"DKCrayonCrumble";

@interface TBMTutorialView ()
@property(nonatomic, strong) UILabel *firstLabel;
@property(nonatomic, strong) UILabel *secondLabel;
@property(nonatomic, strong) UIImageView *arrowView;
@property(nonatomic, strong) UIView *gotItButton;
@property(nonatomic, strong) UIImageView *gotItImage;
@property(nonatomic, strong) UILabel *gotItLabel;
@end

@implementation TBMTutorialView {

}

#pragma mark - Drawing

- (void)drawRect:(CGRect)rect {
    [self.fillColor setFill];
    UIRectFill(rect);
    if (!self.framesToCutOut || self.framesToCutOut.count <= 0) {
        return;
    }

    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetBlendMode(context, kCGBlendModeDestinationOut);
    for (UIBezierPath *path in self.framesToCutOut) {
        NSLog(@"Drawed path : %@ ", NSStringFromCGRect([path bounds]));
        [path fill];
    }
    CGContextSetBlendMode(context, kCGBlendModeNormal);
}

- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event {
    for (UIBezierPath *path in self.framesToCutOut) {
        CGFloat pathWidth = CGRectGetWidth([path bounds]);
        CGFloat pathHeight = CGRectGetHeight([path bounds]);
        if ([path containsPoint:point] && pathHeight > 0 && pathWidth > 0) {
            return NO;
        }
    }
    return YES;
}

#pragma mark - Layout

- (void)layoutButton {

    CGFloat aspectRatio = self.gotItImage.image.size.height / self.gotItImage.image.size.width;
    CGFloat width = (CGRectGetWidth(self.bounds) / 2);
    CGFloat height = width * aspectRatio;
    CGFloat x = (CGRectGetWidth(self.bounds) / 2) - (width / 2);
    CGFloat y = CGRectGetMaxY(self.bounds) - (CGRectGetHeight(self.bounds) / 4);
    CGRect buttonFrame = CGRectMake(x, y, width, height);
    self.gotItButton.frame = buttonFrame;
    self.gotItImage.frame = self.gotItButton.bounds;
    self.gotItLabel.frame = self.gotItButton.bounds;

}

- (void)layoutLabels {
    CGFloat height = 60;
    CGFloat width = CGRectGetWidth(self.bounds);
    CGFloat x = CGRectGetMinX(self.bounds);
    CGFloat y = CGRectGetMinY(self.bounds) + (CGRectGetHeight(self.bounds) / 3) - (height / 2);
    CGRect firstLabelFrame = CGRectMake(x, y, width, height);
    self.firstLabel.frame = firstLabelFrame;
}

- (CGSize)makeArrowSizeWithImage:(UIImage *)image {
    CGFloat aspectRatio = image.size.height / image.size.width;
    CGFloat width = CGRectGetWidth(self.bounds) / 3;
    CGFloat height = width * aspectRatio;
    return CGSizeMake(width, height);
}

- (void)layoutArrow {
    UIImage *image = nil;
    CGPoint point = CGPointZero;
    CGSize arrowSize;

    CGFloat x = 0.f;
    CGFloat y = 0.f;
    switch (self.arrowKind) {
        case TBMTutorialArrowPointFromTopToHorizTop:
            image = [UIImage imageNamed:@"arrow-yellow-bottom-left-vertical"];
            point = [self transparentBoundsTopCenter];
            arrowSize = [self makeArrowSizeWithImage:image];
            x = point.x - arrowSize.width;
            y = point.y - arrowSize.height;

            break;

        case TBMTutorialArrowPointFromTopToHorizCenter:
            break;
        case TBMTutorialArrowPointFromTopToHorizBottom:
            image = [UIImage imageNamed:@"arrow-yellow-bottom-right"];
            point = [self transparentBoundsRightBottom];
            arrowSize = [self makeArrowSizeWithImage:image];
            x = point.x - arrowSize.width;
            y = point.y - arrowSize.height;
            [self layoutArrowImage:image arrowSize:&arrowSize x:x y:y];
            [self.arrowView setTransform:CGAffineTransformMakeRotation(DEGREES_TO_RADIANS(30))];
            break;
        case TBMTutorialArrowPointFromTopToVertLeftCorner:
            break;
        default:
            break;
    }

}

- (void)layoutArrowImage:(UIImage *)image arrowSize:(CGSize *)arrowSize x:(CGFloat)x y:(CGFloat)y {
    CGRect frame = CGRectMake(x, y, (*arrowSize).width, (*arrowSize).height);
    self.arrowView.image = image;
    self.arrowView.frame = frame;
}

- (CGPoint)transparentBoundsTopCenter {
    CGRect bounds = [self transparentBounds];
    CGPoint result;
    return result;
}

- (CGPoint)transparentBoundsRightBottom {
    CGRect bounds = [self transparentBounds];
    CGPoint result;
    result.x = CGRectGetMinX(bounds);
    result.y = CGRectGetMaxY(bounds) - (CGRectGetHeight(bounds) / 2);
    return result;
}

/**
 * Concatenate bounds of transparent rects
 */
- (CGRect)transparentBounds {
    NSLog(@"transparentBounds: %@", NSStringFromCGRect([[self.framesToCutOut firstObject] bounds]));
    return [[self.framesToCutOut firstObject] bounds];
}

#pragma mark - Lazy initialization

- (UILabel *)firstLabel {
    if (!_firstLabel) {
        _firstLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _firstLabel.font = [UIFont fontWithName:kTBMTutorialFontName size:32];
        _firstLabel.textColor = [UIColor whiteColor];
        _firstLabel.textAlignment = NSTextAlignmentCenter;
        _firstLabel.minimumScaleFactor = .7f;
        _firstLabel.numberOfLines = 1;
        [self addSubview:_firstLabel];
    }
    return _firstLabel;
}

- (UILabel *)secondLabel {
    return _secondLabel;
}

- (UIImageView *)arrowView {
    if (!_arrowView) {
        _arrowView = [[UIImageView alloc] initWithFrame:CGRectZero];
        [self addSubview:_arrowView];

    }
    return _arrowView;
}

- (UIView *)gotItButton {
    if (!_gotItButton) {
        _gotItButton = [[UIView alloc] initWithFrame:CGRectZero];
        [self addSubview:_gotItButton];
    }
    return _gotItButton;
}

- (UIImageView *)gotItImage {
    if (!_gotItImage) {
        _gotItImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"circle-white"]];
        [self.gotItButton addSubview:_gotItImage];
    }
    return _gotItImage;
}

- (UILabel *)gotItLabel {
    if (!_gotItLabel) {
        _gotItLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _gotItLabel.font = [UIFont fontWithName:kTBMTutorialFontName size:25];
        _gotItLabel.textColor = [UIColor whiteColor];
        _gotItLabel.text = @"Got it";
        _gotItLabel.textColor = [UIColor whiteColor];
        _gotItLabel.textAlignment = NSTextAlignmentCenter;
        _gotItLabel.minimumScaleFactor = .7f;
        _gotItLabel.numberOfLines = 1;
        [self.gotItButton addSubview:_gotItLabel];
    }
    return _gotItLabel;
}


- (void)setText:(NSString *)text {
    _text = text;
    self.firstLabel.text = _text;
    [self layoutLabels];
    [self layoutButton];

}

- (void)setArrowKind:(TBMTutorialArrowPoint)arrowKind {
    _arrowKind = arrowKind;
    [self layoutArrow];
}


@end