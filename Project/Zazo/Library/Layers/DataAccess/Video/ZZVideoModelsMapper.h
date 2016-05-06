//
//  ZZVideoModelsMapper.h
//  Zazo
//
//  Created by ANODA on 8/10/15.
//  Copyright (c) 2015 ANODA. All rights reserved.
//

@class ZZVideoDomainModel;
@class TBMVideo;

@interface ZZVideoModelsMapper : NSObject

+ (TBMVideo *)fillEntity:(TBMVideo *)entity fromModel:(ZZVideoDomainModel *)model;

+ (ZZVideoDomainModel *)fillModel:(ZZVideoDomainModel *)model fromEntity:(TBMVideo *)entity;

@end
