//
//  ZZGridDataProvider.h
//  Zazo
//
//  Created by ANODA on 8/10/15.
//  Copyright (c) 2015 ANODA. All rights reserved.
//

@class ZZGridDomainModel;
@class ZZUserDomainModel;
@class TBMGridElement;

@interface ZZGridDataProvider : NSObject

+ (ZZGridDomainModel*)upsertModel:(ZZGridDomainModel*)model;
+ (void)deleteModel:(ZZGridDomainModel*)model;

#pragma mark - Fetches

+ (NSArray*)loadAllGridsSortByIndex:(BOOL)shouldSortByIndex;
+ (ZZGridDomainModel*)modelWithIndex:(NSInteger)index;
+ (ZZGridDomainModel*)modelWithRelatedUser:(ZZUserDomainModel*)user;
+ (BOOL)isRelatedUserOnGrid:(ZZUserDomainModel*)user;
+ (ZZGridDomainModel*)loadFirstEmptyGridElement;


#pragma mark - Mapping

+ (ZZGridDomainModel*)modelFromEntity:(TBMGridElement*)entity;
+ (TBMGridElement*)entityFromModel:(ZZGridDomainModel*)model;

@end
