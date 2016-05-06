//
//  ZZGridDataProvider+Entities.h
//  Zazo
//
//  Created by Rinat on 11.12.15.
//  Copyright © 2015 No Plan B. All rights reserved.
//

#import "ZZGridDataProvider.h"

@class TBMGridElement;

@interface ZZGridDataProvider (Entities)

#pragma mark - Mapping

+ (ZZGridDomainModel *)modelFromEntity:(TBMGridElement *)entity;

+ (TBMGridElement *)entityWithItemID:(NSString *)itemID;

@end