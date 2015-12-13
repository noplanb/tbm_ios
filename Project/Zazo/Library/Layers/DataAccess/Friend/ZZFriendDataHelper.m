//
//  ZZFriendDataHelper.m
//  Zazo
//
//  Created by ANODA on 11/3/15.
//  Copyright © 2015 No Plan B. All rights reserved.
//

#import "ZZFriendDataHelper.h"
#import "ZZFriendDomainModel.h"
#import "TBMVideo.h"
#import "TBMFriend.h"
#import "ZZVideoDomainModel.h"
#import "MagicalRecord.h"
#import "ZZVideoDataUpdater.h"
#import "ZZContentDataAcessor.h"
#import "ZZVideoStatuses.h"
#import "ZZFriendDataProvider+Entities.h"

@implementation ZZFriendDataHelper

+ (BOOL)isUniqueFirstName:(NSString*)firstName friendID:(NSString*)friendID
{
    NSArray* friends = [ZZFriendDataProvider loadAllFriends];
    ZZFriendDomainModel* friend = [ZZFriendDataProvider friendWithItemID: friendID];
    for (ZZFriendDomainModel *f in friends)
    {
        if (![friend isEqual:f] && [firstName isEqualToString:f.firstName])
            return NO;
    }
    return YES;
}


#pragma mark - Friend video helpers

+ (BOOL)isFriend:(ZZFriendDomainModel*)friend hasIncomingVideoWithId:(NSString*)videoId
{
    BOOL hasVideo = NO;
    NSArray* videos = [friend.videos copy];
    for (ZZVideoDomainModel* video in videos)
    {
        if ([video.videoID isEqualToString:videoId])
        {
            hasVideo = YES;
        }
    }
    
    return hasVideo;
}

+ (NSInteger)unviewedVideoCountWithFriendModel:(ZZFriendDomainModel*)friendModel
{
    TBMFriend *entity = [ZZFriendDataProvider entityFromModel:friendModel];
    NSNumber *count = ZZDispatchOnMainThreadAndReturn(^id{
        return @([self unviewedVideoCountWithFriend:entity]);
    });
    
    return count.integerValue;
}

+ (BOOL)hasOutgoingVideoWithFriendModel:(ZZFriendDomainModel*)friendModel
{
    return friendModel.hasOutgoingVideo;
}

+ (NSInteger)unviewedVideoCountWithFriend:(TBMFriend*)friendModel
{
    NSInteger i = 0;
    for (TBMVideo *v in [friendModel videos])
    {
        if (v.statusValue == ZZVideoIncomingStatusDownloaded)
        {
            i++;
        }
    }
    return i;
}

+ (BOOL)hasOutgoingVideoWithFriend:(TBMFriend*)friendModel
{
    return !ANIsEmpty(friendModel.outgoingVideoId);
}

+ (NSArray *)_allEverSentFriends
{
    NSPredicate *everSent = [NSPredicate predicateWithFormat:@"%K = %@", TBMFriendAttributes.everSent, @(YES)];
    NSPredicate *creator = [NSPredicate predicateWithFormat:@"%K = %@", TBMFriendAttributes.isFriendshipCreator, @(NO)];
    NSPredicate *filter = [NSCompoundPredicate andPredicateWithSubpredicates:@[everSent, creator]];
    return [TBMFriend MR_findAllWithPredicate:filter inContext:[ZZContentDataAcessor mainThreadContext]];
}

+ (NSArray*)everSentMkeys
{
    NSMutableArray *result = [NSMutableArray array];
    for (TBMFriend *friend in [self _allEverSentFriends])
    {
        [result addObject:friend.mkey];
    }
    return result;
}

@end
