//
//  ZZEnvelopStrategy.m
//  Zazo
//
//  Created by ANODA on 22/08/15.
//  Copyright (c) 2015 ANODA. All rights reserved.
//

#import "ZZEnvelopStrategy.h"

@implementation ZZEnvelopStrategy

- (void)fillArray
{
    self.frameArray = @[
                        [NSValue valueWithCGRect:CGRectMake(0, 0, kFrameWidth, kFrameHeight)],
                        [NSValue valueWithCGRect:CGRectMake((CGRectGetWidth([UIScreen mainScreen].bounds) - kFrameWidth), 0, kFrameWidth, kFrameHeight)],
                        [NSValue valueWithCGRect:CGRectMake(0, CGRectGetHeight([UIScreen mainScreen].bounds) - kFrameHeight, kFrameWidth, kFrameHeight)],
                        [NSValue valueWithCGRect:CGRectMake((CGRectGetWidth([UIScreen mainScreen].bounds) - kFrameWidth), CGRectGetHeight([UIScreen mainScreen].bounds) - kFrameHeight, kFrameWidth, kFrameHeight)],
                        ];
}

@end
