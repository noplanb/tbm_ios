//
//  ZZFriendDataHelper.m
//  Zazo
//
//  Created by ANODA on 11/3/15.
//  Copyright © 2015 No Plan B. All rights reserved.
//

#import "ZZFriendDataHelper.h"
#import "TBMFriend.h"
#import "TBMVideo.h"
#import "MagicalRecord.h"
#import "ZZVideoDataUpdater.h"
#import "ZZContentDataAcessor.h"
#import "ZZVideoStatuses.h"
#import "ZZFriendDataProvider+Entities.h"

@implementation ZZFriendDataHelper

+ (BOOL)isUniqueFirstName:(NSString*)firstName friendID:(NSString*)friendID
{
    NSArray* friends = [TBMFriend MR_findAll];
    TBMFriend* friendEnitity = [ZZFriendDataProvider friendEntityWithItemID:friendID];
    for (TBMFriend *f in friends)
    {
        if (![friendEnitity isEqual:f] && [firstName isEqualToString:f.firstName])
            return NO;
    }
    return YES;
}


#pragma mark - Friend video helpers

+ (BOOL)isFriend:(TBMFriend*)friend hasIncomingVideoWithId:(NSString*)videoId
{
    BOOL hasVideo = NO;
    NSArray* videos = [friend.videos.allObjects copy];
    for (TBMVideo* video in videos)
    {
        if ([video.videoId isEqualToString:videoId])
        {
            hasVideo = YES;
        }
    }
    
    return hasVideo;
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
