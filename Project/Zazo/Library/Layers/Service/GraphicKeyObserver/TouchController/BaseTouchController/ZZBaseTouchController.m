//
//  ZZBaseLockController.m
//  Zazo
//
//  Created by ANODA on 22/08/15.
//  Copyright (c) 2015 ANODA. All rights reserved.
//

#import "ZZBaseTouchController.h"
#import "ZZStrategyNavigationLeftRight.h"
#import "ZZEnvelopStrategy.h"


@implementation ZZBaseTouchController

- (void)observeTouch:(UITouch *)touch withEvent:(id)event
{

}

- (void)startObservingIfNeededWithTouch:(UITouch*)touch withEvent:(UIEvent*)event
{
    
    UIWindow* window = [UIApplication sharedApplication].keyWindow;
    UIView* touchView = window.rootViewController.view;
    CGPoint location = [touch locationInView:touchView];
    
    NSArray* frames = [self.strategy intersectionFrames];
    NSValue* startFrameValue = [frames firstObject];
    CGRect startRect = [startFrameValue CGRectValue];
    if (CGRectContainsPoint(startRect, location))
    {
        if (touch.phase == UITouchPhaseBegan)
        {
            self.startTimeStamp = event.timestamp;
            self.startLocation = location;
            self.isStartObserving = YES;
        }
        if (touch.phase == UITouchPhaseEnded)
        {
            [self resetObserving];
        }
    }
}

- (void)observeEndTouchBeforeBeginObservingWithTouch:(UITouch*)touch withEvent:(UIEvent*)event
{
    UIWindow* window = [UIApplication sharedApplication].keyWindow;
    UIView* touchView = window.rootViewController.view;
    CGPoint location = [touch locationInView:touchView];
    
    NSArray* frames = [self.strategy intersectionFrames];
    NSValue* startFrameValue = [frames firstObject];
    CGRect startRect = [startFrameValue CGRectValue];
    if (CGRectContainsPoint(startRect, location))
    {
        if (touch.phase == UITouchPhaseMoved)
        {
            CGFloat diff = event.timestamp - self.startTimeStamp;
            if (diff >= self.touchDelay)
            {
                self.isAbleToMoving = YES;
                [self.strategy intersectRectWithIndex:0];
            }
            
        }
        if (touch.phase == UITouchPhaseEnded)
        {
            [self resetObserving];
        }
    }
}

- (void)observeMovingWithTouch:(UITouch *)touch
{
    UIWindow* window = [UIApplication sharedApplication].keyWindow;
    UIView* touchView = window.rootViewController.view;
    CGPoint location = [touch locationInView:touchView];
    
    if (touch.phase == UITouchPhaseEnded)
    {
        if ([self.strategy isLockedSuccess])
        {
            NSArray* frames = [self.strategy intersectionFrames];
            NSValue* startFrameValue = [frames firstObject];
            CGRect startRect = [startFrameValue CGRectValue];
            if (CGRectContainsPoint(startRect, location))
            {
                
                if (self.completionBlock)
                {
                    self.completionBlock();
                }
                [self resetObserving];
            }
            else
            {
                [self resetObserving];
            }
        }
        else
        {
            [self resetObserving];
        }
        
    }
    
    [[self.strategy intersectionFrames] enumerateObjectsUsingBlock:^(NSValue *value, NSUInteger idx, BOOL *stop) {
        CGRect rect = [value CGRectValue];
        if (CGRectContainsPoint(rect, location))
        {
            [self.strategy intersectRectWithIndex:idx];
        }
    }];
}

- (void)resetObserving
{
    self.isStartObserving = NO;
    self.isAbleToMoving = NO;
    [self.strategy resetValidatoinArray];
}


@end
