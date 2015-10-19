//
//  ZZRemoteStorageConstants.m
//  Zazo
//
//  Created by Oksana Kovalchuk on 10/20/15.
//  Copyright © 2015 No Plan B. All rights reserved.
//

#import "ZZRemoteStorageConstants.h"

const struct ZZRemoteStorageParameters ZZRemoteStorageParameters = {
    .key1 = @"key1",
    .key2 = @"key2",
    .value = @"value",
    .videoID = @"videoID",
    .status = @"status",
};

static NSString *remoteStorageVideoStatusesString[] = {
    @"none",
    @"downloaded",
    @"viewed"
};

NSString* ZZRemoteStorageVideoStatusStringFromEnumValue(ZZRemoteStorageVideoStatus type)
{
    return remoteStorageVideoStatusesString[type];
}

ZZRemoteStorageVideoStatus ZZRemoteStorageVideoStatusEnumValueFromSrting(NSString* string)
{
    NSArray* array = [NSArray arrayWithObjects:remoteStorageVideoStatusesString count:3];
    NSInteger index = [array indexOfObject:string];
    if (index == NSNotFound)
    {
        return ZZRemoteStorageVideoStatusNone;
    }
    return index;
}
