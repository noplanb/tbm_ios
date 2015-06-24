//
// Created by Maksim Bazarov on 16/06/15.
// Copyright (c) 2015 No Plan B. All rights reserved.
//

#import "TBMWelcomeHint.h"

@implementation TBMWelcomeHint {

}
/**
 * Matrix need for get button,angle and curve kind values for 0..7th grid element
 */
- (NSArray *)buttonMatrix {
    return @[@(YES), @(NO), @(NO), @(NO), @(YES), @(YES), @(YES), @(YES)];
}

- (NSArray *)anglesMatrix {
    return @[@(-36.f), @(0.f), @(-36.f), @(45.f), @(-150.f), @(36.f), @(-170.f), @(120.f)];
}

- (NSArray *)arrowKindMatrix {
    return @[@(TBMTutorialArrowCurveKindRight),
            @(TBMTutorialArrowCurveKindRight),
            @(TBMTutorialArrowCurveKindRight),
            @(TBMTutorialArrowCurveKindLeft),
            @(TBMTutorialArrowCurveKindLeft),
            @(TBMTutorialArrowCurveKindLeft),
            @(TBMTutorialArrowCurveKindLeft),
            @(TBMTutorialArrowCurveKindRight)];
}

- (void)configureHint {
    NSUInteger friendIndexInGrid = [self.gridModule lastAddedFriendOnGridIndex];
    CGRect highlightFrame = [self.gridModule gridGetFrameForFriend:friendIndexInGrid inView:self.superview];
    CGPoint arrowPoint = CGPointZero;
    TBMHintArrowCurveKind curveKind = [self.arrowKindMatrix[friendIndexInGrid] integerValue];
    CGFloat angle = [self.anglesMatrix[friendIndexInGrid] floatValue];
    BOOL button = [self.buttonMatrix[friendIndexInGrid] boolValue];
    self.dismissAfterAction = YES;
    self.framesToCutOut = @[
            [UIBezierPath bezierPathWithRect:highlightFrame],
    ];

    if (friendIndexInGrid == 3 || friendIndexInGrid == 5 || friendIndexInGrid == 7) {
        arrowPoint = CGPointMake(CGRectGetMaxX(highlightFrame), CGRectGetMidY(highlightFrame));
    } else {
        arrowPoint = CGPointMake(CGRectGetMinX(highlightFrame), CGRectGetMidY(highlightFrame));
    };

    self.showGotItButton = button;
    NSMutableArray *arrows = [NSMutableArray array];

    [arrows addObject:[TBMHintArrow arrowWithText:@"Send a welcome Zazo"
                                        curveKind:curveKind
                                       arrowPoint:arrowPoint
                                            angle:angle
                                           hidden:NO
                                            frame:self.frame]];

    self.arrows = arrows;
}

@end