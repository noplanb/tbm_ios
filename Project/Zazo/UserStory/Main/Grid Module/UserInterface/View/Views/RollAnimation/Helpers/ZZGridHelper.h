//  Zazo
//
//  Created by Oksana Kovalchuk on 1/11/15.
//  Copyright (c) 2015 ANODA. All rights reserved.
//


@interface ZZGridHelper : NSObject


/**
* size of a cell
*/
@property(assign, nonatomic, readonly) CGSize cellSize;

/**
* space between cells
*/
@property(assign, nonatomic) CGFloat spaceBetweenCells;



/**
* frame to place cells
*/
@property(assign, nonatomic) CGRect frame;

/**
* center of cell in index
*/
- (CGPoint)centerOfCellWithIndex:(NSUInteger)index;

/**
* moving center
*/
- (void)moveCellCenter:(CGPoint *)center byAngle:(double)angle;

/**
* index for cell, containing point, after applying offset
*/
- (NSUInteger)indexForCellWithPoint:(CGPoint)point withOffset:(CGFloat)offset;

/**
* index for cell, containing point, with zero offset
*/
- (NSUInteger)indexWithPoint:(CGPoint)point;

@end