//
//  ZZFriendModelsMapper.h
//  Zazo
//
//  Created by ANODA on 8/10/15.
//  Copyright (c) 2015 ANODA. All rights reserved.
//

@class ZZFriendDomainModel;
@class TBMFriend;

@interface ZZFriendModelsMapper : NSObject

+ (TBMFriend *)fillEntity:(TBMFriend *)entity fromModel:(ZZFriendDomainModel *)model;

+ (ZZFriendDomainModel *)fillModel:(ZZFriendDomainModel *)model fromEntity:(TBMFriend *)entity;

@end
