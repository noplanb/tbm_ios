//
//  ZZCredentialsProvider.m
//  Zazo
//
//  Created by Rinat on 22/09/16.
//  Copyright © 2016 No Plan B. All rights reserved.
//

#import "ZZCredentialsProvider.h"

@implementation ZZCredentialsProvider

- (instancetype)sharedProvider
{
    static id sharedProvider;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedProvider = [ZZCredentialsProvider new];
    });
    
    return sharedProvider;
}

- (ZZS3CredentialsDomainModel *)credentialsOfType:(NSString *)type
{
    return [ZZKeychainDataProvider loadCredentialsOfType:type];
}

- (void)updateCredentialsOfType:(NSString *)type completion:(ANCodeBlock)completion
{
    
}

@end
