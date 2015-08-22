//
// Created by Maksim Bazarov on 16/06/15.
// Copyright (c) 2015 No Plan B. All rights reserved.
//

#import "TBMFrontCameraUsageHintView.h"

@implementation TBMFrontCameraUsageHintView {

}

- (void)configureHint {
    CGRect highlightFrame = [self.gridModule gridGetCenterCellFrameInView:self.superview];
    self.dismissAfterAction = YES;
    self.framesToCutOut = @[
            [UIBezierPath bezierPathWithRect:highlightFrame],
    ];
    self.showGotItButton = NO;
    NSMutableArray *arrows = [NSMutableArray array];
    [arrows addObject:[TBMHintArrow arrowWithText:@"Tap to switch camera."
                                        curveKind:TBMTutorialArrowCurveKindRight
                                       arrowPoint:CGPointMake(
                                               CGRectGetMinX(highlightFrame),
                                               CGRectGetMinY(highlightFrame))
                                            angle:0.f
                                           hidden:NO
                                            frame:self.frame]];

    self.arrows = arrows;
}

@end