//
//  ZZGridDomainModel.m
//  Zazo
//
//  Created by ANODA on 8/10/15.
//  Copyright (c) 2015 ANODA. All rights reserved.
//

#import "ZZGridDomainModel.h"
#import "ZZGridUIConstants.h"

const struct ZZGridDomainModelAttributes ZZGridDomainModelAttributes = {
    .itemID = @"itemID",
    .relatedUser = @"relatedUser",
    .index = @"index",
};

@implementation ZZGridDomainModel

- (NSInteger)indexPathIndexForItem
{
    return kGridIndexFromFlowIndex(self.index);
}

@end
