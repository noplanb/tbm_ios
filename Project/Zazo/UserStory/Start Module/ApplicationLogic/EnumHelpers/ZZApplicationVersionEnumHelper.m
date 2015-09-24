//
//  ZZApplicationVersionEnumHelper.m
//  Zazo
//
//  Created by Oksana Kovalchuk on 9/24/15.
//  Copyright © 2015 No Plan B. All rights reserved.
//

#import "ZZApplicationVersionEnumHelper.h"

static NSString *versionString[] = {
    @"current",
    @"update_optional",
    @"update_schema_required",
    @"update_required",
};


NSString* ZZApplicationVersionStateStringFromEnumValue(ZZApplicationVersionState type)
{
    return versionString[type];
}

ZZApplicationVersionState ZZApplicationVersionStateEnumValueFromString(NSString* string)
{
    NSArray* array = [NSArray arrayWithObjects:versionString count:4];
    return [array indexOfObject:string];
}
