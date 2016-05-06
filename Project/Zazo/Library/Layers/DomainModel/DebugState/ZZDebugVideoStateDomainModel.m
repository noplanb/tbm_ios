//
//  ZZDebugVideoStateDomainModel.m
//  Zazo
//
//  Created by Oksana Kovalchuk on 8/27/15.
//  Copyright (c) 2015 No Plan B. All rights reserved.
//

#import "ZZDebugVideoStateDomainModel.h"

const struct ZZDebugVideoStateDomainModelAttributes ZZDebugVideoStateDomainModelAttributes = {
        .itemID = @"itemID",
        .status = @"status",
};

@implementation ZZDebugVideoStateDomainModel

+ (instancetype)itemWithItemID:(NSString *)itemID status:(NSString *)status
{
    ZZDebugVideoStateDomainModel *model = [ZZDebugVideoStateDomainModel new];
    model.itemID = itemID;
    model.status = status;

    return model;
}

@end
