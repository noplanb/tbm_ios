//
//  ZZVideoDataUpdater.h
//  Zazo
//
//  Created by ANODA on 10/28/15.
//  Copyright © 2015 No Plan B. All rights reserved.
//

@class ZZVideoDomainModel;
@class ZZFriendDomainModel;

@interface ZZVideoDataUpdater : NSObject

+ (void)deleteAllViewedOrFailedVideoWithFriendId:(NSString*)friendId;
+ (ZZVideoDomainModel*)upsertVideo:(ZZVideoDomainModel*)model;

@end
