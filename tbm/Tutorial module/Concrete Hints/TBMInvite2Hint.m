//
// Created by Maksim Bazarov on 16/06/15.
// Copyright (c) 2015 No Plan B. All rights reserved.
//

#import "TBMInvite2Hint.h"

@implementation TBMInvite2Hint {

}

- (void)configureHint {
    CGRect highlightFrame = [self.gridModule gridGetFrameForFriend:4 inView:self.superview];
    self.dismissAfterAction = YES;
    self.framesToCutOut = @[
            [UIBezierPath bezierPathWithRect:highlightFrame],
    ];
    self.showGotItButton = NO;
    NSMutableArray *arrows = [NSMutableArray array];
    [arrows addObject:[TBMHintArrow arrowWithText:@"Zazo someone else!"
                                        curveKind:TBMTutorialArrowCurveKindRight
                                       arrowPoint:CGPointMake(
                                               CGRectGetMidX(highlightFrame),
                                               CGRectGetMaxY(highlightFrame))
                                            angle:-180.f
                                           hidden:NO
                                            frame:self.frame]];

    self.arrows = arrows;
}

@end