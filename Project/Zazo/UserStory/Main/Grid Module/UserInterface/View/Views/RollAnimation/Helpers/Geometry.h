//
// Created by Maksim Bazarov on 13/07/15.
// Copyright (c) 2015 Maksim Bazarov. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@class Grid;

typedef NS_ENUM(NSInteger, SpinDirection) {
    SpinNone = 0,
    SpinClockwise,
    SpinCounterClockwise
};

/**
* Геометрия - расчет секторов, позиций, скоростей и прочего ответсвенность:
- Рассчитывать сложные математические расчеты основанные на геометрии (например синусУгла или угловаяСкорость)
*/
@interface Geometry : NSObject

/**
* Rotating point by angle as if it was placed on a circle with frame.width/2 frame.height/2
*/
+ (CGPoint)rotatedPointFromPoint:(CGPoint)from byAngle:(double)angle onFrame:(CGRect)frame;

/**
* Getting angle of point as if it was placed on a circle with frame.width/2 frame.height/2
*/
+ (CGFloat)angleFromPoint:(CGPoint)point onFrame:(CGRect)frame;

/**
* Getting point on frame border.
* Angle between (frame.width, frame.height/2),(frame.width/2, frame.height/2) and that point will result on given angle
*/
+ (CGPoint)pointForAngle:(double)angle onFrame:(CGRect)frame;

/**
* getting quarter of point in frame. Right Top quarter is 0, counting counterclockwise
*/
+ (NSUInteger)quarterForPoint:(CGPoint)point inFrame:(CGRect)frame;

/**
* getting quarter of angle in frame. Right Top quarter is 0, counting counterclockwise
*/
+ (NSUInteger)quarterOfAngle:(double)angle inFrame:(CGRect)frame;

/**
* get direction from linear velocity and angle
*/
+ (SpinDirection)directionWithVelocity:(CGPoint *)velocity fromAngle:(CGFloat)angle;


/**
* get nearest fixed position from offset
*/
+ (CGFloat)nearestFixedPositionFrom:(CGFloat)currentPosition;

+ (CGFloat)nextFixedPositionFrom:(CGFloat)currentPosition withDirection:(SpinDirection)direction;

/**
* get angle between 0. and grid.maxCellsOffset
*/
+ (CGFloat)normalizedAngle:(CGFloat)angle onGrid:(Grid *)grid;
@end