//  Zazo
//
//  Created by Oksana Kovalchuk on 1/11/15.
//  Copyright (c) 2015 ANODA. All rights reserved.
//


#import "ZZGridHelper.h"
#import "ZZGeometryHelper.h"
#import "ZZGridUIConstants.h"

@interface ZZGridHelper ()

@property (nonatomic, assign, readonly) CGRect rails;
@property (nonatomic, assign, readonly) CGFloat railsHeightToWidthRatio;
@property (nonatomic, strong) NSArray *cellFrames;

/**
 * space between top border of frame and top cell
 * equals to space between bottom border of frame and bottom cell
 */
@property(assign, nonatomic) CGFloat verticalInset;

/**
 * space between left border of frame and left cell
 * equals to space between right border of frame and right cell
 */
@property(assign, nonatomic) CGFloat horizontalInset;

@end

@implementation ZZGridHelper

- (CGFloat)spaceBetweenCells
{
    return kGridItemSpacing();
}

- (CGSize)cellSize
{
    return kGridItemSize();
}

- (void)setFrame:(CGRect)rect
{
    _frame = rect;

    self.horizontalInset = (rect.size.width - 3 * self.cellSize.width - 2 * self.spaceBetweenCells) / 2;
    self.verticalInset = 5;
    
    [self layoutCells];

    [self setRails];
    [self setRailsHeightToWidthRatio];
}

- (void)layoutCells
{
    CGFloat x = self.horizontalInset;
    CGFloat y = self.verticalInset;
    NSMutableArray *cellsFrames = [NSMutableArray new];
    for (int yIndex = 0; yIndex < 3; yIndex++)
    {
        for (int xIndex = 0; xIndex < 3; xIndex++)
        {
            CGFloat newX = x + xIndex*(self.cellSize.width + self.spaceBetweenCells);
            CGFloat newY = y + yIndex*(self.cellSize.height + self.spaceBetweenCells);
            CGRect frame = CGRectMake(newX, newY, self.cellSize.width, self.cellSize.height);
            [cellsFrames addObject:[NSValue valueWithCGRect:frame]];
        }
    }
    NSMutableArray *res = [cellsFrames mutableCopy];
    NSArray *transform;
    transform = [self cellMatrix];
    
    for (int index = 0; index < 9; index++)
    {
        NSUInteger flowIndex = [transform[index] unsignedIntegerValue];
        res[index] = cellsFrames[flowIndex];
    }
    ANDispatchBlockToMainQueue(^{
       self.cellFrames = [res copy];
    });
}


#pragma mark - Private

- (NSArray *)cellMatrix
{
    return @[@(0), @(1), @(2), @(5), @(8), @(7), @(6), @(3), @(4)];
}

- (void) setRails
{
    CGFloat railXMin = [self centerOfCellWithIndex:0].x;
    CGFloat railXMax = [self centerOfCellWithIndex:2].x;
    _rails = CGRectMake(railXMin, railXMin, railXMax - railXMin, railXMax - railXMin);
}

- (void)setRailsHeightToWidthRatio
{
    CGFloat railYMin = [self centerOfCellWithIndex:2].y;
    CGFloat railYMax = [self centerOfCellWithIndex:4].y;
    CGFloat railXMin = [self centerOfCellWithIndex:0].x;
    CGFloat railXMax = [self centerOfCellWithIndex:2].x;
    _railsHeightToWidthRatio = (railYMax - railYMin) / (railXMax - railXMin);
}

- (CGPoint)centerOfCellWithIndex:(NSUInteger)index
{
    CGPoint result = CGPointZero;

    result.x = [self.cellFrames[index] CGRectValue].origin.x + self.cellSize.width / 2;
    result.y = [self.cellFrames[index] CGRectValue].origin.y + self.cellSize.height / 2;

    return result;
}

- (void)moveCellCenter:(CGPoint *)center byAngle:(double)angle
{
    CGPoint p = (*center);
    double remain = angle;

    CGRect f = self.rails;

    p.x = p.x - self.horizontalInset - self.cellSize.width / 2;
    p.y = p.y - self.verticalInset - self.cellSize.height / 2;
    p.y *= 1 / self.railsHeightToWidthRatio;

    CGPoint rotated = [ZZGeometryHelper rotatedPointFromPoint:p byAngle:remain onFrame:f];

    rotated.y *= self.railsHeightToWidthRatio;
    rotated.x = rotated.x + self.horizontalInset + self.cellSize.width / 2;
    rotated.y = rotated.y + self.verticalInset + self.cellSize.height / 2;

    (*center) = CGPointMake(rotated.x, rotated.y);
}

- (NSUInteger)indexForCellWithPoint:(CGPoint)point withOffset:(CGFloat)offset
{
    NSUInteger index = 0;


    if (point.x < self.horizontalInset + 2 * self.cellSize.width + self.spaceBetweenCells )
    {
        if (point.x > self.horizontalInset + self.cellSize.width + self.spaceBetweenCells )
        {
            if (point.y < self.verticalInset + 2 * self.cellSize.height + self.spaceBetweenCells )
            {
                if (point.y > self.verticalInset + self.cellSize.height + self.spaceBetweenCells )
                {
                    return 8;
                }
            }
        }
    }
    CGPoint pointWithoutOffset = point;
    [self moveCellCenter:&pointWithoutOffset byAngle:(-offset)];

    index = [self indexWithPoint:pointWithoutOffset];
    return index;
}

- (NSUInteger)indexWithPoint:(CGPoint)point
{
    NSUInteger res = NAN;

    NSArray *results = @[@(0), @(1), @(2), @(3), @(4), @(5), @(6), @(7), @(8)];

    NSUInteger index = 0;
    for (NSValue *boxedRect in self.cellFrames)
    {
        CGRect rect = [boxedRect CGRectValue];
        
        if (point.x > rect.origin.x && point.x < rect.origin.x + rect.size.width)
        {
            if (point.y > rect.origin.y && point.y < rect.origin.y + rect.size.height)
            {
                res = [results[index] unsignedIntegerValue];
                return res;
            }
        }
        index++;
    }
    return res;
}

@end