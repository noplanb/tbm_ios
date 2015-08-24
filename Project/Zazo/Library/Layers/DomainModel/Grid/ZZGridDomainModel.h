//
//  ZZGridDomainModel.h
//  Zazo
//
//  Created by Oksana Kovalchuk on 8/10/15.
//  Copyright (c) 2015 ANODA. All rights reserved.
//

#import "ZZBaseDomainModel.h"

@class ZZFriendDomainModel;

@interface ZZGridDomainModel : ZZBaseDomainModel

@property (nonatomic, strong) NSNumber* index;
@property (nonatomic, strong) ZZFriendDomainModel* relatedUser;

@end
