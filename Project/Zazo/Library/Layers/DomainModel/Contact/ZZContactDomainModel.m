//
//  ZZContactDomainModel.m
//  Zazo
//
//  Created by ANODA on 8/11/15.
//  Copyright (c) 2015 ANODA. All rights reserved.
//

#import "ZZContactDomainModel.h"
#import "ZZUserPresentationHelper.h"

@interface ZZContactDomainModel ()

@property (nonatomic, copy) NSString *fullName;

@end

@implementation ZZContactDomainModel

+ (instancetype)modelWithFirstName:(NSString *)firstName lastName:(NSString *)lastName
{
    ZZContactDomainModel *model = [self new];
    model.firstName = firstName;
    model.lastName = lastName;
    model.fullName = [ZZUserPresentationHelper fullNameWithFirstName:model.firstName lastName:model.lastName];

    if (ANIsEmpty(firstName))
    {
        firstName = @"…";
    }

    model.category = [firstName substringWithRange:NSMakeRange(0, 1)];

    return model;
}

- (BOOL)hasApp
{
    return NO;
}

- (ZZMenuContactType)contactType
{
    return ZZMenuContactTypeAddressbook;
}

- (void)setPhones:(NSArray *)phones
{
    _phones = phones;
}

- (ZZCommunicationDomainModel *)primaryPhone
{
    if (!_primaryPhone)
    {
        if (_phones.count == 1)
        {
            _primaryPhone = [_phones firstObject];
        }
    }
    return _primaryPhone;
}

#pragma mark - Override

- (BOOL)isEqualToContactDomainModel:(ZZContactDomainModel *)model
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

- (NSString *)description
{
    NSMutableString *description = [NSMutableString string];
    [description appendFormat:@"self.fullName=%@", self.fullName];
    [description appendFormat:@", self.phones=%@", self.phones];

    return [NSString stringWithFormat:@"<%@: %@>", NSStringFromClass([self class]), description];

}


@end
