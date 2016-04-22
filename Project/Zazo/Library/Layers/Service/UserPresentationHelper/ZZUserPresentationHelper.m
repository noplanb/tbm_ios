//
//  ZZUserPresentationHelper.m
//  Zazo
//
//  Created by Oksana Kovalchuk on 9/22/15.
//  Copyright © 2015 No Plan B. All rights reserved.
//

#import "ZZUserPresentationHelper.h"

@implementation ZZUserPresentationHelper

+ (NSString*)fullNameWithFirstName:(NSString *)firstName lastName:(NSString *)lastName
{
    BOOL shouldUseSpace = (!ANIsEmpty(firstName) && !ANIsEmpty(lastName));
    
    return [NSString stringWithFormat:@"%@%@%@", [NSObject an_safeString:firstName], shouldUseSpace ? @" " : @"", [NSObject an_safeString:lastName]];
}

+ (NSString *)abbreviationWithFullname:(NSString *)name
{
    name = [name stringByTrimmingCharactersInSet:[NSCharacterSet letterCharacterSet].invertedSet];
    
    if (ANIsEmpty(name))
    {
        return nil;
    }
    
    name = [name uppercaseString];
    
    NSArray <NSString *> *items = [name componentsSeparatedByString:@" "];
    
    if (items.count > 1)
    {
        items = [items subarrayWithRange:NSMakeRange(0, 2)];
    }
    
    NSMutableString *result = [NSMutableString new];
    
    [items enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        
        if (ANIsEmpty(obj))
        {
            return;
        }
        
        [result appendString:[obj substringToIndex:1]];
    }];
    
    return result;
}

@end
