//
// Created by Maksim Bazarov on 16/06/15.
// Copyright (c) 2015 No Plan B. All rights reserved.
//

#import "TBMRecordHintView.h"

@interface TBMRecordHintView ()
@property(nonatomic, strong) TBMHintArrow *playArrow;
@property(nonatomic, strong) TBMHintArrow *recordArrow;
@property(nonatomic) CGRect highlightFrame;
@end

@implementation TBMRecordHintView

- (void)configureHint
{
    self.highlightFrame = [self.gridModule gridGetFrameForFriend:0 inView:self.superview];
    CGRect highlightFrame = [self.gridModule gridGetFrameForFriend:0 inView:self.superview];
    self.dismissAfterAction = YES;
    self.framesToCutOut = @[
            [UIBezierPath bezierPathWithRect:highlightFrame],
    ];
    self.showGotItButton = NO;
    [self setupRecordTip];
}

- (void)addPlayTip
{
    self.arrows = @[self.recordArrow, self.playArrow];
}

- (void)setupRecordTip
{
    self.arrows = @[self.recordArrow];
}

#pragma mark Lazy initialization

- (TBMHintArrow *)playArrow
{
    if (!_playArrow)
    {
        _playArrow = [TBMHintArrow new];
        _playArrow.text = @"Tap to play";
        _playArrow.arrowCurveKind = TBMTutorialArrowCurveKindRight;
        _playArrow.arrowPoint = CGPointMake(
                CGRectGetMinX(self.highlightFrame),
                CGRectGetMidY(self.highlightFrame));
        _playArrow.arrowAngle = -40.f;
        _playArrow.hideArrow = YES;
        _playArrow.frame = self.frame;
    }
    return _playArrow;
}

- (TBMHintArrow *)recordArrow
{
    if (!_recordArrow)
    {
        _recordArrow = [TBMHintArrow new];
        _recordArrow.text = @"Press and hold to record";
        _recordArrow.arrowCurveKind = TBMTutorialArrowCurveKindRight;
        _recordArrow.arrowPoint = CGPointMake(
                CGRectGetMinX(self.highlightFrame),
                CGRectGetMidY(self.highlightFrame));
        _recordArrow.arrowAngle = -60.f;
        _recordArrow.hideArrow = NO;
        _recordArrow.frame = self.frame;
    }
    return _recordArrow;
}

@end