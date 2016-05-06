//
//  NSError+Extensions.m
//  Zazo
//
//  Created by Sani Elfishawy on 4/23/15.
//  Copyright (c) 2015 No Plan B. All rights reserved.
//

#import "NSError+ZZAdditions.h"

@implementation NSError (Extensions)

+ (NSError *)errorWithError:(NSError *)error reason:(NSString *)reason
{
    NSMutableDictionary *userInfo = [NSMutableDictionary new];
    [userInfo addEntriesFromDictionary:error.userInfo ?: @{}];
    userInfo[NSLocalizedFailureReasonErrorKey] = [NSObject an_safeString:reason];

    return [[NSError alloc] initWithDomain:error.domain
                                      code:error.code
                                  userInfo:userInfo];
}

@end
