//
//  ZZContactDomainModel.m
//  Zazo
//
//  Created by ANODA on 8/11/15.
//  Copyright (c) 2015 ANODA. All rights reserved.
//

#import "ZZContactDomainModel.h"
#import "ZZUserPresentationHelper.h"

@implementation ZZContactDomainModel

- (NSString *)fullName
{
    return [ZZUserPresentationHelper fullNameWithFirstName:self.firstName lastName:self.lastName];
}

- (NSString*)photoURLString
{
    return nil;
}

- (BOOL)hasApp
{
    return NO;
}

- (ZZMenuContactType)contactType
{
    return ZZMenuContactTypeAddressbook;
}

- (void)setPhones:(NSArray*)phones
{
    _phones = phones;
    if (_phones.count == 1)
    {
        self.primaryPhone = [_phones firstObject];
    }
}

@end
