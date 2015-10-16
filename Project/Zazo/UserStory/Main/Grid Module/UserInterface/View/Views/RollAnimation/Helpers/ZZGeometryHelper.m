//  Zazo
//
//  Created by Oksana Kovalchuk on 1/11/15.
//  Copyright (c) 2015 ANODA. All rights reserved.
//

#import "ZZGeometryHelper.h"

@implementation ZZGeometryHelper

+ (CGPoint)rotatedPointFromPoint:(CGPoint)from byAngle:(double)angle onFrame:(CGRect)frame
{
    CGPoint result;

    double startAngle = [self angleFromPoint:from onFrame:frame];

    startAngle += angle;
    while (startAngle < 0.f) {
        startAngle += 2 * M_PI;
    }
    while (startAngle >= 2 * M_PI) {
        startAngle -= 2 * M_PI;
    }

    result = [self pointForAngle:startAngle onFrame:frame];

    return result;
}

+ (CGFloat)angleFromPoint:(CGPoint)point onFrame:(CGRect)frame
{
    CGFloat res;

    CGPoint p = point;
    p.y -= 0.0005;
    CGRect f = frame;

    NSUInteger quarter = 0;

    while ([self decreaseQuarterOfPoint:&p inFrame:&f])
    {
        quarter++;
    }

    CGFloat x = p.x - f.size.width / 2;
    CGFloat y = f.size.height / 2 - p.y;

    CGFloat tg = y / x;
    res = atanf(tg);

    while (quarter != 0)
    {
        [self increaseQuarterOfAngle:&res inFrame:&f];
        quarter--;
    }

    return res;
}

+ (CGPoint)pointForAngle:(double)angle onFrame:(CGRect)frame
{
    CGPoint res;

    double a = angle;
    CGRect f = frame;
    NSUInteger quarter = 0;

    while ([self decreaseQuarterOfAngle:&a inFrame:&f])
    {
        quarter++;
    }

    double x;
    double y;
    double corner = [self angleFromPoint:CGPointMake(f.size.width, 0.f) onFrame:f];
    if (a > corner)
    {
        y = f.size.height / 2;
        x = y / tan(a);
    }
    else if (a < corner) {
        x = f.size.width / 2;
        y = x * tan(a);
    }
    else
    {
        x = f.size.width / 2;
        y = f.size.height / 2;
    }

    res = CGPointMake((CGFloat) (f.size.width / 2 + x), (CGFloat) (f.size.height / 2 - y));

    while (quarter != 0) {
        [self increaseQuarterOfPoint:&res inFrame:&f];
        quarter--;
    }

    return res;
}

+ (NSUInteger)quarterForPoint:(CGPoint)point inFrame:(CGRect)frame
{
    CGPoint center = CGPointMake(frame.size.width / 2, frame.size.height / 2);
    if (point.x > center.x)
    {
        if (point.y <= center.y)
        {
            return 0;
        } else {
            return 3;
        }
    }
    else
    {
        if (point.y < center.y)
        {
            return 1;
        }
        else
        {
            return 2;
        }
    }
}

+ (NSUInteger)quarterOfAngle:(double)angle inFrame:(CGRect)frame
{
    if (angle >= 0.f && angle < M_PI_2) {
        return 0;
    } else if (angle >= M_PI_2 && angle < M_PI) {
        return 1;
    } else if (angle >= M_PI && angle < M_PI + M_PI_2) {
        return 2;
    } else if (angle >= M_PI + M_PI_2 && angle < 2 * M_PI) {
        return 3;
    } else {
        return NAN;
    }
}

+ (ZZSpinDirection)directionWithVelocity:(CGPoint *)velocity fromAngle:(CGFloat)angle {
    ZZSpinDirection res = ZZSpinDirectionNone;
    if (angle >= 0.f && angle < M_PI_4)
    {
        if ((*velocity).y < 0)
        {
            res = ZZSpinDirectionCounterClockwise;
        }
        else if ((*velocity).y > 0)
        {
            res = ZZSpinDirectionClockwise;
        }
    }
    if (angle >= M_PI_4 && angle < 3 * M_PI_4) {
        if ((*velocity).x < 0)
        {
            res = ZZSpinDirectionCounterClockwise;
        }
        else if ((*velocity).x > 0)
        {
            res = ZZSpinDirectionClockwise;
        }
    }
    if (angle >= 3 * M_PI_4 && angle < 5 * M_PI_4)
    {
        if ((*velocity).y > 0)
        {
            res = ZZSpinDirectionCounterClockwise;
        }
        else if ((*velocity).y < 0)
        {
            res = ZZSpinDirectionClockwise;
        }
    }
    if (angle >= 5 * M_PI_4 && angle < 7 * M_PI_4)
    {
        if ((*velocity).x > 0)
        {
            res = ZZSpinDirectionCounterClockwise;
        }
        else if ((*velocity).x < 0)
        {
            res = ZZSpinDirectionClockwise;
        }
    }
    if (angle >= 7 * M_PI_4 && angle < 8 * M_PI_4) {
        if ((*velocity).y < 0)
        {
            res = ZZSpinDirectionCounterClockwise;
        } else if ((*velocity).y > 0)
        {
            res = ZZSpinDirectionClockwise;
        }
    }
    return res;
}

+ (CGFloat)nearestFixedPositionFrom:(CGFloat)currentPosition {
    CGFloat moveToAngle = currentPosition;
    if (currentPosition < M_PI_4 / 2 && currentPosition > 0)
    {
        moveToAngle = 0;
    }
    else if (currentPosition < 3 * M_PI_4 / 2 && currentPosition > M_PI_4 / 2)
    {
        moveToAngle = (CGFloat) M_PI_4;
    }
    else if (currentPosition < 5 * M_PI_4 / 2 && currentPosition > 3 * M_PI_4 / 2)
    {
        moveToAngle = (CGFloat) M_PI_2;
    }
    else if (currentPosition < 7 * M_PI_4 / 2 && currentPosition > 5 * M_PI_4 / 2)
    {
        moveToAngle = (CGFloat) (3 * M_PI_4);
    }
    else if (currentPosition < 9 * M_PI_4 / 2 && currentPosition > 7 * M_PI_4 / 2)
    {
        moveToAngle = (CGFloat) M_PI;
    }
    else if (currentPosition < 11 * M_PI_4 / 2 && currentPosition > 9 * M_PI_4 / 2)
    {
        moveToAngle = (CGFloat) (5 * M_PI_4);
    }
    else if (currentPosition < 13 * M_PI_4 / 2 && currentPosition > 11 * M_PI_4 / 2)
    {
        moveToAngle = (CGFloat) (3 * M_PI_2);
    }
    else if (currentPosition < 15 * M_PI_4 / 2 && currentPosition > 13 * M_PI_4 / 2)
    {
        moveToAngle = (CGFloat) (7 * M_PI_4);
    }
    else if (currentPosition < 16 * M_PI_4 / 2 && currentPosition > 15 * M_PI_4 / 2)
    {
        moveToAngle = (CGFloat) (2 * M_PI);
    }
    return moveToAngle;
}

+ (CGFloat)nextFixedPositionFrom:(CGFloat)currentPosition withDirection:(ZZSpinDirection) direction
{
    CGFloat moveToAngle = currentPosition;

    while (currentPosition > (CGFloat)(2*M_PI)) {
        currentPosition -= (CGFloat)(2*M_PI);
    }
    while (currentPosition < 0) {
        currentPosition += (CGFloat)(2*M_PI);
    }

    if (currentPosition < M_PI_4 && currentPosition >= 0)
    {
        moveToAngle = direction == ZZSpinDirectionClockwise ? 0.f : (CGFloat) M_PI_4;
    }
    else if (currentPosition < M_PI_2 && currentPosition >= M_PI_4)
    {
        moveToAngle = direction == ZZSpinDirectionClockwise ? (CGFloat) M_PI_4 : (CGFloat) M_PI_2;
    }
    else if (currentPosition < 3 * M_PI_4 && currentPosition >= M_PI_2)
    {
        moveToAngle = direction == ZZSpinDirectionClockwise ? (CGFloat) M_PI_2 : (CGFloat) (3 * M_PI_4);
    }
    else if (currentPosition < M_PI && currentPosition >= 3 * M_PI_4)
    {
        moveToAngle = direction == ZZSpinDirectionClockwise ?(CGFloat) (3 * M_PI_4) : (CGFloat) M_PI;
    }
    else if (currentPosition < 5 * M_PI_4 && currentPosition >= M_PI)
    {
        moveToAngle = direction == ZZSpinDirectionClockwise ?(CGFloat) M_PI : (CGFloat)(5*M_PI_4);
    }
    else if (currentPosition < 3 * M_PI_2 && currentPosition >= 5 * M_PI_4)
    {
        moveToAngle = direction == ZZSpinDirectionClockwise ?(CGFloat) (5 * M_PI_4) : (CGFloat) (3 * M_PI_2);
    }
    else if (currentPosition < 7 * M_PI_4 && currentPosition >= 3 * M_PI_2)
    {
        moveToAngle = direction == ZZSpinDirectionClockwise ?(CGFloat) (3 * M_PI_2) : (CGFloat)(7 * M_PI_4);
    }
    else if (currentPosition < 2 * M_PI && currentPosition >= 7 * M_PI_4)
    {
        moveToAngle = direction == ZZSpinDirectionClockwise ? (CGFloat) (7 * M_PI_4) : (CGFloat)(2 * M_PI);
    }
    return moveToAngle;
}

#pragma mark - Private

+ (BOOL)increaseQuarterOfPoint:(CGPoint *)point inFrame:(CGRect *)frame {
    NSUInteger quarter = [self quarterForPoint:*point inFrame:*frame];
    if (quarter == 3) {
        return NO;
    } else {
        *point = CGPointMake((*point).y, (*frame).size.width - (*point).x);
        *frame = CGRectMake(0.f, 0.f, (*frame).size.height, (*frame).size.width);
    }
    return YES;
}

+ (BOOL)increaseQuarterOfAngle:(CGFloat *)angle inFrame:(CGRect *)frame {
    if ([self quarterOfAngle:(*angle) inFrame:(*frame)] == 3) {
        return NO;
    }
    *angle += M_PI_2;
    *frame = CGRectMake(0.f, 0.f, (*frame).size.height, (*frame).size.width);
    return YES;
}

+ (BOOL)decreaseQuarterOfPoint:(CGPoint *)point inFrame:(CGRect *)frame {
    NSUInteger quarter = [self quarterForPoint:*point inFrame:*frame];
    if (quarter == 0) {
        return NO;
    } else {
        *point = CGPointMake((*frame).size.height - (*point).y, (*point).x);
        *frame = CGRectMake(0.f, 0.f, (*frame).size.height, (*frame).size.width);
    }
    return YES;
}

+ (BOOL)decreaseQuarterOfAngle:(double *)angle inFrame:(CGRect *)frame {
    if ([self quarterOfAngle:(*angle) inFrame:(*frame)] == 0) {
        return NO;
    }
    *angle -= M_PI_2;
    *frame = CGRectMake(0.f, 0.f, (*frame).size.height, (*frame).size.width);
    return YES;
}

+ (CGFloat)normalizedAngle:(CGFloat)angle withMaxCellOffset:(CGFloat)maxCellsOffset
{
    while (angle > maxCellsOffset)
    {
        angle -= maxCellsOffset;
    }
    while (angle < 0)
    {
        angle += maxCellsOffset;
    }
    return angle;
}

@end