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
+ (TBMVideo*)createIncomingVideoForFriend:(TBMFriend*)friend withVideoId:(NSString*)videoId;
+ (TBMVideo*)createOutgoingVideoForFriendID:(NSString*)friendID
                                    videoID:(NSString*)videoID
                                    context:(NSManagedObjectContext*)context;


#pragma mark - Mapping

//+ (TBMVideo*)entityFromModel:(ZZVideoDomainModel*)model;
+ (ZZVideoDomainModel*)modelFromEntity:(TBMVideo*)entity;

#pragma mark - Helpers

//+ (unsigned long long)videoFileSizeForVideo:(TBMVideo*)video;
//+ (BOOL)hasValidVideoFileWithVideo:(TBMVideo*)video;
+ (NSURL *)videoUrlWithVideo:(TBMVideo*)video;

@end