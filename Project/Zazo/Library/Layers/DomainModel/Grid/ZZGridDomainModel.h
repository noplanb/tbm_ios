//
//  ZZGridDomainModel.h
//  Zazo
//
//  Created by ANODA on 8/10/15.
//  Copyright (c) 2015 ANODA. All rights reserved.
//

#import "ZZBaseDomainModel.h"
#import "ZZFriendDomainModel.h"

extern const struct ZZGridDomainModelAttributes
{
    __unsafe_unretained NSString *itemID;
    __unsafe_unretained NSString *relatedUser;
    __unsafe_unretained NSString *index;
} ZZGridDomainModelAttributes;

@interface ZZGridDomainModel : ZZBaseDomainModel

@property (nonatomic, copy) NSString *itemID;
@property (nonatomic, strong) ZZFriendDomainModel *relatedUser;
@property (nonatomic, assign) NSInteger index;
//@property (nonatomic, assign) BOOL isDownloadAnimationViewed;

- (NSInteger)indexPathIndexForItem;

@end
