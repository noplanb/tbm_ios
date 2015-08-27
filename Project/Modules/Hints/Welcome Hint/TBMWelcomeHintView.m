//
// Created by Maksim Bazarov on 16/06/15.
// Copyright (c) 2015 No Plan B. All rights reserved.
//

#import "TBMWelcomeHintView.h"
#import "TBMFriend.h"
#import "TBMGridElement.h"

@implementation TBMWelcomeHintView
{

}
/**
 * Matrix need for get button,angle and curve kind values for 0..7th grid element
 */
- (NSArray *)buttonMatrix
{
    return @[@(NO), @(NO), @(NO), @(NO), @(NO), @(NO), @(NO), @(NO)];
}

- (NSArray *)angles1Matrix
{
    return @[@(-36.f), @(0.f), @(-36.f), @(45.f), @(-120.f), @(36.f), @(-125.f), @(120.f)];
}

- (NSArray *)angles2Matrix
{
    return @[@(-56.f), @(-60.f), @(-66.f), @(70.f), @(-180.f), @(63.f), @(-200.f), @(140.f)];
}

- (NSArray *)arrowKindMatrix
{
    return @[@(TBMTutorialArrowCurveKindRight),
            @(TBMTutorialArrowCurveKindRight),
            @(TBMTutorialArrowCurveKindRight),
            @(TBMTutorialArrowCurveKindLeft),
            @(TBMTutorialArrowCurveKindLeft),
            @(TBMTutorialArrowCurveKindLeft),
            @(TBMTutorialArrowCurveKindLeft),
            @(TBMTutorialArrowCurveKindRight)];
}

- (void)configureHint
{
    NSUInteger friendIndexInGrid = [self.gridModule lastAddedFriendOnGridIndex];
    NSString *friendName = [self.gridModule lastAddedFriendOnGridName];
    CGRect highlightFrame = [self.gridModule gridGetFrameForFriend:friendIndexInGrid inView:self.superview];
    CGPoint arrowPoint = CGPointZero;
    TBMHintArrowCurveKind curveKind = [self.arrowKindMatrix[friendIndexInGrid] integerValue];
    CGFloat angle1 = [self.angles1Matrix[friendIndexInGrid] floatValue];
    CGFloat angle2 = [self.angles2Matrix[friendIndexInGrid] floatValue];
    BOOL button = [self.buttonMatrix[friendIndexInGrid] boolValue];
    self.dismissAfterAction = YES;
    self.framesToCutOut = @[
            [UIBezierPath bezierPathWithRect:highlightFrame],
    ];

    if (friendIndexInGrid == 3 || friendIndexInGrid == 5 || friendIndexInGrid == 7)
    {
        arrowPoint = CGPointMake(CGRectGetMaxX(highlightFrame), CGRectGetMidY(highlightFrame));
    } else
    {
        arrowPoint = CGPointMake(CGRectGetMinX(highlightFrame), CGRectGetMidY(highlightFrame));
    };

    self.showGotItButton = button;
    NSMutableArray *arrows = [NSMutableArray array];


    NSString *sendString = friendName ? [NSString stringWithFormat:@"Send %@", friendName] : @"Send";
    [arrows addObject:[TBMHintArrow arrowWithText:sendString
                                        curveKind:curveKind
                                       arrowPoint:arrowPoint
                                            angle:angle1
                                           hidden:NO
                                            frame:self.frame]];

    [arrows addObject:[TBMHintArrow arrowWithText:@"a welcome Zazo"
                                        curveKind:curveKind
                                       arrowPoint:arrowPoint
                                            angle:angle2
                                           hidden:YES
                                            frame:self.frame]];

    self.arrows = arrows;
}

@end