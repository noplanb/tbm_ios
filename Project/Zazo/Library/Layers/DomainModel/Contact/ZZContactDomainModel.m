//
//  ZZContactDomainModel.m
//  Zazo
//
//  Created by ANODA on 8/11/15.
//  Copyright (c) 2015 ANODA. All rights reserved.
//

#import "ZZContactDomainModel.h"

@implementation ZZContactDomainModel

- (NSString *)fullName
{
    NSString* username = self.firstName ? self.firstName : @"";
    if (username.length)
    {
        username = [username stringByAppendingString:@" "];
    }
    return [username stringByAppendingString:self.lastName ? self.lastName : @""];
}

- (NSString*)photoURLString
{
    return nil;
}

- (BOOL)hasApp
{
    return NO;
}

@end
