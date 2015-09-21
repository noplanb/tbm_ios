//
//  ZZS3CredentialsDomainModel.h
//  Zazo
//
//  Created by ANODA on 8/11/15.
//  Copyright (c) 2015 ANODA. All rights reserved.
//

#import "ANBaseDomainModel.h"

@class FEMObjectMapping;

extern const struct ZZS3CredentialsDomainModelAttributes {
    __unsafe_unretained NSString *region;
    __unsafe_unretained NSString *bucket;
    __unsafe_unretained NSString *accessKey;
    __unsafe_unretained NSString *secretKey;
} ZZS3CredentialsDomainModelAttributes;

@interface ZZS3CredentialsDomainModel : ANBaseDomainModel

@property (nonatomic, copy) NSString* region;
@property (nonatomic, copy) NSString* bucket;
@property (nonatomic, copy) NSString* accessKey;
@property (nonatomic, copy) NSString* secretKey;

+ (FEMObjectMapping*)mapping;

- (BOOL)isValid;

@end
