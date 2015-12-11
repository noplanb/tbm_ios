//
//  ZZApplicationDataUpdaterService.m
//  Zazo
//
//  Created by Oksana Kovalchuk on 10/20/15.
//  Copyright © 2015 No Plan B. All rights reserved.
//

#import "ZZApplicationDataUpdaterService.h"
#import "ZZFriendsTransportService.h"
#import "ZZUserDataProvider.h"
#import "ZZRemoteStoageTransportService.h"
#import "ZZFriendDataProvider.h"
#import "ZZKeyStoreIncomingVideoIdsDomainModel.h"
#import "ZZFriendDomainModel.h"
#import "ZZKeyStoreOutgoingVideoStatusDomainModel.h"
#import "ZZVideoDataProvider.h"
#import "ZZVideoStatusHandler.h"
#import "ZZRootStateObserver.h"
#import "ZZFriendDataUpdater.h"
#import "ZZHelperFunctions.h"


@implementation ZZApplicationDataUpdaterService

- (void)updateAllData
{
    ZZLogInfo(@"getAndPollAllFriends");
    ANDispatchBlockToBackgroundQueue(^{
        [[ZZFriendsTransportService loadFriendList] subscribeNext:^(NSArray* friends) {
            ZZLogInfo(@"gotFriends");
            [self _pollAllFriends];
        } error:^(NSError *error) {
            [self _pollAllFriends];
        }];
    });
}

- (void)updateAllDataWithoutRequest
{
    [self _pollAllFriends];
}

- (void)updateApplicationBadge
{
    ZZLogInfo(@"setBadgeNumberDownloadedUnviewed = %li", (long)[ZZVideoDataProvider countTotalUnviewedVideos]);
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
    ZZLogInfo(@"setBadgeNumberUnviewed = %li", (long) [ZZVideoDataProvider countTotalUnviewedVideos]);
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
    ZZUserDomainModel* me = ZZDispatchBlockToMainQueueAndReturnValue(^id{
        return [ZZUserDataProvider authenticatedUser];
    });
    
    [[ZZRemoteStoageTransportService loadRemoteEverSentFriendsIDsForUserMkey:me.mkey] subscribeNext:^(id x) {
  
            [ZZFriendDataUpdater updateEverSentFriendsWithMkeys:x];
            [[ZZRootStateObserver sharedInstance] notifyWithEvent:ZZRootStateObserverEventDonwloadedMkeys
                                               notificationObject:x];
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
//                if (friendModel.videos.count)
//                {
                    ZZLogInfo(@"%@  vids = %@", [NSObject an_safeString:[friendModel fullName]], model.videoIds ? : @[]);
                    [self queueDownloadWithFriendID:friendModel.idTbm videoIds:model.videoIds];
//                }
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
                    ZZLogError(@"pollVideoStatusWithFriend: got unknown outgoing video status. This should never happen");
                    return;
                }

                if ([model status] != ZZVideoOutgoingStatusNone)
                {
                    ZZFriendDomainModel* friendModelAnother = [ZZFriendDataProvider friendWithItemID:friendModel.idTbm];
                    [[ZZVideoStatusHandler sharedInstance] notifyOutgoingVideoWithStatus:(ZZVideoOutgoingStatus)[model status]
                                                                            withFriendID:friendModelAnother.idTbm
                                                                             withVideoId:model.videoId];
                }
            }
        }
    }];
}

@end
