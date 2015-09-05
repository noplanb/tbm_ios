//  Zazo
//
//  Created by Oksana Kovalchuk on 1/11/15.
//  Copyright (c) 2015 ANODA. All rights reserved.
//


#import "ZZRotationGestureRecognizer.h"

@interface ZZRotationGestureRecognizer ()

@end

@implementation ZZRotationGestureRecognizer

- (CGFloat)startAngleInView:(UIView *)view
{
    CGPoint translation = [self translationInView:view];
    CGPoint point = [self locationInView:view];
    CGPoint centerBefore = CGPointMake(point.x - translation.x, point.y - translation.y);
    CGFloat res = [ZZGeometryHelper angleFromPoint:centerBefore onFrame:view.frame];
    return res;
}

- (CGFloat)currentAngleInView:(UIView *)view
{
    CGPoint point = [self locationInView:view];
    CGFloat res = [ZZGeometryHelper angleFromPoint:point onFrame:view.frame];
    return res;
}

- (ZZSpinDirection)directionOfSpinInView:(UIView *)view
{
    ZZSpinDirection res;
    CGPoint velocity = [self velocityInView:view];
    CGPoint point = [self locationInView:view];
    CGFloat angle = [ZZGeometryHelper angleFromPoint:point onFrame:view.frame];

    res = [ZZGeometryHelper directionWithVelocity:&velocity fromAngle:angle];

    return res;
}

- (CGFloat)angleVelocityInView:(UIView *)view
{
    CGPoint velocity = [self velocityInView:view];

    CGPoint point = [self locationInView:view];
    //radius from center view to touch
    CGFloat x = (fabsf(point.x) - view.frame.size.width / 2);
    CGFloat y = (fabsf(point.y) - view.frame.size.height / 2);
    CGFloat radius = sqrtf(x * x + y * y);

    CGFloat angleVelocity = (CGFloat) sqrtf(velocity.x * velocity.x + velocity.y * velocity.y) / radius;

    ZZSpinDirection direction = [self directionOfSpinInView:view];
    if (direction == ZZSpinDirectionClockwise)
    {
        angleVelocity *= -1;
    }
    return angleVelocity;
}

@end