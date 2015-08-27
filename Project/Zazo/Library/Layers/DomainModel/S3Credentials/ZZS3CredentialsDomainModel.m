//
//  ZZS3CredentialsDomainModel.m
//  Zazo
//
//  Created by ANODA on 8/11/15.
//  Copyright (c) 2015 ANODA. All rights reserved.
//

#import "ZZS3CredentialsDomainModel.h"
#import "FEMObjectMapping.h"

const struct ZZS3CredentialsDomainModelAttributes ZZS3CredentialsDomainModelAttributes = {
    .region = @"region",
    .bucket = @"bucket",
    .accessKey = @"accessKey",
    .secretKey = @"secretKey",
};

@implementation ZZS3CredentialsDomainModel

+ (FEMObjectMapping*)mapping
{
    return [FEMObjectMapping mappingForClass:[self class] configuration:^(FEMObjectMapping *mapping) {
       
        [mapping addAttributesFromDictionary:@{ZZS3CredentialsDomainModelAttributes.region      : @"region",
                                               ZZS3CredentialsDomainModelAttributes.bucket      : @"bucket",
                                               ZZS3CredentialsDomainModelAttributes.accessKey   : @"access_key",
                                               ZZS3CredentialsDomainModelAttributes.secretKey   : @"secret_key"}];
    }];
}

- (BOOL)isValid
{
    return (!ANIsEmpty(self.region) &&
            (!ANIsEmpty(self.bucket)) &&
            (!ANIsEmpty(self.accessKey)) &&
            (!ANIsEmpty(self.secretKey)));
}

@end
