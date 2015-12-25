//
//  ZZVideoDataUpdater.h
//  Zazo
//
//  Created by ANODA on 10/28/15.
//  Copyright © 2015 No Plan B. All rights reserved.
//

#import "ZZVideoStatuses.h"

@class ZZVideoDomainModel;
@class TBMVideo;
@class ZZFriendDomainModel;

@interface ZZVideoDataUpdater : NSObject

+ (void)deleteAllViewedOrFailedVideoWithFriendId:(NSString*)friendId;

+ (void)updateViewedVideoCounterWithVideoDomainModel:(ZZVideoDomainModel*)playedVideoModel;

+ (void)updateVideoWithID:(NSString *)videoID setIncomingStatus:(ZZVideoIncomingStatus)videoStatus;
+ (void)updateVideoWithID:(NSString *)videoID setDownloadRetryCount:(NSUInteger)count;

@end
