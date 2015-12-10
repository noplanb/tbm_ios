//
//  ZZVideoDataProvider.h
//  Zazo
//
//  Created by ANODA on 8/10/15.
//  Copyright (c) 2015 ANODA. All rights reserved.
//

@class ZZVideoDomainModel;
@class ZZFriendDomainModel;

@interface ZZVideoDataProvider : NSObject


#pragma mark - Fetches

+ (ZZVideoDomainModel*)findWithVideoId:(NSString *)videoId;
+ (ZZVideoDomainModel*)itemWithID:(NSString*)itemID;
+ (NSArray*)downloadingItems;
+ (ZZVideoDomainModel*)createIncomingVideoForFriendId:(NSString*)friendId withVideoId:(NSString*)videoId;

#pragma mark - Count

+ (NSUInteger)countDownloadedUnviewedVideos;
+ (NSUInteger)countDownloadingVideos;
+ (NSUInteger)countTotalUnviewedVideos;
+ (NSUInteger)countAllVideos;


#pragma mark - Load

+ (NSArray*)sortedIncomingVideosForUser:(ZZFriendDomainModel*)friendModel;
+ (NSArray*)sortedIncomingVideosForUserID:(NSString*)userID;

#pragma mark - Helpers

+ (void)printAll;
+ (NSURL *)videoUrlWithVideo:(ZZVideoDomainModel*)video;
+ (BOOL)videoFileExistsForVideo:(ZZVideoDomainModel*)video;
+ (BOOL)isStatusDownloadingWithVideo:(ZZVideoDomainModel*)video;

@end
