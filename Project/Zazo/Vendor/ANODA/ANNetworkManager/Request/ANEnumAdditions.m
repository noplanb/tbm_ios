//
//  ANEnumAdditions.m
//
//  Created by ANODA on 21/11/14.
//
//

#import "ANEnumAdditions.h"

static NSString *httpMethodTypeString[] = {
    @"none",
    @"GET",
    @"POST",
    @"DELETE"
};

NSString* ANHttpMethodTypeStringFromEnumValue(ANHttpMethodType type)
{
    int count = sizeof(httpMethodTypeString) / sizeof(httpMethodTypeString[0]);
    return (type < count) ? httpMethodTypeString[type] : nil;
}

ANHttpMethodType ANHttpMethodTypeEnumValueFromString(NSString* string)
{
    int count = sizeof(httpMethodTypeString) / sizeof(httpMethodTypeString[0]);
    NSArray* array = [NSArray arrayWithObjects:httpMethodTypeString count:count];
    NSInteger index = [array indexOfObject:[NSObject an_safeString:string]];
    return (index == NSNotFound) ? 0 : index;
}