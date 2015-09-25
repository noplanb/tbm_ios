//
//  NSError+Extensions.m
//  Zazo
//
//  Created by Sani Elfishawy on 4/23/15.
//  Copyright (c) 2015 No Plan B. All rights reserved.
//

#import "NSError+Extensions.h"

@implementation NSError (Extensions)

+ (NSError *)errorWithError:(NSError *)error reason:(NSString *)reason
{
    NSMutableDictionary *userInfo = [[NSMutableDictionary alloc] init];

    [userInfo addEntriesFromDictionary:error.userInfo];
    
    userInfo[NSLocalizedFailureReasonErrorKey] = reason;
    
    return [[NSError alloc] initWithDomain:error.domain
                                      code:error.code
                                  userInfo:userInfo];
}

@end
