//
//  TBMAppSyncManager.m
//  tbm
//
//  Created by Sani Elfishawy on 5/27/14.
//  Copyright (c) 2014 No Plan B. All rights reserved.
//

#import "TBMAppSyncManagerDeprecated.h"
#import "TBMVideoIdUtils.h"
#import "TBMHttpClient.h"

@implementation TBMAppSyncManagerDeprecated

//+ (void)handleSyncPayload:(NSDictionary *)payload{
//    DebugLog(@"handleSyncPayload: %@", payload);
//    NSArray *videosRequiringDownload = [payload objectForKey:@"videosRequiringDownload"];
//    [TBMAppSyncManager handleVideosRequiringDownload:videosRequiringDownload];
//    
//    NSArray *videoStatusUpdates = [payload objectForKey:@"videoStatusUpdates"];
//    [TBMAppSyncManager handleVideoStatusUpdates:videoStatusUpdates];
//}
//
//+ (void)handleVideosRequiringDownload:(NSArray *)videosRequiringDownload{
//    DebugLog(@"handleVideosRequiringDownload: %lu", (unsigned long)[videosRequiringDownload count]);
//    for (NSString *videoId in videosRequiringDownload){
//        NSString *friendId = [TBMVideoIdUtils senderIdWithVideoId:videoId];
//        TBMFriend *friend = [TBMFriend findWithId:friendId];
//        [friend addToDownloadQueueWithVideoId:videoId];
//    }
//}
//
//+ (void)handleVideoStatusUpdates:(NSArray *)videoStatusUpdates{
//    DebugLog(@"handleVideoStatusUpdates: %lu", (unsigned long)[videoStatusUpdates count]);
//    for (NSDictionary *vsu in videoStatusUpdates){
//        NSString *friendId = [TBMVideoIdUtils receiverIdWithVideoId:vsu[@"videoId"]];
//        TBMFriend *friend = [TBMFriend findWithId:friendId];
//        NSString *status = [vsu[@"status"] lowercaseString];
//        if ([status isEqual:@"downloaded"]){
//            [friend setAndNotifyOutgoingVideoStatus:OUTGOING_VIDEO_STATUS_DOWNLOADED];
//        } else if ([status isEqual:@"viewed"]) {
//            [friend setAndNotifyOutgoingVideoStatus:OUTGOING_VIDEO_STATUS_VIEWED];
//        } else {
//            DebugLog(@"ERROR: handleVideoStatusUpdates: did not recognize status from server. ERROR this should never happen.");
//        }
//    }
//}
//
//+ (void)notifyServerOfViewedForFriend:(TBMFriend *)friend{
//    NSString *path = [NSString stringWithFormat:@"videos/update_viewed"];
//    NSURLSessionDataTask *task = [[TBMHttpClient sharedClient] GET:path parameters:@{@"video_id": friend.incomingVideoId} success:^(NSURLSessionDataTask *task, id responseObject) {
//        DebugLog(@"notifyServerOfViewedForFriend: %@", responseObject);
//    } failure:^(NSURLSessionDataTask *task, NSError *error) {
//        DebugLog(@"notifyServerOfViewedForFriend: ERROR: %@", error);
//    }];
//    [task resume];
//}


@end
