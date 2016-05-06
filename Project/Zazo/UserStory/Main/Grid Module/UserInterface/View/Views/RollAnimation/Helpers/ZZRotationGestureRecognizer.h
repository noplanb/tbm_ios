//  Zazo
//
//  Created by Oksana Kovalchuk on 1/11/15.
//  Copyright (c) 2015 ANODA. All rights reserved.
//


#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "ZZGeometryHelper.h"
#import <UIKit/UIGestureRecognizerSubclass.h>

@interface ZZRotationGestureRecognizer : UIPanGestureRecognizer

/**
* get angle from pan gesture started
*/
- (CGFloat)startAngleInView:(UIView *)view;

/**
* get angle from current state of pan gesture
*/
- (CGFloat)currentAngleInView:(UIView *)view;

/**
* get direction of spin
*/
- (ZZSpinDirection)directionOfSpinInView:(UIView *)view;

/**
* get angle velocity from linear velocity on pan
*/
- (CGFloat)angleVelocityInView:(UIView *)view;

- (void)stateChanged;

@end