//
//  ANEnumAdditions.m
//
//  Created by ANODA on 21/11/14.
//
//

#import "ANEnumAdditions.h"

static NSString *httpMethodTypeString[] = {
    @"GET",
    @"POST",
    @"DELETE"
};

NSString* ANHttpMethodTypeStringFromEnumValue(ANHttpMethodType type)
{
    return httpMethodTypeString[type];
}

ANHttpMethodType ANHttpMethodTypeEnumValueFromSrting(NSString* string)
{
    NSArray* array = [NSArray arrayWithObjects:httpMethodTypeString count:3];
    return [array indexOfObject:string];
}