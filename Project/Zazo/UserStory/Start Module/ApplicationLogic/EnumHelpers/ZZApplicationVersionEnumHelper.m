//
//  ZZApplicationVersionEnumHelper.m
//  Zazo
//
//  Created by Oksana Kovalchuk on 9/24/15.
//  Copyright © 2015 No Plan B. All rights reserved.
//

#import "ZZApplicationVersionEnumHelper.h"

static NSString *versionString[] = {
        @"none",
        @"current",
        @"update_optional",
        @"update_schema_required",
        @"update_required",
};


NSString *ZZApplicationVersionStateStringFromEnumValue(ZZApplicationVersionState type)
{
    int count = sizeof(versionString) / sizeof(versionString[0]);
    return (type < count) ? versionString[type] : nil;
}

ZZApplicationVersionState ZZApplicationVersionStateEnumValueFromString(NSString *string)
{
    int count = sizeof(versionString) / sizeof(versionString[0]);
    NSArray *array = [NSArray arrayWithObjects:versionString count:count];
    NSInteger index = [array indexOfObject:[NSObject an_safeString:string]];
    return (index == NSNotFound) ? 0 : index;
}
