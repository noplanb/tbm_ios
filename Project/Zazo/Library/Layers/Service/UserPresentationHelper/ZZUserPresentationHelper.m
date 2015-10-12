//
//  ZZUserPresentationHelper.m
//  Zazo
//
//  Created by Oksana Kovalchuk on 9/22/15.
//  Copyright © 2015 No Plan B. All rights reserved.
//

#import "ZZUserPresentationHelper.h"

@implementation ZZUserPresentationHelper

+ (NSString*)fullNameWithFirstName:(NSString*)firstName lastName:(NSString*)lastName
{
    NSString* username = [NSObject an_safeString:firstName];
    if (username.length && lastName.length)
    {
        username = [username stringByAppendingString:@" "];
    }
    
    BOOL shouldUseSpace = (!ANIsEmpty(firstName) && !ANIsEmpty(lastName));
    
    return [NSString stringWithFormat:@"%@%@%@", [NSObject an_safeString:firstName], shouldUseSpace ? @" " : @"", [NSObject an_safeString:lastName]];
}

@end
