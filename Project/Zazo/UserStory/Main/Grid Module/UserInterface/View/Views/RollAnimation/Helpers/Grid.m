//
// Created by Maksim Bazarov on 13/07/15.
// Copyright (c) 2015 Maksim Bazarov. All rights reserved.
//

#import <pop/POPAnimatableProperty.h>
#import "Grid.h"
#import "Rotator.h"
#import "GridHelper.h"

#import "Cell.h"
#import "ZZGridView.h"


@interface Grid ()

@property(nonatomic) CGFloat startOffset;
@property(nonatomic) BOOL touchedWhileAnimation;

@end

@implementation Grid

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self calculateDefaults];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        [self calculateDefaults];
    }
    return self;
}

- (void)calculateDefaults {
    self.grid = [[GridHelper alloc] init];
    
    self.rotator = [[Rotator alloc] initWithAnimationCompletionBlock:^{
        [self.delegate rotationStoped];
    }];

    [self.grid setFrame:self.frame];

    CGFloat offsetMax = (CGFloat) (M_PI * 2);

    _maxCellsOffset = offsetMax;
    _cellsOffset = 0.f;
}

- (void)handleRotationGesture:(RotationGestureRecognizer *)recognizer {
    switch (recognizer.state) {
        case UIGestureRecognizerStateBegan:
            [self.tapRecognizer setEnabled:NO];
//            [self.rotator stopAnimationsOnGrid:self];
            self.startOffset = self.cellsOffset;
        case UIGestureRecognizerStateChanged: {
            CGPoint point = [recognizer locationInView:self];

            CGFloat currentAngle = [recognizer currentAngleInView:self];
            CGFloat startAngle = [recognizer startAngleInView:self];
            CGFloat deltaAngle = (CGFloat)((CGFloat)currentAngle - (CGFloat)startAngle);
            NSUInteger indexPath = [self.grid indexWithPoint:point];
            if (indexPath == 8) {
                return;
            }
            self.cellsOffset = self.startOffset + (CGFloat) (deltaAngle);
        }
            break;
        case UIGestureRecognizerStateCancelled:
        case UIGestureRecognizerStateEnded: {
            [self.tapRecognizer setEnabled:YES];
            [self.rotator decayAnimationWithVelocity:[recognizer angleVelocityInView:self] onCarouselView:self];
        }
            break;
        default: {
            // Do nothing...
        }
            break;
    }
}

-(void)layoutSubviews {
    [self.grid setFrame:self.frame];
}


- (void)placeCells {
    [self.rotator rotateCells:self.cells onAngle:self.cellsOffset withGrid:self.grid];
}

- (void)bounceCells {
    self.cellsOffset = self.cellsOffset;
    CGFloat angle = [Geometry nearestFixedPositionFrom:self.cellsOffset];
    [self.rotator bounceAnimationToAngle:angle onCarouselView:self];
}

- (void)setCellsOffset:(CGFloat)cellsOffset {
    _cellsOffset = cellsOffset;
    while (_cellsOffset > _maxCellsOffset) {
        _cellsOffset -= _maxCellsOffset;
    }
    while (_cellsOffset < 0) {
        _cellsOffset += _maxCellsOffset;
    }
    [self placeCells];
}

-(void) setCells:(NSArray *)cells {
    _cells = cells;
    for (Cell *cell in cells) {
        [self addSubview:cell];
    }
    
    self.cellsOffset = 0.f;
}

- (void)removeAllCells
{
    [self.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
}

#pragma mark - <POPAnimationDelegate>

- (void)pop_animationDidApply:(POPAnimation *)anim {
    [self.rotator stopDecayAnimationIfNeeded:anim onGrid:self];
}

#pragma mark - <UIGestureRecognizerDelegate>

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    if ([gestureRecognizer isEqual:self.longPressRecognizer]) {
        BOOL isCellsInPlace = fabs(self.cellsOffset - [Geometry nearestFixedPositionFrom:self.cellsOffset]) <= 0.001;
        return  isCellsInPlace;
    }
    return YES;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer
        shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {

    if (gestureRecognizer == self.longPressRecognizer && otherGestureRecognizer == self.rotationRecognizer) {
        return NO;
    } else {
        return !(gestureRecognizer == self.rotationRecognizer && otherGestureRecognizer == self.longPressRecognizer);
    }
}

@end