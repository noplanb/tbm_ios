//
// Created by Maksim Bazarov on 10/06/15.
// Copyright (c) 2015 No Plan B. All rights reserved.
//


#import "TBMHintView.h"
#import "TBMEventHandlerPresenter.h"

@interface TBMHintView ()

@property(nonatomic, weak) TBMEventHandlerPresenter *presenter;

@property(nonatomic, strong) UIView *gotItButton;
@property(nonatomic, strong) UIImageView *gotItImage;
@property(nonatomic, strong) UILabel *gotItLabel;

@end

@implementation TBMHintView

#pragma mark - Interface

- (void)showInGrid:(id <TBMGridModuleInterface>)gridModule {
    UIView *view = gridModule.viewForDialog;
    self.gridModule = gridModule;
    self.frame = view.bounds;

    [self configureHint];

    [view addSubview:self];
    [view bringSubviewToFront:self];
    [self show];
}

- (void)dismiss {
    [self hide];
    [self.presenter dialogDidDismiss];
}

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


#pragma mark - Handle events

- (void)tutorialViewDidTap:(id)sender {
    [self dismiss];
}

- (void)setArrows:(NSArray *)arrows {
    for (UIView *view in _arrows) {
        [view removeFromSuperview];
    }
    _arrows = arrows;
    for (UIView *view in _arrows) {
        [self addSubview:view];
    }
}

#pragma mark - Private

- (void)configureHint {
    //virtual
}

- (void)show {
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