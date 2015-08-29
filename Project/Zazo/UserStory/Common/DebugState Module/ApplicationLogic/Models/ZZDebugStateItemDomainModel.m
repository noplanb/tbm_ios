//
//  ZZDebugStateItemDomainModel.m
//  Zazo
//
//  Created by Oksana Kovalchuk on 8/27/15.
//  Copyright (c) 2015 No Plan B. All rights reserved.
//

#import "ZZDebugStateItemDomainModel.h"

@implementation ZZDebugStateItemDomainModel

+ (instancetype)itemWithItemID:(NSString *)itemID status:(NSString *)status
{
    ZZDebugStateItemDomainModel* model = [ZZDebugStateItemDomainModel new];
    model.itemID = itemID;
    model.status = status;
    
    return model;
}

@end
