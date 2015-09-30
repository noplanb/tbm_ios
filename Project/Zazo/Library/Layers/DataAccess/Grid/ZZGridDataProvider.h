//
//  ZZGridDataProvider.h
//  Zazo
//
//  Created by ANODA on 8/10/15.
//  Copyright (c) 2015 ANODA. All rights reserved.
//

@class ZZGridDomainModel;
@class ZZFriendDomainModel;
@class TBMGridElement;

@interface ZZGridDataProvider : NSObject


#pragma mark - Fetches

+ (NSArray*)loadAllGridsSortByIndex:(BOOL)shouldSortByIndex;
+ (ZZGridDomainModel*)modelWithIndex:(NSInteger)index;

+ (ZZGridDomainModel*)modelWithRelatedUserID:(NSString*)userID;
+ (BOOL)isRelatedUserOnGridWithID:(NSString*)userID;

+ (ZZGridDomainModel*)loadFirstEmptyGridElement;


#pragma mark - Mapping

+ (ZZGridDomainModel*)modelFromEntity:(TBMGridElement*)entity;

+ (TBMGridElement*)entityWithItemID:(NSString*)itemID;

@end
