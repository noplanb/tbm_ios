//
//  ZZStrategyNavigationLeftRight.m
//  Zazo
//
//  Created by ANODA on 21/08/15.
//  Copyright (c) 2015 ANODA. All rights reserved.
//

#import "ZZStrategyNavigationLeftRight.h"

@implementation ZZStrategyNavigationLeftRight

- (void)fillArray
{
    self.frameArray  = @[
                        [NSValue valueWithCGRect:CGRectMake(0, 0, kFrameWidth, kFrameHeight)],
                        [NSValue valueWithCGRect:CGRectMake((CGRectGetWidth([UIScreen mainScreen].bounds) - kFrameWidth), 0, kFrameWidth, kFrameHeight)]
                        ];
}

@end
