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

- (NSString *)description
{
    NSMutableString *description = [NSMutableString stringWithFormat:@"<%@: ", NSStringFromClass([self class])];
    [description appendFormat:@"itemID=%@", self.itemID];
    [description appendFormat:@", relatedUser=%@", self.relatedUser];
    [description appendFormat:@", index=%li", (long)self.index];
    [description appendString:@">"];
    return description;
}


- (NSInteger)indexPathIndexForItem
{
    return kGridIndexFromFlowIndex(self.index);
}

@end
