//
//  ZZKeychainDataProvider.m
//  Zazo
//
//  Created by ANODA on 8/11/15.
//  Copyright (c) 2015 ANODA. All rights reserved.
//

#import "ZZKeychainDataProvider.h"
#import "VALValet.h"
#import "ZZS3CredentialsDomainModel.h"

@implementation ZZKeychainDataProvider

+ (void)updateWithCredentials:(ZZS3CredentialsDomainModel*)model
{
    if ([model isValid])
    {
        VALValet *valet = [[VALValet alloc] initWithIdentifier:[self _bundleID] accessibility:VALAccessibilityWhenUnlocked];
        
        [valet setString:model.region forKey:ZZS3CredentialsDomainModelAttributes.region];
        [valet setString:model.bucket forKey:ZZS3CredentialsDomainModelAttributes.bucket];
        [valet setString:model.accessKey forKey:ZZS3CredentialsDomainModelAttributes.accessKey];
        [valet setString:model.secretKey forKey:ZZS3CredentialsDomainModelAttributes.secretKey];
    }
}

+ (ZZS3CredentialsDomainModel*)loadCredentials
{
    ZZS3CredentialsDomainModel* model = [ZZS3CredentialsDomainModel new];
    VALValet *valet = [[VALValet alloc] initWithIdentifier:[self _bundleID] accessibility:VALAccessibilityWhenUnlocked];
    
    model.region = [valet stringForKey:ZZS3CredentialsDomainModelAttributes.region];
    model.bucket = [valet stringForKey:ZZS3CredentialsDomainModelAttributes.bucket];
    model.accessKey = [valet stringForKey:ZZS3CredentialsDomainModelAttributes.accessKey];
    model.secretKey = [valet stringForKey:ZZS3CredentialsDomainModelAttributes.secretKey];
    
    return model;
}


#pragma mark - Private

+ (NSString*)_bundleID
{
    return [[NSBundle mainBundle] bundleIdentifier];
}

@end
