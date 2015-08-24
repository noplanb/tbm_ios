//
//  ZZLockControllerWithTouchDelay.m
//  Zazo
//
//  Created by ANODA on 22/08/15.
//  Copyright (c) 2015 ANODA. All rights reserved.
//

#import "ZZTouchControllerWithTouchDelay.h"

@implementation ZZTouchControllerWithTouchDelay

- (instancetype)initWithDelay:(CGFloat)delay
                 withStrategy:(id<ZZSecretScreenStrategy>)strategy
          withComplitionBlock:(void (^)())completionBlock
{
    self = [super init];
    if (self)
    {
        self.completionBlock = completionBlock;
        self.strategy = strategy;
        self.checkFrameModelsArray = [NSMutableArray arrayWithArray:[self.strategy intersectionFrames]];
        [self.checkFrameModelsArray removeObjectAtIndex:0];
        self.resultArray = [NSMutableArray array];
        self.touchDelay = delay;
    }
    
    return self;
}


- (void)observeTouch:(UITouch*)touch withEvent:(id)event
{
    if (!self.isStrartObserving)
    {
        [self startObservingIfNeededWithTouch:touch withEvent:event];
    }
    else
    {
        if (!self.isAbbleToMoving)
        {
            [self observeEndTouchBeforeBeginObservingWithTouch:touch withEvent:event];
        }
        else
        {
            [self objserveMovingWithTouch:touch];
        }
    }
}

@end
