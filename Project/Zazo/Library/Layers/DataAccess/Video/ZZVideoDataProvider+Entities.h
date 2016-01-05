//
//  ZZVideoDataProvider+Entities.h
//  Zazo
//
//  Created by Rinat on 11.12.15.
//  Copyright © 2015 No Plan B. All rights reserved.
//

#import "ZZVideoDataProvider.h"

@class TBMVideo;

@interface ZZVideoDataProvider (Entities)

#pragma mark - Fetches

+ (TBMVideo*)entityWithID:(NSString*)itemID;

#pragma mark - Mapping

+ (ZZVideoDomainModel*)modelFromEntity:(TBMVideo*)entity;

#pragma mark - Helpers

+ (NSURL *)videoUrlWithVideo:(TBMVideo*)video;

@end