//
//  ZZUserModelsMapper.h
//  Zazo
//
//  Created by ANODA on 8/10/15.
//  Copyright (c) 2015 ANODA. All rights reserved.
//

#import "ZZUserDomainModel.h"
#import "TBMUser.h"

@interface ZZUserModelsMapper : NSObject

+ (TBMUser*)fillEntity:(TBMUser*)entity fromModel:(ZZUserDomainModel*)model;
+ (ZZUserDomainModel*)fillModel:(ZZUserDomainModel*)model fromEntity:(TBMUser*)entity;

@end
