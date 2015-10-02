//
//  ZZUserDomainModel.m
//  Zazo
//
//  Created by ANODA on 8/10/15.
//  Copyright (c) 2015 ANODA. All rights reserved.
//

#import "ZZUserDomainModel.h"
#import "FEMObjectMapping.h"
#import "NBPhoneNumberUtil.h"
#import "ZZUserPresentationHelper.h"

const struct ZZUserDomainModelAttributes ZZUserDomainModelAttributes = {
    .idTbm = @"idTbm",
    .firstName = @"firstName",
    .lastName = @"lastName",
    .auth = @"auth",
    .mkey = @"mkey",
    .mobileNumber = @"mobileNumber",
    .isRegistered = @"isRegistered",
};

@implementation ZZUserDomainModel

+ (FEMObjectMapping*)mapping
{
    return [FEMObjectMapping mappingForClass:[self class] configuration:^(FEMObjectMapping *mapping) {
        [mapping addAttributesFromDictionary:@{ZZUserDomainModelAttributes.firstName    : @"first_name",
                                               ZZUserDomainModelAttributes.lastName     : @"last_name",
                                               ZZUserDomainModelAttributes.idTbm        : @"id",
                                               ZZUserDomainModelAttributes.auth         : @"auth",
                                               ZZUserDomainModelAttributes.mkey         : @"mkey",
                                               ZZUserDomainModelAttributes.mobileNumber : @"mobile_number"}];
    }];
}

- (BOOL)hasApp
{
    return YES;
}

- (ZZMenuContactType)contactType
{
    return -1;
}

- (NSString*)fullName
{
    return [ZZUserPresentationHelper fullNameWithFirstName:self.firstName lastName:self.lastName];
}

@end
