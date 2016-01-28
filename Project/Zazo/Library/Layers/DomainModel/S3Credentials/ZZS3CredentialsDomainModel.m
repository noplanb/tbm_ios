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

@dynamic regionType;

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


- (AWSRegionType)regionType
{

    if ([self.region isEqualToString:@"eu-west-1"]) {
        return AWSRegionEUWest1;
    }
    if ([self.region isEqualToString:@"us-west-1"]) {
        return AWSRegionUSWest1;
    }
    if ([self.region isEqualToString:@"us-west-2"]) {
        return AWSRegionUSWest2;
    }
    if ([self.region isEqualToString:@"ap-southeast-1"]) {
        return AWSRegionAPSoutheast1;
    }
    if ([self.region isEqualToString:@"ap-southeast-2"]) {
        return AWSRegionAPSoutheast2;
    }
    if ([self.region isEqualToString:@"ap-northeast-1"]) {
        return AWSRegionAPNortheast1;
    }
    if ([self.region isEqualToString:@"sa-east-1"]) {
        return AWSRegionSAEast1;
    }

    if ([self.region isEqualToString:@"cn-north-1"]) {
        return AWSRegionCNNorth1;
    }
    if ([self.region isEqualToString:@"eu-central-1"]) {
        return AWSRegionEUCentral1;
    }
    if ([self.region isEqualToString:@"us-gov-west-1"]) {
        return AWSRegionUSGovWest1;
    }
    
    return AWSRegionUnknown;
}


@end
