//
//  ANMemoryStorage+UpdateWithoutAnimations.m
//
//  Created by Oksana Kovalchuk on 29/10/14.
//  Copyright (c) 2014 ANODA. All rights reserved.
//

#import "ANMemoryStorage+UpdateWithoutAnimations.h"

@implementation ANMemoryStorage (UpdateWithoutAnimations)

- (void)updateWithoutAnimations:(void (^)(void))block
{
    id delegate = self.updatingInterface;
    self.updatingInterface = nil;

    if (block)
    {
        block();
    }
    self.updatingInterface = delegate;
}

@end
