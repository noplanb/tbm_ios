//
//  ZZRollbarConstants.m
//  Zazo
//
//  Created by Oksana Kovalchuk on 10/19/15.
//  Copyright © 2015 No Plan B. All rights reserved.
//

#import "ZZRollbarConstants.h"

static NSString *logLevelString[] = {
        @"debug",
        @"info",
        @"warning",
        @"error",
        @"critical"
};

NSString *ZZDispatchLevelStringFromEnumValue(ZZDispatchLevel type)
{
    return logLevelString[type];
}

ZZDispatchLevel ZZDispatchLevelEnumValueFromSrting(NSString *string)
{
    NSArray *array = [NSArray arrayWithObjects:logLevelString count:5];
    return [array indexOfObject:[NSObject an_safeString:string]];
}


#pragma mark - Server state

static NSString *serverTypeString[] = {
        @"development",
        @"production",
        @"staging"
};

NSString *ZZDispatchServerStateStringFromEnumValue(ZZConfigServerState type)
{
    return logLevelString[type];
}

ZZConfigServerState ZZDispatchServerStateEnumValueFromSrting(NSString *string)
{
    NSArray *array = [NSArray arrayWithObjects:serverTypeString count:3];
    return [array indexOfObject:[NSObject an_safeString:string]];
}

