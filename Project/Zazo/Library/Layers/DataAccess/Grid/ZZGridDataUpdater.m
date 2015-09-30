//
//  ZZGridDataUpdater.m
//  Zazo
//
//  Created by ANODA on 9/30/15.
//  Copyright © 2015 No Plan B. All rights reserved.
//

#import "ZZGridDataUpdater.h"
#import "ZZGridDomainModel.h"
#import "ZZGridDataProvider.h"

@implementation ZZGridDataUpdater

+ (ZZGridDomainModel*)upsertGridModelWithModel:(ZZGridDomainModel*)model
{
    return [ZZGridDataProvider upsertModel:model];
}

@end
