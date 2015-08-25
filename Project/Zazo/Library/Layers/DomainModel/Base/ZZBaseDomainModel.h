//
//  ZZBaseDomainModel.h
//  Zazo
//
//  Created by ANODA on 8/10/15.
//  Copyright (c) 2015 ANODA. All rights reserved.
//

#import "ANBaseDomainModel.h"

extern const struct ZZBaseDomainModelAttributes {
    __unsafe_unretained NSString *idTbm;
} ZZBaseDomainModelAttributes;

@interface ZZBaseDomainModel : ANBaseDomainModel

@property (nonatomic, copy) NSString* idTbm;

@end
