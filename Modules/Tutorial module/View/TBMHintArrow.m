//
// Created by Maksim Bazarov on 13/06/15.
// Copyright (c) 2015 No Plan B. All rights reserved.
//

#import "TBMHintArrow.h"

NSString *const kTBMTutorialFontName = @"DKCrayonCrumble";

@interface TBMHintArrow ()
@property(nonatomic, strong) UIView *rotationWrapper;
@property(nonatomic, strong) UIImageView *arrowImageView;
@property(nonatomic, strong) UIImage *arrowImage;
@property(nonatomic, strong) UIView *arrowEndPointView;

@end

@implementation TBMHintArrow

- (instancetype)init {
    self = [super init];
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

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self setup];
    }
    return self;
}

- (void)setup {
    self.userInteractionEnabled = NO;
    self.backgroundColor = [UIColor clearColor];
}

CGFloat degreesToRadians(CGFloat x) {
    return (CGFloat) (M_PI * (x) / 180.0);
}

- (void)setHideArrow:(BOOL)hideArrow {
    self.arrowImageView.hidden = hideArrow;
    _hideArrow = hideArrow;
}

+ (TBMHintArrow *)arrowWithText:(NSString *)text curveKind:(TBMHintArrowCurveKind)curveKind arrowPoint:(CGPoint)point angle:(CGFloat)angle hidden:(BOOL)hidden frame:(CGRect)frame {
    TBMHintArrow *result = [[TBMHintArrow alloc] initWithFrame:frame];
    result.text = text;
    result.arrowCurveKind = curveKind;
    result.arrowPoint = point;
    result.arrowAngle = angle;
    result.hideArrow = hidden;
    return result;
}

#pragma mark - Layout

- (void)layoutSubviews {
    [super layoutSubviews];
    [self layoutArrow];
    [self layoutLabels];
}

- (void)layoutLabels {
    CGFloat height = 40;
    CGFloat width = CGRectGetWidth(self.bounds);
    CGFloat x = CGRectGetMinX(self.bounds);
    CGFloat y;
    CGRect arrow = [self.rotationWrapper convertRect:self.arrowImageView.frame toView:self];

    if (self.arrowAngle >= -90 && self.arrowAngle <= 90) {
        y = CGRectGetMinY(arrow) - CGRectGetHeight(self.firstLabel.bounds);
    } else {
        y = CGRectGetMaxY(arrow);
    }

    CGRect firstLabelFrame = CGRectMake(x, y, width, height);
    self.firstLabel.frame = firstLabelFrame;
}

- (void)layoutArrow {
    CGFloat imageWidth = self.arrowImage.size.width;
    CGFloat imageHeight = self.arrowImage.size.height;
    CGFloat width = self.arrowImage.size.width;
    CGFloat height = self.arrowImage.size.height;
    CGRect frame = CGRectMake(self.arrowPoint.x - (width / 2), self.arrowPoint.y - (height / 2), width, height);
    self.rotationWrapper.frame = frame;
    self.arrowImageView.image = self.arrowImage;
    self.arrowImageView.frame = CGRectMake(0, 0, imageWidth, imageHeight);
    self.rotationWrapper.layer.anchorPoint = CGPointMake(0.5f, 0.5f);

    //Positioning of arrow end point
    if (self.arrowCurveKind == TBMTutorialArrowCurveKindRight) {
        self.arrowEndPointView.frame = CGRectMake(CGRectGetMinX(self.arrowImageView.bounds) + (imageWidth * .44f), CGRectGetMaxY(self.arrowImageView.bounds), 5, 5);
    } else {
        self.arrowEndPointView.frame = CGRectMake(CGRectGetMinX(self.arrowImageView.bounds) + (imageWidth * .54f), CGRectGetMaxY(self.arrowImageView.bounds), 5, 5);
    }
    // Rotation
    [self.rotationWrapper setTransform:CGAffineTransformMakeRotation(degreesToRadians(self.arrowAngle))];
    // Correction of arrow end point to anchor point
    [self makeCorrectionForArrow];
    self.arrowImageView.hidden = self.hideArrow;
}

- (void)makeCorrectionForArrow {
    CGFloat x = self.arrowImageView.frame.origin.x;
    CGFloat y = self.arrowImageView.frame.origin.y;
    CGFloat width = CGRectGetWidth(self.arrowImageView.frame);
    CGFloat height = CGRectGetHeight(self.arrowImageView.frame);
    CGPoint anchor = [self.rotationWrapper convertPoint:self.arrowPoint fromView:self];
    CGPoint endPoint = self.arrowEndPointView.frame.origin;
    CGPoint correctionDelta = CGPointMake(anchor.x - endPoint.x, anchor.y - endPoint.y);
    self.arrowImageView.frame = CGRectMake(x + correctionDelta.x, y + correctionDelta.y, width, height);
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

- (void)setupArrowImage {
    if (self.arrowCurveKind == TBMTutorialArrowCurveKindLeft) {
        _arrowImage = [UIImage imageNamed:@"arrow-yellow-kind-left"];
    } else {
        _arrowImage = [UIImage imageNamed:@"arrow-yellow-kind-right"];
    }
}

- (UIView *)rotationWrapper {
    if (!_rotationWrapper) {
        _rotationWrapper = [[UIView alloc] initWithFrame:CGRectZero];
        _rotationWrapper = [[UIImageView alloc] initWithFrame:CGRectZero];
        [self addSubview:_rotationWrapper];
    }
    return _rotationWrapper;
}

- (UIImageView *)arrowImageView {
    if (!_arrowImageView) {
        _arrowImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
        [self.rotationWrapper addSubview:_arrowImageView];
    }
    return _arrowImageView;
}

- (UIView *)arrowEndPointView {
    if (!_arrowEndPointView) {
        _arrowEndPointView = [[UIView alloc] initWithFrame:CGRectZero];
        [self.arrowImageView addSubview:_arrowEndPointView];
    }
    return _arrowEndPointView;
}

- (UIImage *)arrowImage {
    if (!_arrowImage) {
        [self setupArrowImage];
    }
    return _arrowImage;
}

- (void)setText:(NSString *)text {
    _text = text;
    self.firstLabel.text = _text;
}

- (void)setArrowCurveKind:(TBMHintArrowCurveKind)arrowCurveKind {
    _arrowCurveKind = arrowCurveKind;
}

- (void)setArrowPoint:(CGPoint)arrowPoint {
    _arrowPoint = arrowPoint;
}
@end