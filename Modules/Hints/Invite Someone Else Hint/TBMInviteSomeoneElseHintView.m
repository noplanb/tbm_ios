//
// Created by Maksim Bazarov on 16/06/15.
// Copyright (c) 2015 No Plan B. All rights reserved.
//

#import "TBMInviteSomeoneElseHintView.h"
#import "NSArray+TBMArrayHelpers.h"

@interface TBMInviteSomeoneElseHintView ()
@property(nonatomic, strong) UIImageView *presentImage;
@end

@implementation TBMInviteSomeoneElseHintView

- (void)configureHint
{
    CGRect highlightFrame = [self.gridModule gridGetFrameForFriend:4 inView:self.superview];
    self.dismissAfterAction = YES;
    self.framesToCutOut = @[
            [UIBezierPath bezierPathWithRect:highlightFrame],
    ];
    self.showGotItButton = NO;
    NSMutableArray *arrows = [NSMutableArray array];
    TBMHintArrow *arrow = [TBMHintArrow arrowWithText:@"Surprise feature waiting \n Just Zazo someone else!"
                                            curveKind:TBMTutorialArrowCurveKindLeft
                                           arrowPoint:CGPointMake(
                                                   CGRectGetMinX(highlightFrame),
                                                   CGRectGetMidY(highlightFrame) + (CGRectGetHeight(highlightFrame) / 4))
                                                angle:-95.f
                                               hidden:NO
                                                frame:self.frame];
    arrow.arrowLabel.text = self._possiblePhrases.randomObject;
    [arrows addObject:arrow];
    self.arrows = arrows;

    self.presentImage;
}

- (void)layoutSubviews
{
    [super layoutSubviews];

    [self layoutPresentImage];
}

- (void)layoutPresentImage
{
    CGRect parentBounds = self.bounds;
    CGFloat height = CGRectGetHeight(parentBounds);
    CGFloat width = CGRectGetWidth(parentBounds);
    CGFloat imageSize = width / 3;
    self.presentImage.frame = CGRectMake(
            CGRectGetMinX(parentBounds) + (width / 2) - (imageSize / 2),
            CGRectGetMinY(parentBounds) + (height / 2) + (imageSize),
            imageSize,
            imageSize
    );
}

- (UIImageView *)presentImage
{
    if (!_presentImage)
    {
        _presentImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"present-icon"]];
        _presentImage.contentMode = UIViewContentModeScaleAspectFit;
        [self addSubview:_presentImage];
    }
    return _presentImage;
}

#pragma mark - Private

- (NSArray *)_possiblePhrases
{
    return @[
            @"Unlock a secret feature \n Just Zazo someone else!",
            @"A gift is waiting \n Just Zazo someone else!",
            @"Unlock a surprise \n Just Zazo someone else!",
            @"Surprise feature waiting \n Just Zazo someone else!",
    ];
}

@end