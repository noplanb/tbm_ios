//
//  ZZVideoDataProvider.h
//  Zazo
//
//  Created by ANODA on 8/10/15.
//  Copyright (c) 2015 ANODA. All rights reserved.
//

#import "ZZVideoStatuses.h"
#import "ZZVideoDomainModel.h"

@class ZZFriendDomainModel;

extern NSString * const ZZVideosDeletedNotification;

@interface ZZVideoDataProvider : NSObject

+ (ZZVideoDomainModel *)itemWithID:(NSString *)itemID;

+ (ZZVideoDomainModel *)createIncomingVideoModelForFriend:(ZZFriendDomainModel *)friendModel withVideoID:(NSString *)videoId;

+ (NSArray <ZZVideoDomainModel *> *)videosWithStatus:(ZZVideoIncomingStatus)status;

#pragma mark - Count

+ (NSUInteger)countVideosWithStatus:(ZZVideoIncomingStatus)status fromFriend:(NSString *)friendID;

+ (NSUInteger)countVideosWithStatus:(ZZVideoIncomingStatus)status;

+ (NSUInteger)countAllVideos;

+ (NSArray *)sortedIncomingVideosForUserWithID:(NSString *)friendID;

#pragma mark - Helpers

+ (BOOL)videoExists:(NSString *)videoID;

+ (void)printAll;

+ (NSURL *)videoUrlWithVideoModel:(ZZVideoDomainModel *)video;

@end
