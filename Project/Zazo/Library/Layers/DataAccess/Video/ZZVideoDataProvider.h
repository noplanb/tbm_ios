//
//  ZZVideoDataProvider.h
//  Zazo
//
//  Created by ANODA on 8/10/15.
//  Copyright (c) 2015 ANODA. All rights reserved.
//

@class ZZVideoDomainModel;
@class TBMVideo;
@class ZZFriendDomainModel;
@class TBMFriend;

@interface ZZVideoDataProvider : NSObject


#pragma mark - Fetches

+ (TBMVideo*)newWithVideoId:(NSString *)videoId onContext:(NSManagedObjectContext*)context;
+ (TBMVideo*)findWithVideoId:(NSString *)videoId;
+ (NSArray *)all;
+ (ZZVideoDomainModel*)itemWithID:(NSString*)itemID;
+ (TBMVideo*)entityWithID:(NSString*)itemID;
+ (NSArray*)downloadingEntities;


+ (TBMVideo*)createIncomingVideoForFriend:(TBMFriend*)friend withVideoId:(NSString*)videoId;

#pragma mark - Count

+ (NSUInteger)countDownloadedUnviewedVideos;
+ (NSUInteger)countDownloadingVideos;
+ (NSUInteger)countTotalUnviewedVideos;
+ (NSUInteger)countAllVideos;


#pragma mark - Load

//+ (NSArray*)loadUnviewedVideos; // TODO: load with status ?
//+ (NSArray*)loadDownloadingVideos;
//+ (NSArray*)loadAllVideos;


+ (NSArray*)sortedIncomingVideosForUser:(ZZFriendDomainModel*)friendModel;


#pragma mark - Mapping

//+ (TBMVideo*)entityFromModel:(ZZVideoDomainModel*)model;
+ (ZZVideoDomainModel*)modelFromEntity:(TBMVideo*)entity;


#pragma mark - Helpers

+ (void)printAll;
+ (NSURL *)videoUrlWithVideo:(TBMVideo*)video;
+ (BOOL)videoFileExistsForVideo:(TBMVideo*)video;
//+ (unsigned long long)videoFileSizeForVideo:(TBMVideo*)video;
//+ (BOOL)hasValidVideoFileWithVideo:(TBMVideo*)video;
+ (BOOL)isStatusDownloadingWithVideo:(TBMVideo*)video;

@end
