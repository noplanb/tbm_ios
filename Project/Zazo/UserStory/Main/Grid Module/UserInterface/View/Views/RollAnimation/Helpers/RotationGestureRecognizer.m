//
// Created by Maksim Bazarov on 13/07/15.
// Copyright (c) 2015 Maksim Bazarov. All rights reserved.
//

#import "RotationGestureRecognizer.h"

@interface RotationGestureRecognizer ()

@end

@implementation RotationGestureRecognizer {

}
- (CGFloat)startAngleInView:(UIView *)view {
    CGPoint translation = [self translationInView:view];
    CGPoint point = [self locationInView:view];
    CGPoint centerBefore = CGPointMake(point.x - translation.x, point.y - translation.y);
    CGFloat res = [Geometry angleFromPoint:centerBefore onFrame:view.frame];
    return res;
}

- (CGFloat)currentAngleInView:(UIView *)view {
    CGPoint point = [self locationInView:view];
    CGFloat res = [Geometry angleFromPoint:point onFrame:view.frame];
    return res;
}

- (SpinDirection)directionOfSpinInView:(UIView *)view {
    SpinDirection res;
    CGPoint velocity = [self velocityInView:view];
    CGPoint point = [self locationInView:view];
    CGFloat angle = [Geometry angleFromPoint:point onFrame:view.frame];

    res = [Geometry directionWithVelocity:&velocity fromAngle:angle];

    return res;
}

- (CGFloat)angleVelocityInView:(UIView *)view {
    CGPoint velocity = [self velocityInView:view];

    CGPoint point = [self locationInView:view];
    //radius from center view to touch
    CGFloat x = (fabs(point.x) - view.frame.size.width / 2);
    CGFloat y = (fabs(point.y) - view.frame.size.height / 2);
    CGFloat radius = sqrtf(x * x + y * y);

    CGFloat angleVelocity = (CGFloat) sqrtf(velocity.x * velocity.x + velocity.y * velocity.y) / radius;

    SpinDirection direction = [self directionOfSpinInView:view];
    if (direction == SpinClockwise) {
        angleVelocity *= -1;
    }

    return angleVelocity;
}

@end