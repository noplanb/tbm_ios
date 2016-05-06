//  Zazo
//
//  Created by Oksana Kovalchuk on 1/11/15.
//  Copyright (c) 2015 ANODA. All rights reserved.
//


typedef NS_ENUM(NSInteger, ZZGridSpinPositionType)
{
    ZZGridSpinPositionTypeTopLeft,
    ZZGridSpinPositionTypeTopCenter,
    ZZGridSpinPositionTypeTopRight,
    ZZGridSpinPositionTypeCenterLeft,
    ZZGridSpinPositionTypeCamera,
    ZZGridSpinPositionTypeCenterRight,
    ZZGridSpinPositionTypeBottomLeft,
    ZZGridSpinPositionTypeBottomCenter,
    ZZGridSpinPositionTypeBottomRight
};

@interface ZZGridHelper : NSObject

@property (assign, nonatomic, readonly) CGSize cellSize;
@property (assign, nonatomic) CGFloat spaceBetweenCells;
@property (assign, nonatomic) CGRect frame;

- (CGPoint)centerCellPointWithNormalIndex:(NSUInteger)index;

- (void)moveCellCenter:(CGPoint *)center byAngle:(double)angle;

- (BOOL)isCameraCellInPoint:(CGPoint)point;

@end