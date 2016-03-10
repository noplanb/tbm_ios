//
//  ZZVideoDataUpdater.h
//  Zazo
//
//  Created by ANODA on 10/28/15.
//  Copyright © 2015 No Plan B. All rights reserved.
//

#import "ZZVideoStatuses.h"

@interface ZZVideoDataUpdater : NSObject

+ (void)updateVideoWithID:(NSString *)videoID setIncomingStatus:(ZZVideoIncomingStatus)videoStatus;
+ (void)updateVideoWithID:(NSString *)videoID setDownloadRetryCount:(NSUInteger)count;

+ (void)deleteAllViewedVideosWithFriendID:(NSString*)friendId;
+ (void)deleteAllFailedVideos;
+ (void)deleteAllVideos;

@end