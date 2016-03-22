//
// Created by Maksim Bazarov on 26/08/15.
// Copyright (c) 2015 No Plan B. All rights reserved.
//

#import "NSArray+ZZAdditions.h"

@implementation NSArray (ZZAdditions)

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

- (NSDictionary *)zz_groupByKeyPath:(NSString *)keyPath
{
    NSArray *array = [self copy];
    keyPath = [keyPath copy];
    
    NSMutableDictionary *result = [NSMutableDictionary new];
    
    [array enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        
        id value = [obj valueForKeyPath:keyPath];
        
        if (!value)
        {
            return ;
        }
        
        if (!result[value])
        {
            [result setObject:[NSMutableArray new] forKey:value];
        }
        
        NSMutableArray *keyItems = result[value];
        [keyItems addObject:obj];
    }];
    
    return [result copy];
}

@end