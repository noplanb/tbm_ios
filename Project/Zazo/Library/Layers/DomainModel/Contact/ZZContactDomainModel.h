//
//  ZZContactDomainModel.h
//  Zazo
//
//  Created by ANODA on 8/11/15.
//  Copyright (c) 2015 ANODA. All rights reserved.
//

#import "ANBaseDomainModel.h"
#import "ZZUserInterface.h"
#import "ZZMenuEnumsAdditions.h"
#import "ZZCommunicationDomainModel.h"

@interface ZZContactDomainModel : ANBaseDomainModel <ZZUserInterface>

@property (nonatomic, copy) NSString* firstName;
@property (nonatomic, copy) NSString* lastName;
@property (nonatomic, strong) NSArray* phones;
@property (nonatomic, strong) NSArray* emails;

@property (nonatomic, strong) ZZCommunicationDomainModel* primaryPhone;

- (NSString*)fullName;
- (ZZMenuContactType)contactType;

+ (instancetype)modelWithFirstName:(NSString*)firstName lastName:(NSString*)lastName;

@end
