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
@property (nonatomic, strong) NSArray *cellFlowFrames;

@property(assign, nonatomic) CGFloat verticalInset;
@property(assign, nonatomic) CGFloat horizontalInset;

@property (nonatomic, strong) NSArray* originalFrames;

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
    
    self.originalFrames = cellsFrames;
    
    NSMutableArray *res = [cellsFrames mutableCopy];
    NSArray *transform;
    transform = [self cellMatrix];
    
    for (int index = 0; index < 9; index++)
    {
        NSUInteger flowIndex = [transform[index] unsignedIntegerValue];
        res[index] = cellsFrames[flowIndex];
    }
    self.cellFlowFrames = [res copy];
}


#pragma mark - Private

- (NSArray *)cellMatrix
{
    return @[@(ZZGridSpinPositionTypeTopLeft),
             @(ZZGridSpinPositionTypeTopCenter),
             @(ZZGridSpinPositionTypeTopRight),
             @(ZZGridSpinPositionTypeCenterRight),
             @(ZZGridSpinPositionTypeBottomRight),
             @(ZZGridSpinPositionTypeBottomCenter),
             @(ZZGridSpinPositionTypeBottomLeft),
             @(ZZGridSpinPositionTypeCenterLeft),
             @(ZZGridSpinPositionTypeCamera)];
}

- (void)setRails
{
    CGFloat railXMin = [self centerCellPointWithNormalIndex:ZZGridSpinPositionTypeTopLeft].x;
    CGFloat railXMax = [self centerCellPointWithNormalIndex:ZZGridSpinPositionTypeTopRight].x;
    _rails = CGRectMake(railXMin, railXMin, railXMax - railXMin, railXMax - railXMin);
}

- (void)setRailsHeightToWidthRatio
{
    CGFloat railYMin = [self centerCellPointWithNormalIndex:ZZGridSpinPositionTypeTopLeft].y;
    CGFloat railYMax = [self centerCellPointWithNormalIndex:ZZGridSpinPositionTypeBottomLeft].y;
    CGFloat railXMin = [self centerCellPointWithNormalIndex:ZZGridSpinPositionTypeTopLeft].x;
    CGFloat railXMax = [self centerCellPointWithNormalIndex:ZZGridSpinPositionTypeTopRight].x;
    _railsHeightToWidthRatio = (railYMax - railYMin) / (railXMax - railXMin);
}

- (CGPoint)centerCellPointWithNormalIndex:(NSUInteger)index
{
    CGPoint result = CGPointZero;
    if (self.cellFlowFrames.count > index)
    {
        NSValue* frameValue = self.originalFrames[index];
        CGRect frame = [frameValue CGRectValue];
        
        result = CGPointMake(CGRectGetMidX(frame), CGRectGetMidY(frame));
    }

    return result;
}

- (void)moveCellCenter:(CGPoint*)center byAngle:(double)angle
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

- (BOOL)isCameraCellInPoint:(CGPoint)point
{
    return CGRectContainsPoint([[self.originalFrames objectAtIndex:ZZGridSpinPositionTypeCamera] CGRectValue], point);
}

//- (void)updateOriginalFramesWithActualFrames:(NSArray*)frames
//{
//    self.originalFrames = [frames copy];
//}

- (NSArray*)initialFrames
{
    return self.originalFrames;
}

@end