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
#import "ZZRemoteStorageTransportService.h"
#import "ZZFriendDataProvider.h"
#import "ZZKeyStoreIncomingVideoIDsDomainModel.h"
#import "ZZFriendDomainModel.h"
#import "ZZKeyStoreOutgoingVideoStatusDomainModel.h"
#import "ZZVideoDataProvider.h"
#import "ZZVideoStatusHandler.h"
#import "ZZRootStateObserver.h"
#import "ZZFriendDataUpdater.h"


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
    [self _setBadgeCount:[ZZVideoDataProvider countTotalUnviewedVideos]];
}


#pragma mark -  Notification center and badge control

- (void)_clearBadgeCount
{
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:1];
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
}

- (void)_setBadgeCount:(NSInteger)count
{
    if (count == 0)
    {
        [self _clearBadgeCount];
    }
    else
    {
        [[UIApplication sharedApplication] setApplicationIconBadgeNumber:count];
    }
}


- (void)_queueDownloadWithFriendID:(NSString *)friendID videoIDs:(NSSet*)videoIDs
{
    for (NSString *videoID in videoIDs)
    {
        [self.delegate freshVideoDetectedWithVideoID:videoID friendID:friendID];
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
    
    [[ZZRemoteStorageTransportService loadRemoteEverSentFriendsIDsForUserMkey:me.mkey] subscribeNext:^(id x) {
        
        ANDispatchBlockToBackgroundQueue(^{
            
            [ZZFriendDataUpdater updateEverSentFriendsWithMkeys:x];
            [[ZZRootStateObserver sharedInstance] notifyWithEvent:ZZRootStateObserverEventDonwloadedMkeys
                                               notificationObject:x];
        });
    }];
}


- (void)_pollAllIncomingVideos
{
    [[ZZRemoteStorageTransportService loadAllIncomingVideoIDs] subscribeNext:^(NSArray *models) {
        for (ZZKeyStoreIncomingVideoIDsDomainModel *model in models)
        {
            ZZFriendDomainModel* friendModel = [ZZFriendDataProvider friendWithMKeyValue:model.friendMkey];
            if (friendModel.idTbm)
            {
//                if (friendModel.videos.count)
//                {
                    ZZLogInfo(@"%@  vids = %@", [NSObject an_safeString:[friendModel fullName]], model.videoIDs ? : @[]);
                [self _queueDownloadWithFriendID:friendModel.idTbm videoIDs:model.videoIDs];
//                }
            }
        }
    }];
}


- (void)_pollAllOutgoingVideoStatus
{
    [[ZZRemoteStorageTransportService loadAllOutgoingVideoStatuses] subscribeNext:^(NSArray *models) {
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
                    [[ZZVideoStatusHandler sharedInstance] notifyOutgoingVideoWithStatus:(ZZVideoOutgoingStatus) [model status]
                                                                            withFriendID:friendModel.idTbm
                                                                             withVideoID:model.videoId];
                }
            }
        }
    }];
}

@end
