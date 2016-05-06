//
// Created by Maksim Bazarov on 13/06/15.
// Copyright (c) 2015 No Plan B. All rights reserved.
//

#import "ZZHintsArrow.h"
#import "ZZHintsConstants.h"

CGFloat const kImageScale = 0.75f;
NSString *const kZZHintsFontName = @"DKCrayonCrumble";


@interface ZZHintsArrow ()

@property (nonatomic, strong) UIView *rotationWrapper;
@property (nonatomic, strong) UIImageView *arrowImageView;
@property (nonatomic, strong) UIImage *arrowImage;
@property (nonatomic, strong) UIView *arrowEndPointView;
@property (nonatomic, assign) NSInteger focusViewIndex;
@property (nonatomic, strong) UIFont *mainLabelFont;
@end

@implementation ZZHintsArrow

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
    return (CGFloat)(M_PI * (x) / 180.0);
}

- (void)setHideArrow:(BOOL)hideArrow
{
    self.arrowImageView.hidden = hideArrow;
    _hideArrow = hideArrow;
}

+ (ZZHintsArrow *)arrowWithText:(NSString *)text
                      curveKind:(ZZHintsArrowCurveKind)curveKind
                     arrowPoint:(CGPoint)point
                          angle:(CGFloat)angle
                         hidden:(BOOL)hidden
                          frame:(CGRect)frame
                 focusViewIndex:(NSInteger)index
{
    ZZHintsArrow *result = [[ZZHintsArrow alloc] initWithFrame:frame];
    result.text = text;
    result.arrowCurveKind = curveKind;
    result.arrowPoint = point;
    result.arrowAngle = angle;
    result.hideArrow = hidden;
    result.focusViewIndex = index;
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

    CGFloat offset;
    if ([self countLinesForArrowLabel] == 1)
    {
        offset = 30;
    }
    else if ([self countLinesForArrowLabel] == 2)
    {
        offset = 50;
    }
    else
    {
        offset = 60;
    }

    y = 0;
    // hint label position top or bottom
    switch (self.focusViewIndex)
    {
        // top line indexes
        case 0:
        case 1:
        case 2:
        {
            y = CGRectGetMaxY(arrow) + offset;

        }
            break;

            // middle line indexes
        case 3:
        case 4:
        case 5:
        {
            if (IS_IPAD)
            {
                y = CGRectGetMinY(arrow) - CGRectGetHeight(self.arrowLabel.bounds) - offset * 3;
            }
            else
            {
                y = CGRectGetMinY(arrow) - CGRectGetHeight(self.arrowLabel.bounds) - offset * 2;
            }

        }
            break;

            // bottom line indexes
        case 6:
        case 7:
        case 8:
        {
            if (IS_IPAD)
            {
                y = CGRectGetMinY(arrow) - CGRectGetHeight(self.arrowLabel.bounds) - (offset * 3);
            }
            else
            {
                y = CGRectGetMinY(arrow) - CGRectGetHeight(self.arrowLabel.bounds) - offset * 2;
            }

        }
            break;
    }

    self.arrowLabel.preferredMaxLayoutWidth = width;
    CGRect frame = CGRectMake(x, y, width, height);

    CGFloat aLabelSizeWidth = CGRectGetWidth(frame);
    NSDictionary *attributes = @{NSFontAttributeName : self.arrowLabel.font};
    CGRect labelRect = [self.arrowLabel.text boundingRectWithSize:CGSizeMake(aLabelSizeWidth, MAXFLOAT)
                                                          options:NSStringDrawingUsesLineFragmentOrigin
                                                       attributes:attributes
                                                          context:nil];
    x = CGRectGetMidX(self.bounds) - (CGRectGetWidth(labelRect) / 2);
    self.arrowLabel.frame = CGRectMake(x, frame.origin.y, labelRect.size.width, labelRect.size.height);
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

- (NSInteger)countLinesForArrowLabel
{
    NSInteger lineCount = 0;

    CGSize textSize = CGSizeMake(SCREEN_WIDTH - 30, MAXFLOAT);
    NSInteger rHeight = roundf([self.arrowLabel sizeThatFits:textSize].height);
    NSInteger charSize = roundf(30);

    lineCount = rHeight / charSize;

    return lineCount;
}

#pragma mark - Lazy initialization

- (UILabel *)arrowLabel
{
    if (!_arrowLabel)
    {
        _arrowLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _arrowLabel.textColor = [UIColor whiteColor];
        _arrowLabel.font = [UIFont fontWithName:kZZHintsFontName size:kHintArrowLabelFontSize()];
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