//
//  ZZUserDataProvider.h
//  Zazo
//
//  Created by ANODA on 8/10/15.
//  Copyright (c) 2015 ANODA. All rights reserved.
//

#import "ZZUserDomainModel.h"

@interface ZZUserDataProvider : NSObject

+ (ZZUserDomainModel *)authenticatedUser;

+ (ZZUserDomainModel *)upsertUserWithModel:(ZZUserDomainModel *)model;

@end
