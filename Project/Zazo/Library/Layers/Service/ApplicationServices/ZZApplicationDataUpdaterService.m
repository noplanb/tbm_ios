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
#import "ZZFriendDataProvider.h"

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


- (void)queueDownloadWithFriendID:(NSString *)friendID videoIds:(NSSet *)videoIds
{
    for (NSString *videoId in videoIds)
    {
        [self.delegate freshVideoDetectedWithVideoID:videoId friendID:friendID];
    }
}







- (void)_pollAllFriends
{
//    ANDispatchBlockToBackgroundQueue(^{
//        OB_INFO(@"pollAllFriends");
//        
//        NSArray* friends = [TBMFriend all];
//        for (TBMFriend *f in friends)
//        {
//            [self _pollVideosWithFriend:f];
//            [self _pollVideoStatusWithFriend:f];
//        }
//        [self _pollEverSentStatusForAllFriends];
//    });
//
    //    +    // Note I intentionally do not put these on a background queue.
    //    +    // The http requests and responses will run on a background thread by themselves. The actions
    //    +    // prior to calling the http requests are light. I dont wish to incur the delay of a background queue
    //    +    // to start the requests. The user must see some results from polling within a second or two of opening the
    //    +    // app or he will think there is nothing new and close.
    
    
    
    [self _pollEverSentStatusForAllFriends];
    [self _pollAllIncomingVideos];
    [self _pollAllOutgoingVideoStatus];
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


- (void)_pollAllIncomingVideos
{
    [[ZZRemoteStoageTransportService getAllIncomingVideoIds] subscribeNext:^(NSArray *models) {
        for (ZZKeyStoreIncomingVideoIdsDomainModel *model in models) {
            
            // TODO: This is a back ass way of getting a friendModel from Mkey. What is the correct way?
            TBMFriend *friend = [TBMFriend findWithMkey:model.friendMkey];
            if (friend.idTbm)
            {
                ZZFriendDomainModel *friendModel = [ZZFriendDataProvider modelFromEntity:friend];
                if ([model.videoIds count] != 0)
                {
                    OB_INFO(@"%@  vids = %@", [friendModel fullName], model.videoIds);
                    [self queueDownloadWithFriendID:friendModel.idTbm videoIds:model.videoIds];
                }
            }
        }
    }];
}


- (void)pollAllOutgoingVideoStatus
{
    [[ZZKeyStoreTransportService getAllOutgoingVideoStatus] subscribeNext:^(NSArray *models) {
        for (ZZKeyStoreOutgoingVideoStatusDomainModel *model in models){
            
            // TODO: Use friendModel rather than friendEntity.
            TBMFriend *friend = [TBMFriend findWithMkey:model.friendMkey];
            if (friend)
            {
                if ([model status] == ZZVideoOutgoingStatusUnknown)
                {
                    OB_ERROR(@"pollVideoStatusWithFriend: got unknown outgoing video status. This should never happen");
                    return;
                }
                [friend setAndNotifyOutgoingVideoStatus:[model status] videoId:model.videoId];
            }
        }
    }];
}




//TODO: UNUSED!

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
