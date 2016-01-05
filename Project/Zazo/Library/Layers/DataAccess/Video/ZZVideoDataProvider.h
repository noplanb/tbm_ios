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
+ (ZZVideoDomainModel*)createIncomingVideoModelForFriend:(ZZFriendDomainModel*)friendModel withVideoID:(NSString*)videoId;
+ (NSArray *)downloadingVideos;

#pragma mark - Count

+ (NSUInteger)countDownloadedUnviewedVideos;
+ (NSUInteger)countDownloadingVideos;
+ (NSUInteger)countTotalUnviewedVideos;
+ (NSUInteger)countAllVideos;

+ (NSArray*)sortedIncomingVideosForUser:(ZZFriendDomainModel*)friendModel;

#pragma mark - Helpers

+ (BOOL)isStatusDownloadingWithVideo:(ZZVideoDomainModel*)video;
+ (void)printAll;
+ (NSURL *)videoUrlWithVideoModel:(ZZVideoDomainModel*)video;

@end
