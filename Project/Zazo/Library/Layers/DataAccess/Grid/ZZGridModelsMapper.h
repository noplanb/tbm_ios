//
//  ZZGridModelsMapper.h
//  Zazo
//
//  Created by ANODA on 8/10/15.
//  Copyright (c) 2015 ANODA. All rights reserved.
//

#import "ZZGridDomainModel.h"
#import "TBMGridElement.h"

@interface ZZGridModelsMapper : NSObject

+ (ZZGridDomainModel *)fillModel:(ZZGridDomainModel *)model fromEntity:(TBMGridElement *)entity;

+ (TBMGridElement *)fillEntity:(TBMGridElement *)entity fromModel:(ZZGridDomainModel *)model;

@end
