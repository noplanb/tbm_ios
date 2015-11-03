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

@implementation ZZFriendDataHelper

+ (BOOL)isUniqueFirstName:(NSString*)firstName
{
    NSArray* friends = [TBMFriend MR_findAll];
    for (TBMFriend *f in friends)
    {
        if (![self isEqual:f] && [firstName isEqualToString:f.firstName])
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

+ (NSInteger)unviewedVideoCountWithFriend:(TBMFriend*)friend
{
    NSInteger i = 0;
    for (TBMVideo *v in [friend videos])
    {
        if (v.statusValue == ZZVideoIncomingStatusDownloaded) //||
            // v.statusValue == ZZVideoIncomingStatusDownloading)
        {
            i++;
        }
    }
    return i;
}

+ (BOOL)hasOutgoingVideoWithFriend:(TBMFriend*)friend
{
    return !ANIsEmpty(friend.outgoingVideoId);
}

+ (NSArray *)_allEverSentFriends
{
    NSPredicate *everSent = [NSPredicate predicateWithFormat:@"%K = %@", TBMFriendAttributes.everSent, @(YES)];
    NSPredicate *creator = [NSPredicate predicateWithFormat:@"%K = %@", TBMFriendAttributes.isFriendshipCreator, @(NO)];
    NSPredicate *filter = [NSCompoundPredicate andPredicateWithSubpredicates:@[everSent, creator]];
    return [TBMFriend MR_findAllWithPredicate:filter inContext:[ZZContentDataAcessor contextForCurrentThread]];
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
