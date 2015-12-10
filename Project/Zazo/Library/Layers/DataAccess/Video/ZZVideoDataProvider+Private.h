//
//  ZZVideoDataProvider+Private.h
//  Zazo
//
//  Created by Vitaly Cherevaty on 12/9/15.
//  Copyright © 2015 No Plan B. All rights reserved.
//

#import "ZZVideoDataProvider.h"

@class TBMVideo;

@interface ZZVideoDataProvider (Private)


#pragma mark - Fetches

+ (NSArray *)allEntities;
+ (TBMVideo*)entityWithID:(NSString*)itemID;
+ (NSArray*)downloadingEntities;

#pragma mark - Mapping

+ (ZZVideoDomainModel*)modelFromEntity:(TBMVideo*)entity;

@end
