//
//  ZZVideoDataUpdater.h
//  Zazo
//
//  Created by ANODA on 10/28/15.
//  Copyright © 2015 No Plan B. All rights reserved.
//

@class ZZVideoDomainModel;
@class TBMVideo;
@class ZZFriendDomainModel;

@interface ZZVideoDataUpdater : NSObject

+ (ZZVideoDomainModel*)upsertVideo:(ZZVideoDomainModel*)model;

//+ (void)deleteItem:(ZZVideoDomainModel*)model;
+ (void)destroy:(TBMVideo *)video;

+ (void)deleteAllViewedOrFailedVideoWithFriendId:(NSString*)friendId;
+ (void)deleteVideoFileWithVideo:(TBMVideo*)video;
+ (void)deleteFilesForVideo:(TBMVideo*)video;
+ (void)updateViewedVideoCounterWithVideoDomainModel:(ZZVideoDomainModel*)playedVideoModel;

@end
