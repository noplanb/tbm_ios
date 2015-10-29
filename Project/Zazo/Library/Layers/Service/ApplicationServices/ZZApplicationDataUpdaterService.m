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
#import "ZZKeyStoreIncomingVideoIdsDomainModel.h"
#import "ZZFriendModelsMapper.h"
#import "ZZFriendDomainModel.h"
#import "ZZKeyStoreOutgoingVideoStatusDomainModel.h"
#import "ZZVideoDataProvider.h"

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
    OB_INFO(@"setBadgeNumberDownloadedUnviewed = %li", (long)[ZZVideoDataProvider countTotalUnviewedVideos]);
    [self setBadgeCount:[ZZVideoDataProvider countTotalUnviewedVideos]];
}


#pragma mark -  Notification center and badge control

- (void)clearBadgeCount
{
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:1];
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
}

- (void)setBadgeNumberUnviewed
{
    OB_INFO(@"setBadgeNumberUnviewed = %li", (long) [ZZVideoDataProvider countTotalUnviewedVideos]);
    [self setBadgeCount:[ZZVideoDataProvider countTotalUnviewedVideos]];
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


- (void)queueDownloadWithFriendID:(NSString*)friendID videoIds:(NSSet*)videoIds
{
    for (NSString *videoId in videoIds)
    {
        [self.delegate freshVideoDetectedWithVideoID:videoId friendID:friendID];
    }
}

- (void)_pollAllFriends
{
    ANDispatchBlockToBackgroundQueue(^{
        [self _pollEverSentStatusForAllFriends];
        [self _pollAllIncomingVideos];
        [self _pollAllOutgoingVideoStatus];
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


- (void)_pollAllIncomingVideos
{
    [[ZZRemoteStoageTransportService loadAllIncomingVideoIds] subscribeNext:^(NSArray *models) {
        
        for (ZZKeyStoreIncomingVideoIdsDomainModel *model in models)
        {
            ZZFriendDomainModel* friendModel = [ZZFriendDataProvider friendWithMKeyValue:model.friendMkey];
            if (friendModel.idTbm)
            {
                if (friendModel.videos.count)
                {
                    OB_INFO(@"%@  vids = %@", [NSObject an_safeString:[friendModel fullName]], model.videoIds ? : @[]);
                    [self queueDownloadWithFriendID:friendModel.idTbm videoIds:model.videoIds];
                }
            }
        }
    }];
}


- (void)_pollAllOutgoingVideoStatus
{
    [[ZZRemoteStoageTransportService loadAllOutgoingVideoStatuses] subscribeNext:^(NSArray *models) {
        
        for (ZZKeyStoreOutgoingVideoStatusDomainModel *model in models)
        {
            ZZFriendDomainModel* friendModel = [ZZFriendDataProvider friendWithMKeyValue:model.friendMkey];
            if (friendModel)
            {
                if ([model status] == ZZVideoOutgoingStatusUnknown)
                {
                    OB_ERROR(@"pollVideoStatusWithFriend: got unknown outgoing video status. This should never happen");
                    return;
                }
                //TODO: remove this core data stuff
                TBMFriend* friendEntity = [ZZFriendDataProvider friendEntityWithItemID:friendModel.idTbm];
                [friendEntity setAndNotifyOutgoingVideoStatus:[model status] videoId:model.videoId];
            }
        }
    }];
}

@end
