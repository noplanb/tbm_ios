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
#import "ZZCredentialsKeyData.h"

NSString * const ZZCredentialsTypeVideo = @"s3_credentials/videos";
NSString * const ZZCredentialsTypeAvatar = @"s3_credentials/avatars";

@implementation ZZKeychainDataProvider

+ (void)updateWithCredentials:(ZZS3CredentialsDomainModel *)model
{
    ZZCredentialsKeyData *keyData = [ZZCredentialsKeyData keyDataForType:model.type];
    
    if ([model isValid])
    {
        [NSObject an_updateObject:model.region forKey:keyData.regionKey];
        [NSObject an_updateObject:model.bucket forKey:keyData.bucketKey];
        [NSObject an_updateObject:model.accessKey forKey:keyData.accessKey];
        [NSObject an_updateObject:model.secretKey forKey:keyData.secretKey];
    }
}

+ (ZZS3CredentialsDomainModel *)loadCredentialsOfType:(NSString *)type
{
    ZZCredentialsKeyData *keyData = [ZZCredentialsKeyData keyDataForType:type];
    ZZS3CredentialsDomainModel *model = [ZZS3CredentialsDomainModel new];

    model.type = type;
    model.region = [NSObject an_stringForKey:keyData.regionKey];
    model.bucket = [NSObject an_stringForKey:keyData.bucketKey];
    model.accessKey = [NSObject an_stringForKey:keyData.accessKey];
    model.secretKey = [NSObject an_stringForKey:keyData.secretKey];

    return model;
}

@end
