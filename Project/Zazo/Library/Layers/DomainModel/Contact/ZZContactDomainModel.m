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

#pragma mark - Override

- (BOOL)isEqualToContactDomainModel:(ZZContactDomainModel*)model
{
    if (!model)
    {
        return NO;
    }
    
    BOOL haveEqualItems = (ANIsEmpty(self.fullName) && ANIsEmpty(model.fullName)) ||
    [self.fullName isEqualToString:model.fullName];
    return haveEqualItems;
}


#pragma mark - NSObject

- (BOOL)isEqual:(id)object
{
    if (self == object)
    {
        return YES;
    }
    if (![object isKindOfClass:[ZZContactDomainModel class]])
    {
        return NO;
    }
    return [self isEqualToContactDomainModel:object];
}

- (NSUInteger)hash
{
    return [self.fullName hash];
}


@end
