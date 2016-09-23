//
//  ZZCredentialsKeyData.m
//  Zazo
//
//  Created by Rinat on 22/09/16.
//  Copyright © 2016 No Plan B. All rights reserved.
//

#import "ZZCredentialsKeyData.h"

@implementation ZZCredentialsKeyData

+ (instancetype)keyDataForType:(NSString *)type
{
    return [[ZZCredentialsKeyData alloc] initWithType:type];
}

- (instancetype)initWithType:(NSString *)type
{
    self = [super init];
    if (self)
    {
        if (type != nil)
        {
            type = [NSString stringWithFormat:@"%@-", type];
        }
        
        _regionKey = [NSString stringWithFormat:@"%@%@", type, ZZS3CredentialsDomainModelAttributes.region];
        _bucketKey = [NSString stringWithFormat:@"%@%@", type, ZZS3CredentialsDomainModelAttributes.bucket];
        _accessKey = [NSString stringWithFormat:@"%@%@", type, ZZS3CredentialsDomainModelAttributes.accessKey];
        _secretKey = [NSString stringWithFormat:@"%@%@", type, ZZS3CredentialsDomainModelAttributes.secretKey];
    }
    return self;
}

@end
