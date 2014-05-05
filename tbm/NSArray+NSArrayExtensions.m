//
//  NSArray+NSArrayExtensions.m
//  tbm
//
//  Created by Sani Elfishawy on 5/5/14.
//  Copyright (c) 2014 No Plan B. All rights reserved.
//

#import "NSArray+NSArrayExtensions.h"

@implementation NSArray (NSArrayExtensions)

- (NSArray *)mapObjectsUsingBlock:(id (^)(id obj, NSUInteger idx))block {
    NSMutableArray *result = [NSMutableArray arrayWithCapacity:[self count]];
    [self enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [result addObject:block(obj, idx)];
    }];
    return result;
}

@end
