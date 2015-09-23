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
    if (username.length)
    {
        username = [username stringByAppendingString:@" "];
    }
    return [username stringByAppendingString:[NSObject an_safeString:lastName]];
}

@end
