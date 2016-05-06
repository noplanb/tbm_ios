//
//  ZZKeychainDataProvider.m
//  Zazo
//
//  Created by ANODA on 8/11/15.
//  Copyright (c) 2015 ANODA. All rights reserved.
//

#import "ZZKeychainDataProvider.h"
#import "ZZS3CredentialsDomainModel.h"
#import "NSObject+ANUserDefaults.h"

@implementation ZZKeychainDataProvider

+ (void)updateWithCredentials:(ZZS3CredentialsDomainModel *)model
{
    if ([model isValid])
    {
        [NSObject an_updateObject:model.region forKey:ZZS3CredentialsDomainModelAttributes.region];
        [NSObject an_updateObject:model.bucket forKey:ZZS3CredentialsDomainModelAttributes.bucket];
        [NSObject an_updateObject:model.accessKey forKey:ZZS3CredentialsDomainModelAttributes.accessKey];
        [NSObject an_updateObject:model.secretKey forKey:ZZS3CredentialsDomainModelAttributes.secretKey];
    }
}

+ (ZZS3CredentialsDomainModel *)loadCredentials
{
    ZZS3CredentialsDomainModel *model = [ZZS3CredentialsDomainModel new];

    model.region = [NSObject an_stringForKey:ZZS3CredentialsDomainModelAttributes.region];
    model.bucket = [NSObject an_stringForKey:ZZS3CredentialsDomainModelAttributes.bucket];
    model.accessKey = [NSObject an_stringForKey:ZZS3CredentialsDomainModelAttributes.accessKey];
    model.secretKey = [NSObject an_stringForKey:ZZS3CredentialsDomainModelAttributes.secretKey];

    return model;
}

@end
