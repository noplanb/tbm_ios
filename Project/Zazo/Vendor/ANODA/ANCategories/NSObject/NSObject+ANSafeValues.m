//
//  NSObject+SMSafeValues.m
//  Zazo
//
//  Created by ANODA on 7/12/15.
//  Copyright (c) 2015 ANODA. All rights reserved.
//

#import "NSObject+ANSafeValues.h"

@implementation NSObject (ANSafeValues)

+ (NSString *)an_safeString:(NSString *)value
{
    value = value ?: @"";
    if ([value isKindOfClass:[NSNull class]])
    {
        return @"";
    }
    if ([value isKindOfClass:[NSString class]])
    {
        return value;
    }
    return [NSString stringWithFormat:@"%@", value];
}

+ (NSDictionary *)an_safeDictionary:(NSDictionary *)dict
{
    dict = dict ?: @{};
    return dict;
}

@end
