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

const struct ZZUserDomainModelAttributes ZZUserDomainModelAttributes = {
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
                                               ZZBaseDomainModelAttributes.idTbm        : @"id",
                                               ZZUserDomainModelAttributes.auth         : @"auth",
                                               ZZUserDomainModelAttributes.mkey         : @"mkey",
                                               ZZUserDomainModelAttributes.mobileNumber : @"mobile_number"}];
    }];
}

- (NSString*)photoURLString
{
    return nil; // TODO:
}

- (UIImage*)photoImage
{
    return nil;
}

//TODO: copy-paste from friend class
- (NSString*)fullName
{
    NSString* username = self.firstName ? self.firstName : @"";
    if (username.length)
    {
        username = [username stringByAppendingString:@" "];
    }
    return [username stringByAppendingString:self.lastName ? self.lastName : @""];
}


@end
