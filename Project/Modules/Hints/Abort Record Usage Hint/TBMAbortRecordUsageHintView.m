//
// Created by Maksim Bazarov on 16/06/15.
// Copyright (c) 2015 No Plan B. All rights reserved.
//

#import "TBMAbortRecordUsageHintView.h"

@implementation TBMAbortRecordUsageHintView
{

}

- (void)configureHint
{
    CGRect highlightFrame = [self.gridModule gridGetFrameForFriend:0 inView:self.superview];
    self.dismissAfterAction = YES;
    self.framesToCutOut = @[
            [UIBezierPath bezierPathWithRect:highlightFrame],
    ];
    self.showGotItButton = YES;
    NSMutableArray *arrows = [NSMutableArray array];
    [arrows addObject:[TBMHintArrow arrowWithText:@"Abort a recording."
                                        curveKind:TBMTutorialArrowCurveKindRight
                                       arrowPoint:CGPointMake(
                                               CGRectGetMinX(highlightFrame),
                                               CGRectGetMidY(highlightFrame) - 60.f)
                                            angle:-65.f
                                           hidden:YES
                                            frame:self.frame]];

    [arrows addObject:[TBMHintArrow arrowWithText:@"Drag finger away"
                                        curveKind:TBMTutorialArrowCurveKindRight
                                       arrowPoint:CGPointMake(
                                               CGRectGetMinX(highlightFrame),
                                               CGRectGetMidY(highlightFrame) - 30.f)
                                            angle:-65.f
                                           hidden:YES
                                            frame:self.frame]];
    [arrows addObject:[TBMHintArrow arrowWithText:@"while recording."
                                        curveKind:TBMTutorialArrowCurveKindRight
                                       arrowPoint:CGPointMake(
                                               CGRectGetMinX(highlightFrame),
                                               CGRectGetMidY(highlightFrame))
                                            angle:-65.f
                                           hidden:NO
                                            frame:self.frame]];

    self.arrows = arrows;
}

@end