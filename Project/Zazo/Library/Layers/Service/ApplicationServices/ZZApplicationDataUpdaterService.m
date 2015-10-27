//
//  ZZApplicationDataUpdaterService.m
//  Zazo
//
//  Created by Oksana Kovalchuk on 10/20/15.
//  Copyright © 2015 No Plan B. All rights reserved.
//

#import "ZZApplicationDataUpdaterService.h"
#import "ZZFriendsTransportService.h"
#import "TBMFriend.h"
#import "ZZUserDataProvider.h"
#import "ZZRemoteStoageTransportService.h"

@implementation ZZApplicationDataUpdaterService

- (void)updateAllData
{
    OB_INFO(@"getAndPollAllFriends");
    
    [[ZZFriendsTransportService loadFriendList] subscribeNext:^(NSArray* friends) {
        
        OB_INFO(@"gotFriends");
        [self _pollAllFriends];
    } error:^(NSError *error) {
        
        [self _pollAllFriends];
    }];
}

- (void)updateApplicationBadge
{
    OB_INFO(@"setBadgeNumberDownloadedUnviewed = %lu", (unsigned long) [TBMVideo downloadedUnviewedCount]);
    [self setBadgeCount:[TBMVideo downloadedUnviewedCount]];
}


#pragma mark -  Notification center and badge control

- (void)clearBadgeCount
{
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:1];
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
}

- (void)setBadgeNumberUnviewed
{
    OB_INFO(@"setBadgeNumberUnviewed = %lu", (unsigned long) [TBMVideo unviewedCount]);
    [self setBadgeCount:[TBMVideo unviewedCount]];
}

- (void)setBadgeCount:(NSInteger)count
{
    if (count == 0)
    {
        [self clearBadgeCount];
    }
    else
    {
        [[UIApplication sharedApplication] setApplicationIconBadgeNumber:count];
    }
}

- (void)_pollAllFriends
{
    ANDispatchBlockToBackgroundQueue(^{
        OB_INFO(@"pollAllFriends");
        
        NSArray* friends = [TBMFriend all];
        for (TBMFriend *f in friends)
        {
            [self _pollVideosWithFriend:f];
            [self _pollVideoStatusWithFriend:f];
        }
        [self _pollEverSentStatusForAllFriends];
    });
}

- (void)_pollEverSentStatusForAllFriends
{
    ZZUserDomainModel* me = [ZZUserDataProvider authenticatedUser];
    
    [[ZZRemoteStoageTransportService loadRemoteEverSentFriendsIDsForUserMkey:me.mkey] subscribeNext:^(id x) {
        
        ANDispatchBlockToBackgroundQueue(^{
            [TBMFriend setEverSentForMkeys:x];
        });
    }];
}

- (void)_pollVideosWithFriend:(TBMFriend*)friend
{
    if (friend.idTbm)
    {
        __block NSString* friendID = friend.idTbm;
        __block NSString* firstName = friend.firstName;
        
        [[ZZRemoteStoageTransportService loadRemoteIncomingVideoIDsWithFriendMkey:friend.mkey
                                                                       friendCKey:friend.ckey] subscribeNext:^(NSArray* videoIds) {
            OB_INFO(@"pollWithFriend: %@  vids = %@", firstName, ANIsEmpty(videoIds) ? @"no videos" : videoIds);
            if (!ANIsEmpty(videoIds))
            {
                for (NSString *videoId in videoIds)
                {
                    [self.delegate freshVideoDetectedWithVideoID:videoId friendID:friendID];
                }
            }
        }];
    }
}

- (void)_pollVideoStatusWithFriend:(TBMFriend*)friend
{
    if (friend.outgoingVideoStatusValue == OUTGOING_VIDEO_STATUS_VIEWED)
    {
        OB_INFO(@"pollVideoStatusWithFriend: skipping %@ becuase outgoing status is viewed.", friend.firstName);
        return;
    }
    
    [[ZZRemoteStoageTransportService loadRemoteOutgoingVideoStatusForFriendMkey:friend.mkey
                                                                     friendCKey:friend.ckey] subscribeNext:^(NSDictionary *response) {
        
        if (!ANIsEmpty(response))
        {
            NSString *status = response[ZZRemoteStorageParameters.status];
            ZZRemoteStorageVideoStatus ovsts = ZZRemoteStorageVideoStatusEnumValueFromSrting(status);
            if (ovsts == ZZRemoteStorageVideoStatusNone)
            {
                OB_ERROR(@"pollVideoStatusWithFriend: got unknown outgoing video status: %@", status);
                return;
            }
            // This call handles making sure that videoId == outgoingVideoId etc.
            
            
            TBMOutgoingVideoStatus videoStatus;
            if (ovsts == ZZRemoteStorageVideoStatusDownloaded)
            {
                videoStatus = OUTGOING_VIDEO_STATUS_DOWNLOADED;
            }
            else
            {
                videoStatus = OUTGOING_VIDEO_STATUS_VIEWED;
            }
            
            [friend setAndNotifyOutgoingVideoStatus:videoStatus
                                            videoId:response[ZZRemoteStorageParameters.videoID]];
        }
    } error:^(NSError *error) {
        // This can happen on startup when there is nothing in the remoteVideoStatusKV
        OB_WARN(@"pollVideoStatusWithFriend: Error polling outgoingVideoStatus for %@ - %@", friend.firstName, error);
    }];
}

@end
