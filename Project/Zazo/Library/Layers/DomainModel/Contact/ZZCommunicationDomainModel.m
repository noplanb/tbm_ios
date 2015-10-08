//
//  ZZCommunicationDomainModel.m
//  Zazo
//
//  Created by ANODA on 9/23/15.
//  Copyright © 2015 No Plan B. All rights reserved.
//

#import "ZZCommunicationDomainModel.h"

@implementation ZZCommunicationDomainModel

#pragma mark - Override

- (BOOL)isEqualToCommunicationDomainModel:(ZZCommunicationDomainModel*)model
{
    if (!model)
    {
        return NO;
    }
    
    BOOL haveEqualItems = (ANIsEmpty(self.contact) && ANIsEmpty(model.contact)) ||
    [self.contact isEqualToString:model.contact];
    return haveEqualItems;
}


#pragma mark - NSObject

- (BOOL)isEqual:(id)object
{
    if (self == object)
    {
        return YES;
    }
    if (![object isKindOfClass:[ZZCommunicationDomainModel class]])
    {
        return NO;
    }
    return [self isEqualToCommunicationDomainModel:object];
}

- (NSUInteger)hash
{
    return [self.contact hash];
}

@end
