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

#pragma mark Fetch

+ (ZZVideoDomainModel*)itemWithID:(NSString*)itemID;
+ (ZZVideoDomainModel*)createIncomingVideoModelForFriend:(ZZFriendDomainModel*)friendModel withVideoID:(NSString*)videoID;
+ (NSArray*)sortedIncomingVideosForUserWithID:(NSString *)friendID;
+ (NSArray *)downloadingVideos;

#pragma mark Count

+ (NSUInteger)countDownloadedUnviewedVideos;
+ (NSUInteger)countDownloadingVideos;
+ (NSUInteger)countTotalUnviewedVideos;
+ (NSUInteger)countAllVideos;

#pragma mark Helpers

+ (void)printAll;
+ (NSURL *)videoUrlWithVideoModel:(ZZVideoDomainModel*)video;

@end
