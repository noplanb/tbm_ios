//
//  ZZUserDomainModel.h
//  Zazo
//
//  Created by ANODA on 8/10/15.
//  Copyright (c) 2015 ANODA. All rights reserved.
//

#import "ZZBaseDomainModel.h"
#import "ZZUserInterface.h"

@class FEMObjectMapping;

extern const struct ZZUserDomainModelAttributes {
    __unsafe_unretained NSString *firstName;
    __unsafe_unretained NSString *lastName;
    __unsafe_unretained NSString *auth;
    __unsafe_unretained NSString *mkey;
    __unsafe_unretained NSString *mobileNumber;
    __unsafe_unretained NSString *isRegistered;
} ZZUserDomainModelAttributes;

@interface ZZUserDomainModel : ZZBaseDomainModel <ZZUserInterface>

@property (nonatomic, copy) NSString* firstName;
@property (nonatomic, copy) NSString* lastName;
@property (nonatomic, copy) NSString* auth;
@property (nonatomic, copy) NSString* mkey;
@property (nonatomic, copy) NSString* mobileNumber;
@property (nonatomic, assign) BOOL isRegistered;

@property (nonatomic, copy) NSString* countryCode;
@property (nonatomic, copy) NSString* plainPhoneNumber;

+ (FEMObjectMapping*)mapping;
- (NSString*)fullName;

@end
