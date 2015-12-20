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

+ (ZZVideoDomainModel*)itemWithID:(NSString*)itemID;

+ (ZZVideoDomainModel*)createIncomingVideoModelForFriend:(ZZFriendDomainModel*)friend withVideoId:(NSString*)videoId;
+ (NSArray *)downloadingVideos;

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
+ (void)deleteVideoWithID:(NSString*)videoID context:(NSManagedObjectContext*)context;


#pragma mark - Helpers

+ (BOOL)isStatusDownloadingWithVideo:(ZZVideoDomainModel*)video;
+ (void)printAll;
+ (NSURL *)videoUrlWithVideoModel:(ZZVideoDomainModel*)video;
+ (BOOL)videoFileExistsForVideoModel:(ZZVideoDomainModel*)video;

@end
