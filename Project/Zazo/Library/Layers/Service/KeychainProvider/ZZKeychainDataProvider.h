//
//  ZZKeychainDataProvider.h
//  Zazo
//
//  Created by ANODA on 8/11/15.
//  Copyright (c) 2015 ANODA. All rights reserved.
//

#import "ZZS3CredentialsDomainModel.h"

extern NSString * const ZZCredentialsTypeVideo;
extern NSString * const ZZCredentialsTypeAvatar;

@interface ZZKeychainDataProvider : NSObject

+ (void)updateWithCredentials:(ZZS3CredentialsDomainModel *)model;
+ (ZZS3CredentialsDomainModel *)loadCredentialsOfType:(NSString *)type;

@end
