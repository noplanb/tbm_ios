//
// Created by Maksim Bazarov on 13/06/15.
// Copyright (c) 2015 No Plan B. All rights reserved.
//

#import "TBMHintArrow.h"
#import "UILabel+TBMUILabelDynamicHeight.h"

CGFloat const kImageScale = 0.75f;

@interface TBMHintArrow ()

@property(nonatomic, strong) UIView *rotationWrapper;
@property(nonatomic, strong) UIImageView *arrowImageView;
@property(nonatomic, strong) UIImage *arrowImage;
@property(nonatomic, strong) UIView *arrowEndPointView;

@property(nonatomic, strong) UIFont *mainLabelFont;
@end

@implementation TBMHintArrow

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        [self setup];
    }
    return self;
}

- (void)setup
{
    self.userInteractionEnabled = NO;
    self.backgroundColor = [UIColor clearColor];
}

CGFloat degreesToRadians(CGFloat x)
{
    return (CGFloat) (M_PI * (x) / 180.0);
}

- (void)setHideArrow:(BOOL)hideArrow
{
    self.arrowImageView.hidden = hideArrow;
    _hideArrow = hideArrow;
}

+ (TBMHintArrow *)arrowWithText:(NSString *)text curveKind:(TBMHintArrowCurveKind)curveKind arrowPoint:(CGPoint)point angle:(CGFloat)angle hidden:(BOOL)hidden frame:(CGRect)frame
{
    TBMHintArrow *result = [[TBMHintArrow alloc] initWithFrame:frame];
    result.text = text;
    result.arrowCurveKind = curveKind;
    result.arrowPoint = point;
    result.arrowAngle = angle;
    result.hideArrow = hidden;
    return result;
}

#pragma mark - Layout

- (void)layoutSubviews
{
    [super layoutSubviews];
    [self layoutArrow];
    [self layoutLabels];
}

- (void)layoutLabels
{
    CGFloat margin = 15.f;
    CGFloat height = 40;
    CGFloat width = CGRectGetWidth(self.bounds) - (margin * 2);
    CGFloat x = CGRectGetMinX(self.bounds) + margin;
    CGFloat y;

    CGRect arrow = [self.rotationWrapper convertRect:self.arrowImageView.frame toView:self];
    y = self.arrowAngle >= -90 && self.arrowAngle <= 90 ? CGRectGetMinY(arrow) - CGRectGetHeight(self.arrowLabel.bounds) -50 : CGRectGetMaxY(arrow) + 50;
    self.arrowLabel.preferredMaxLayoutWidth = width;
    self.arrowLabel.frame = CGRectMake(x, y, width, height);
    CGSize newSize = self.arrowLabel.sizeOfMultiLineLabel;
    self.arrowLabel.frame = CGRectMake(x, y, width, newSize.height);
}

- (void)layoutArrow
{
    CGFloat imageWidth = self.arrowImage.size.width * kImageScale;
    CGFloat imageHeight = self.arrowImage.size.height * kImageScale;

    CGRect frame = CGRectMake(self.arrowPoint.x - (imageWidth / 2), self.arrowPoint.y - (imageHeight / 2), imageWidth, imageHeight);
    self.rotationWrapper.frame = frame;
    self.arrowImageView.image = self.arrowImage;
    self.arrowImageView.frame = CGRectMake(0, 0, imageWidth, imageHeight);
    self.rotationWrapper.layer.anchorPoint = CGPointMake(0.5f, 0.5f);

    //Positioning of arrow end point
    CGRect bounds = self.arrowImageView.bounds;
    self.arrowEndPointView.frame = CGRectMake(CGRectGetMinX(bounds) + (imageWidth * (self.arrowCurveKind == TBMTutorialArrowCurveKindRight ? .44f : .54f)), CGRectGetMaxY(bounds), 5, 5);
    // Rotation
    [self.rotationWrapper setTransform:CGAffineTransformMakeRotation(degreesToRadians(self.arrowAngle))];
    // Correction of arrow end point to anchor point
    [self makeCorrectionForArrow];
    self.arrowImageView.hidden = self.hideArrow;
}

- (void)makeCorrectionForArrow
{
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

- (UILabel *)arrowLabel
{
    if (!_arrowLabel)
    {
        _arrowLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _arrowLabel.textColor = [UIColor whiteColor];
        _arrowLabel.font = [UIFont fontWithName:kTBMTutorialFontName size:30];
        _arrowLabel.textAlignment = NSTextAlignmentCenter;
        _arrowLabel.lineBreakMode = NSLineBreakByWordWrapping;
        _arrowLabel.numberOfLines = 0;
        [self addSubview:_arrowLabel];
    }
    return _arrowLabel;
}

- (void)setupArrowImage
{
    _arrowImage = [UIImage imageNamed:self.arrowCurveKind == TBMTutorialArrowCurveKindLeft ? @"arrow-yellow-kind-left" : @"arrow-yellow-kind-right"];
}

- (UIView *)rotationWrapper
{
    if (!_rotationWrapper)
    {
        _rotationWrapper = [[UIImageView alloc] initWithFrame:CGRectZero];
        [self addSubview:_rotationWrapper];
    }
    return _rotationWrapper;
}

- (UIImageView *)arrowImageView
{
    if (!_arrowImageView)
    {
        _arrowImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
        [self.rotationWrapper addSubview:_arrowImageView];
    }
    return _arrowImageView;
}

- (UIView *)arrowEndPointView
{
    if (!_arrowEndPointView)
    {
        _arrowEndPointView = [[UIView alloc] initWithFrame:CGRectZero];
        [self.arrowImageView addSubview:_arrowEndPointView];
    }
    return _arrowEndPointView;
}

- (UIImage *)arrowImage
{
    if (!_arrowImage)
    {
        [self setupArrowImage];
    }
    return _arrowImage;
}

- (void)setText:(NSString *)text
{
    _text = text;
    self.arrowLabel.text = _text;
}

@end