//  Zazo
//
//  Created by Oksana Kovalchuk on 1/11/15.
//  Copyright (c) 2015 ANODA. All rights reserved.
//

typedef NS_ENUM(NSInteger, ZZSpinDirection) {
    ZZSpinDirectionNone = 0,
    ZZSpinDirectionClockwise,
    ZZSpinDirectionCounterClockwise
};

@interface ZZGeometryHelper : NSObject

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
+ (ZZSpinDirection)directionWithVelocity:(CGPoint)velocity fromAngle:(CGFloat)angle gridFrame:(CGRect)frame;

+ (CGFloat)nextFixedPositionFrom:(CGFloat)currentPosition withDirection:(ZZSpinDirection)direction;

/**
* get angle between 0. and grid.maxCellsOffset
*/
+ (CGFloat)normalizedAngle:(CGFloat)angle withMaxCellOffset:(CGFloat)maxCellsOffset;

@end
