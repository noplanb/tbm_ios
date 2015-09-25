//
//  ZZEditFriendEnumsAdditions.m
//  Zazo
//
//  Created by ANODA on 8/26/15.
//  Copyright (c) 2015 ANODA. All rights reserved.
//

#import "ZZEditFriendEnumsAdditions.h"

@implementation ZZEditFriendEnumsAdditions

static NSString* contactStatusString[] = {
    @"voided",
    @"established",
    @"hidden_by_creator",
    @"hidden_by_target",
    @"hidden_by_both"
};

NSString* ZZConnectionStatusTypeStringFromValue(ZZConnectionStatusType type)
{
    return contactStatusString[type];
}

ZZConnectionStatusType ZZConnectionStatusTypeValueFromSrting(NSString* string)
{
    NSArray* array = [NSArray arrayWithObjects:contactStatusString count:5];
    NSInteger index = [array indexOfObject:string];
    if (index == NSNotFound)
    {
        index = 0;
    }
    return index;
}

@end
