//
//  ZZVideoDataProvider+Entities.h
//  Zazo
//
//  Created by Rinat on 11.12.15.
//  Copyright © 2015 No Plan B. All rights reserved.
//

#import "ZZVideoDataProvider.h"

@class TBMVideo;
@class TBMFriend;

@interface ZZVideoDataProvider (Entities)

#pragma mark - Fetches

+ (TBMVideo*)newWithVideoId:(NSString *)videoId onContext:(NSManagedObjectContext*)context;
+ (TBMVideo*)findWithVideoId:(NSString *)videoId;
+ (NSArray *)all;
+ (TBMVideo*)entityWithID:(NSString*)itemID;
+ (NSArray*)downloadingEntities;
+ (TBMVideo*)createIncomingVideoForFriend:(TBMFriend*)friend withVideoId:(NSString*)videoId;


#pragma mark - Mapping

//+ (TBMVideo*)entityFromModel:(ZZVideoDomainModel*)model;
+ (ZZVideoDomainModel*)modelFromEntity:(TBMVideo*)entity;

#pragma mark - Helpers

+ (NSURL *)videoUrlWithVideo:(TBMVideo*)video;
+ (BOOL)videoFileExistsForVideo:(TBMVideo*)video;
//+ (unsigned long long)videoFileSizeForVideo:(TBMVideo*)video;
//+ (BOOL)hasValidVideoFileWithVideo:(TBMVideo*)video;
+ (BOOL)isStatusDownloadingWithVideo:(TBMVideo*)video;

@end