//  Zazo
//
//  Created by Oksana Kovalchuk on 1/11/15.
//  Copyright (c) 2015 ANODA. All rights reserved.
//

#import <pop/POPAnimatableProperty.h>
#import "ZZMovingGridView.h"
#import "ZZRotator.h"
#import "ZZGridHelper.h"

#import "ZZFakeRotationCell.h"
#import "ZZGridView.h"


@interface ZZMovingGridView ()

@property (nonatomic, assign) CGFloat startOffset;
@property (nonatomic, assign) BOOL touchedWhileAnimation;

@end

@implementation ZZMovingGridView

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        self.grid = [[ZZGridHelper alloc] init];
        
        self.rotator = [[ZZRotator alloc] initWithAnimationCompletionBlock:^{
            self.isGridMoved = NO;
            [self.delegate rotationStoped];
        }];
        
        [self.grid setFrame:self.frame];
        
        CGFloat offsetMax = (CGFloat) (M_PI * 2);
        
        _maxCellsOffset = offsetMax;
        _cellsOffset = 0.f;
    }
    return self;
}


- (void)handleRotationGesture:(ZZRotationGestureRecognizer *)recognizer
{
    switch (recognizer.state)
    {
        case UIGestureRecognizerStateBegan:
        {
            NSLog(@"ZZMOVINGGRIDVIEW START TOUCH");
            [self.tapRecognizer setEnabled:NO];
            self.startOffset = self.cellsOffset;
        } break;
        case UIGestureRecognizerStateChanged:
        {
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
        case UIGestureRecognizerStateEnded:
        {
            self.isGridMoved = YES;
            [self.tapRecognizer setEnabled:YES];
            [self.rotator decayAnimationWithVelocity:[recognizer angleVelocityInView:self] onCarouselView:self];
        }
            break;
        default: break;
    }
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    [self.grid setFrame:self.bounds];
}


- (void)placeCells
{
    [self.rotator rotateCells:self.cells onAngle:self.cellsOffset withGrid:self.grid];
}

- (void)bounceCells
{
    self.cellsOffset = self.cellsOffset;
    CGFloat angle = [ZZGeometryHelper nearestFixedPositionFrom:self.cellsOffset];
    [self.rotator bounceAnimationToAngle:angle onCarouselView:self];
}

- (void)setCellsOffset:(CGFloat)cellsOffset
{
    _cellsOffset = cellsOffset;
    while (_cellsOffset > _maxCellsOffset)
    {
        _cellsOffset -= _maxCellsOffset;
    }
    while (_cellsOffset < 0)
    {
        _cellsOffset += _maxCellsOffset;
    }
    [self placeCells];
}

-(void) setCells:(NSArray *)cells
{
    _cells = cells;
    for (ZZFakeRotationCell *cell in cells)
    {
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

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
    if ([gestureRecognizer isEqual:self.longPressRecognizer])
    {
        BOOL isCellsInPlace = fabs(self.cellsOffset - [ZZGeometryHelper nearestFixedPositionFrom:self.cellsOffset]) <= 0.001;
        return  isCellsInPlace;
    }
    return YES;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer
        shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{

    if (gestureRecognizer == self.longPressRecognizer && otherGestureRecognizer == self.rotationRecognizer)
    {
        return NO;
    }
    else
    {
        return !(gestureRecognizer == self.rotationRecognizer && otherGestureRecognizer == self.longPressRecognizer);
    }
}

@end