//
//  TBMAppSyncManager.h
//  tbm
//
//  Created by Sani Elfishawy on 5/27/14.
//  Copyright (c) 2014 No Plan B. All rights reserved.
//
//  Handles polling as well as notification payloads for updating outgoing video status as well as queuing videos for download.

#import <Foundation/Foundation.h>
#import "TBMFriend.h"

@interface TBMAppSyncManager : NSObject

+ (void)handleSyncPayload:(NSDictionary *)payload;
+ (void)handleVideosRequiringDownload:(NSArray *)videosRequiringDownload;
+ (void)handleVideoStatusUpdates:(NSArray *)videoStatusUpdates;
+ (void)notifyServerOfViewedForFriend:(TBMFriend *)friend;
@end
