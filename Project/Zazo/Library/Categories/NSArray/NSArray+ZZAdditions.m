//
// Created by Maksim Bazarov on 26/08/15.
// Copyright (c) 2015 No Plan B. All rights reserved.
//

#import "NSArray+ZZAdditions.h"

@implementation NSArray (TBMArrayHelpers)

- (id)zz_randomObject
{
    NSUInteger myCount = [self count];
    if (myCount)
    {
        return [self objectAtIndex:arc4random_uniform((u_int32_t)myCount)];
    }
    else
    {
        return nil;
    }
}

@end