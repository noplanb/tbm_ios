//
// Created by Maksim Bazarov on 16/06/15.
// Copyright (c) 2015 No Plan B. All rights reserved.
//

#import "TBMPlayHint.h"

@implementation TBMPlayHint {

}
- (void)configureHint {
    CGRect highlightFrame = [self.gridDelegate gridGetFrameForFriend:0 inView:self.superview];
    self.dismissAfterAction = YES;
    self.framesToCutOut = @[
            [UIBezierPath bezierPathWithRect:highlightFrame],
    ];
    self.showGotItButton = YES;
    NSMutableArray *arrows = [NSMutableArray array];
    [arrows addObject:[TBMHintArrow arrowWithText:@"Tap to play"
                                        curveKind:TBMTutorialArrowCurveKindRight
                                       arrowPoint:CGPointMake(
                                               CGRectGetMinX(highlightFrame),
                                               CGRectGetMidY(highlightFrame))
                                            angle:-40.f
                                           hidden:NO
                                            frame:self.frame]];

    self.arrows = arrows;
}

- (void)addRecordTip {
    CGRect highlightFrame = [self.gridDelegate gridGetFrameForFriend:0 inView:self.superview];
    NSMutableArray *arrows = [self.arrows mutableCopy];
    [arrows addObject:[TBMHintArrow arrowWithText:@"Press and hold to record"
                                        curveKind:TBMTutorialArrowCurveKindRight
                                       arrowPoint:CGPointMake(
                                               CGRectGetMinX(highlightFrame),
                                               CGRectGetMinY(highlightFrame))
                                            angle:-60.f
                                           hidden:YES
                                            frame:self.frame]];

    self.arrows = arrows;
}
@end