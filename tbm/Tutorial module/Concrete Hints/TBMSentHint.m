//
// Created by Maksim Bazarov on 16/06/15.
// Copyright (c) 2015 No Plan B. All rights reserved.
//

#import "TBMSentHint.h"

@implementation TBMSentHint {

}

- (void)configureHint {
    CGRect highlightFrame = [self.gridModule gridGetFrameForFriend:0 inView:self.superview];
    self.dismissAfterAction = YES;
    self.framesToCutOut = @[
            [UIBezierPath bezierPathWithRect:highlightFrame],
    ];
    self.showGotItButton = YES;
    NSMutableArray *arrows = [NSMutableArray array];
    [arrows addObject:[TBMHintArrow arrowWithText:@"Zazo sent! Well done!"
                                        curveKind:TBMTutorialArrowCurveKindRight
                                       arrowPoint:CGPointMake(
                                               CGRectGetMaxX(highlightFrame)-20.f,
                                               CGRectGetMinY(highlightFrame))
                                            angle:-45.f
                                           hidden:NO
                                            frame:self.frame]];

    self.arrows = arrows;
    [self dismissAfter:3.5f];
}

- (void)dismissAfter:(NSTimeInterval)delay {
    [self performSelector:@selector(dismiss) withObject:nil afterDelay:delay];
}
@end