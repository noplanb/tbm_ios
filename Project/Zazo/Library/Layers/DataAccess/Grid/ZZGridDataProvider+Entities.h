//
//  ZZGridDataProvider+Entities.h
//  Zazo
//
//  Created by Rinat on 11.12.15.
//  Copyright © 2015 No Plan B. All rights reserved.
//

#import "ZZGridDataProvider.h"

@class TBMGridElement;
@class TBMFriend;

@interface ZZGridDataProvider (Entities)

#pragma mark - Fetches

+ (ZZGridDomainModel*)modelWithFriend:(TBMFriend *)item;

#pragma mark - Mapping

+ (ZZGridDomainModel*)modelFromEntity:(TBMGridElement*)entity;
+ (TBMGridElement*)entityWithItemID:(NSString*)itemID;

+ (TBMGridElement*)findWithIntIndex:(NSInteger)i;
+ (TBMGridElement*)findWithFriend:(TBMFriend *)item;


//#pragma mark - Entities
//
//+ (BOOL)friendIsOnGrid:(TBMFriend *)item;
//+ (BOOL)hasSentVideos:(NSUInteger)index;

@end