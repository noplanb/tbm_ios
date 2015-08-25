//
//  NSString+ANAdditions.m
//  Zazo
//
//  Created by ANODA on 8/11/15.
//  Copyright (c) 2015 ANODA. All rights reserved.
//

#import "NSString+ZZAdditions.h"
#import "NSObject+ANSafeValues.h"

@implementation NSString (ZZAdditions)

+ (NSString *)an_concatenateString:(NSString*)firstString withString:(NSString*)endString delimenter:(NSString*)string
{
    NSString* result = [NSObject an_safeString:firstString];
    if (result.length)
    {
        result = [result stringByAppendingString:[NSObject an_safeString:string]];
    }
    return [result stringByAppendingString:[NSObject an_safeString:endString]];
}

@end
