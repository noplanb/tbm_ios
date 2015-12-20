//
//  ZZUserDataProvider+Entities.h
//  Zazo
//
//  Created by Rinat on 11.12.15.
//  Copyright © 2015 No Plan B. All rights reserved.
//

#import "ZZUserDataProvider.h"

@class TBMUser;

@interface ZZUserDataProvider (Entities)

//+ (TBMUser*)entityFromModel:(ZZUserDomainModel*)model;
+ (ZZUserDomainModel*)modelFromEntity:(TBMUser*)entity;

@end