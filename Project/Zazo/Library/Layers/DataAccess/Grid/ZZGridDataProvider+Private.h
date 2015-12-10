//
//  ZZGridDataProvider+Private.h
//  Zazo
//
//  Created by Vitaly Cherevaty on 12/9/15.
//  Copyright © 2015 No Plan B. All rights reserved.
//

#import "ZZGridDataProvider.h"

@class TBMGridElement;
@class TBMFriend;

@interface ZZGridDataProvider (Private)

+ (ZZGridDomainModel*)modelWithFriend:(TBMFriend *)item;

#pragma mark - Mapping

+ (ZZGridDomainModel*)modelFromEntity:(TBMGridElement*)entity;
+ (TBMGridElement*)entityWithItemID:(NSString*)itemID;

+ (TBMGridElement*)findWithIntIndex:(NSInteger)i;
+ (TBMGridElement*)findWithFriend:(TBMFriend *)item;

@end
