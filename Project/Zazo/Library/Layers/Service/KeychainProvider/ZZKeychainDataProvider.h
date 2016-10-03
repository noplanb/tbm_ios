//
//  ZZKeychainDataProvider.h
//  Zazo
//
//  Created by ANODA on 8/11/15.
//  Copyright (c) 2015 ANODA. All rights reserved.
//

#import "ZZS3CredentialsDomainModel.h"

extern  NSString * _Nonnull const ZZCredentialsTypeVideo;
extern  NSString * _Nonnull const ZZCredentialsTypeAvatar;

@interface ZZKeychainDataProvider : NSObject

+ (void)updateWithCredentials:(nonnull ZZS3CredentialsDomainModel *)model;
+ (nullable ZZS3CredentialsDomainModel *)loadCredentialsOfType:(nonnull NSString *)type;

@end
