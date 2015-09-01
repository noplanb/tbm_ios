//
// Created by Maksim Bazarov on 13/07/15.
// Copyright (c) 2015 Maksim Bazarov. All rights reserved.
//

#import "GridHelper.h"
#import "Geometry.h"

#define IS_IPHONE_4             ([[UIScreen mainScreen] bounds].size.height == 480.0f)

@interface GridHelper ()

@property(assign, nonatomic, readonly) CGRect rails;
@property(assign, nonatomic, readonly) CGFloat railsHeightToWidthRatio;
@property(strong, nonatomic) NSArray *cellFrames;

@end

@implementation GridHelper

- (void)setFrame:(CGRect)rect {
    _frame = rect;
    
    if (IS_IPHONE_4)
    {
        _spaceBetweenCells = 4.f;

    }
    else if (IS_IPHONE_5)
    {
        _spaceBetweenCells = 4.f;
    }
    else if (IS_IPHONE_6)
    {
        _spaceBetweenCells = 4.5f;
    }
    else if (IS_IPHONE_6_PLUS)
    {
        _spaceBetweenCells = 4.5f;
    }
    else if (IS_IPAD)
    {
        _spaceBetweenCells = 4.5f;
    }
    [self setCellSize];
    [self setVerticalInset];
    [self setHorizontalInset];

    [self layoutCells];

    [self setRails];
    [self setRailsHeightToWidthRatio];
}

- (void)layoutCells {
    CGFloat x = self.horizontalInset;
    CGFloat y = self.verticalInset;
    NSMutableArray *cellsFrames = [NSMutableArray new];
    for (int yIndex = 0; yIndex < 3; yIndex++) {
        for (int xIndex = 0; xIndex < 3; xIndex++) {
            CGFloat newX = x + xIndex*(self.cellSize.width + self.spaceBetweenCells);
            CGFloat newY = y + yIndex*(self.cellSize.height + self.spaceBetweenCells);
            CGRect frame = CGRectMake(newX, newY, self.cellSize.width, self.cellSize.height);
            [cellsFrames addObject:[NSValue valueWithCGRect:frame]];
        }
    }
    NSMutableArray *res = [cellsFrames mutableCopy];
    NSArray *transform;
    transform = [self cellMatrix];
    for (int index = 0; index < 9; index++) {
        res[index] = cellsFrames[[transform[index] unsignedIntegerValue]];
    }
    self.cellFrames = [res copy];
}

#pragma mark - Private

- (NSArray *)cellMatrix {
    return @[@(0), @(1), @(2), @(5), @(8), @(7), @(6), @(3), @(4)];;
}

- (void)setCellSize
{
    
    CGSize size;
    
    if (IS_IPHONE_4)
    {
        size = CGSizeMake(96, 128);
    }
    else if(IS_IPHONE_5)
    {
     size = CGSizeMake(96, 137.5);
    }
    else if (IS_IPHONE_6)
    {
        size = CGSizeMake(114, 163);
    }
    else if (IS_IPHONE_6_PLUS)
    {
        size = CGSizeMake(127,182);
    }
    else if (IS_IPAD)
    {
        size = CGSizeMake(245, 308);
    }
    
    _cellSize = size;
}

- (void)setHorizontalInset
{
    _horizontalInset = (self.frame.size.width - 3*self.cellSize.width - 2*self.spaceBetweenCells)/2;
}

- (void)setVerticalInset
{
    _verticalInset = 12;
}

-(void) setRails {
    CGFloat railXMin = [self centerOfCellWithIndex:0].x;
    CGFloat railXMax = [self centerOfCellWithIndex:2].x;
    _rails = CGRectMake(railXMin, railXMin, railXMax - railXMin, railXMax - railXMin);
}

-(void)setRailsHeightToWidthRatio {
    CGFloat railYMin = [self centerOfCellWithIndex:2].y;
    CGFloat railYMax = [self centerOfCellWithIndex:4].y;
    CGFloat railXMin = [self centerOfCellWithIndex:0].x;
    CGFloat railXMax = [self centerOfCellWithIndex:2].x;
    _railsHeightToWidthRatio = (railYMax - railYMin) / (railXMax - railXMin);
}

- (CGPoint)centerOfCellWithIndex:(NSUInteger)index {
    CGPoint result = CGPointZero;

    result.x = [self.cellFrames[index] CGRectValue].origin.x + self.cellSize.width / 2;
    result.y = [self.cellFrames[index] CGRectValue].origin.y + self.cellSize.height / 2;

    return result;
}

- (void)moveCellCenter:(CGPoint *)center byAngle:(double)angle {
    CGPoint p = (*center);
    double remain = angle;

    CGRect f = self.rails;

    p.x = p.x - self.horizontalInset - self.cellSize.width / 2;
    p.y = p.y - self.verticalInset - self.cellSize.height / 2;
    p.y *= 1 / self.railsHeightToWidthRatio;

    CGPoint rotated = [Geometry rotatedPointFromPoint:p byAngle:remain onFrame:f];

    rotated.y *= self.railsHeightToWidthRatio;
    rotated.x = rotated.x + self.horizontalInset + self.cellSize.width / 2;
    rotated.y = rotated.y + self.verticalInset + self.cellSize.height / 2;

    (*center) = CGPointMake(rotated.x, rotated.y);
}

- (NSUInteger)indexForCellWithPoint:(CGPoint)point withOffset:(CGFloat)offset {
    NSUInteger index = 0;


    if (point.x < self.horizontalInset + 2 * self.cellSize.width + self.spaceBetweenCells ) {
        if (point.x > self.horizontalInset + self.cellSize.width + self.spaceBetweenCells ) {
            if (point.y < self.verticalInset + 2 * self.cellSize.height + self.spaceBetweenCells ) {
                if (point.y > self.verticalInset + self.cellSize.height + self.spaceBetweenCells ) {
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

- (NSUInteger)indexWithPoint:(CGPoint)point {
    NSUInteger res = NAN;

    NSArray *results = @[@(0), @(1), @(2), @(3), @(4), @(5), @(6), @(7), @(8)];

    NSUInteger index = 0;
    for (NSValue *boxedRect in self.cellFrames) {
        CGRect rect = [boxedRect CGRectValue];
        if (point.x > rect.origin.x && point.x < rect.origin.x + rect.size.width) {
            if (point.y > rect.origin.y && point.y < rect.origin.y + rect.size.height) {
                res = [results[index] unsignedIntegerValue];
                return res;
            }
        }
        index++;
    }
    return res;
}

@end