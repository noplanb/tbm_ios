//
// Created by Maksim Bazarov on 16/06/15.
// Copyright (c) 2015 No Plan B. All rights reserved.
//

#import "TBMRecordWelcomeHintView.h"

@implementation TBMRecordWelcomeHintView
{

}
- (void)configureHint
{
    CGRect highlightFrame = [self.gridModule gridGetFrameForFriend:0 inView:self.superview];
    self.dismissAfterAction = YES;
    self.framesToCutOut = @[
            [UIBezierPath bezierPathWithRect:highlightFrame],
    ];
    self.showGotItButton = NO;
    NSString *friendName = [self.gridModule lastAddedFriendOnGridName];
    if (!self.arrows)
    {
        NSMutableArray *arrows = [NSMutableArray array];
        NSString *arrowText = [NSString stringWithFormat:@"Press and hold to record \n a welcome message for %@",friendName];
        [arrows addObject:[TBMHintArrow arrowWithText:arrowText
                                            curveKind:TBMTutorialArrowCurveKindRight
                                           arrowPoint:CGPointMake(
                                                   CGRectGetMinX(highlightFrame),
                                                   CGRectGetMidY(highlightFrame))
                                                angle:-40.f
                                               hidden:NO
                                                frame:self.frame]];

        self.arrows = arrows;

    }
}

@end