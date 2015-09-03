//
//  ZZGridDomainModel.h
//  Zazo
//
//  Created by ANODA on 8/10/15.
//  Copyright (c) 2015 ANODA. All rights reserved.
//

#import "ZZBaseDomainModel.h"
#import "ZZFriendDomainModel.h"


@interface ZZGridDomainModel : ZZBaseDomainModel

@property (nonatomic, strong) ZZFriendDomainModel* relatedUser;
@property (nonatomic, strong) NSNumber* index;

@end
