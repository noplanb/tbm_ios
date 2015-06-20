//
// Created by Maksim Bazarov on 10/06/15.
// Copyright (c) 2015 No Plan B. All rights reserved.
//


#import "TBMHint.h"
#import "TBMHintArrow.h"

@interface TBMHint ()

@property(nonatomic, strong) UIView *gotItButton;
@property(nonatomic, strong) UIImageView *gotItImage;
@property(nonatomic, strong) UILabel *gotItLabel;


@property(nonatomic, weak) id callbackDelegate;
@property(nonatomic) SEL callbackEvent;
@end

@implementation TBMHint {

}

#pragma mark - Interface


#pragma mark - Initialization

- (instancetype)init {
    self = [self initWithFrame:CGRectZero];

    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self setup];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setup];
    }
    return self;
}

- (void)setup {
    self.fillColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.65f];
    self.backgroundColor = [UIColor clearColor];
    self.hidden = YES;
    self.alpha = 0;
    self.userInteractionEnabled = YES;
    UITapGestureRecognizer *recognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tutorialViewDidTap:)];
    [self addGestureRecognizer:recognizer];
}

- (void)tutorialViewDidTap:(id)sender {
    [self dismiss];
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
        [path fill];
    }
    CGContextSetBlendMode(context, kCGBlendModeNormal);
}

- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event {
    for (UIBezierPath *path in self.framesToCutOut) {
        CGFloat pathWidth = CGRectGetWidth([path bounds]);
        CGFloat pathHeight = CGRectGetHeight([path bounds]);
        if ([path containsPoint:point] && pathHeight > 0 && pathWidth > 0) {
            if (self.dismissAfterAction) {
                [self dismiss];
            }
            return NO;
        }
    }
    return YES;
}

#pragma mark - Layout

- (void)layoutSubviews {
    [super layoutSubviews];
    for (TBMHintArrow *arrow in self.arrows) {
        [arrow layoutSubviews];
    }
    [self layoutButton];

}

- (void)layoutButton {
    if (!self.showGotItButton) {
        self.gotItButton.hidden = YES;
        return;
    }

    CGFloat aspectRatio = self.gotItImage.image.size.height / self.gotItImage.image.size.width;
    CGFloat width = (CGRectGetWidth(self.bounds) / 2);
    CGFloat height = width * aspectRatio;
    CGFloat x = (CGRectGetWidth(self.bounds) / 2) - (width / 2);
    CGFloat y = CGRectGetMaxY(self.bounds) - (CGRectGetHeight(self.bounds) / 4);
    CGRect buttonFrame = CGRectMake(x, y, width, height);
    self.gotItButton.frame = buttonFrame;
    self.gotItImage.frame = self.gotItButton.bounds;
    self.gotItLabel.frame = self.gotItButton.bounds;
    self.gotItButton.hidden = NO;
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
        _gotItLabel.numberOfLines = 0;
        [self.gotItButton addSubview:_gotItLabel];
    }
    return _gotItLabel;
}

#pragma mark - Setters

- (void)setArrows:(NSArray *)arrows {
    for (UIView *view in _arrows) {
        [view removeFromSuperview];
    }
    _arrows = arrows;
    for (UIView *view in _arrows) {
        [self addSubview:view];
    }
}

- (void)showHintInView:(UIView *)view frame:(CGRect)frame delegate:(id)callbackDelegate event:(SEL)event {
    self.callbackDelegate = callbackDelegate;
    self.callbackEvent = event;
    self.frame = frame;

    for (UIView *subview in view.subviews) {
        if ([subview isKindOfClass:[TBMHint class]]) {
            [subview removeFromSuperview];
        }
    }

    [self configureHint];
    [view addSubview:self];
    [view bringSubviewToFront:self];
    [self show];
}

- (void)configureHint {
    //virtual
}

- (void)dismiss {
    [self hide];
    if (self.callbackDelegate && [self.callbackDelegate respondsToSelector:self.callbackEvent]) {
        [self.callbackDelegate performSelector:self.callbackEvent];
    }
}

- (void)show{
    self.hidden = NO;
    [self layoutSubviews];
    [UIView animateWithDuration:.25f animations:^{
        self.alpha = 1;
    }];
}

- (void)hide {
    [UIView animateWithDuration:.25f animations:^{
        self.alpha = 0;
    }];
    self.hidden = YES;
}


@end