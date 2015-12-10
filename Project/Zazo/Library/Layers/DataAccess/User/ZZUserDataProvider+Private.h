//
//  ZZUserDataProvider+Private.h
//  Zazo
//
//  Created by Vitaly Cherevaty on 12/9/15.
//  Copyright © 2015 No Plan B. All rights reserved.
//

#import "ZZUserDataProvider.h"

@class TBMUser;

@interface ZZUserDataProvider (Private)

+ (ZZUserDomainModel*)modelFromEntity:(TBMUser*)entity;
+ (TBMUser*)authenticatedEntity;

@end
