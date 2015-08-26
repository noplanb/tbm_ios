//
// Created by Maksim Bazarov on 16/06/15.
// Copyright (c) 2015 No Plan B. All rights reserved.
//

#import "TBMEarpieceUsageHintView.h"

@implementation TBMEarpieceUsageHintView
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

    [arrows addObject:[TBMHintArrow arrowWithText:@"Play quietly. /n Tap to play. Then hold phone to ear."
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