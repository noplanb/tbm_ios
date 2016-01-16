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
#import "ZZContentDataAccessor.h"
#import "ZZVideoStatuses.h"
#import "ZZFriendDataProvider+Entities.h"

@implementation ZZFriendDataHelper

+ (BOOL)isUniqueFirstName:(NSString*)firstName friendID:(NSString*)friendID
{
    NSArray* friends = [ZZFriendDataProvider loadAllFriends];
    ZZFriendDomainModel* aFriendModel = [ZZFriendDataProvider friendWithItemID: friendID];
    
    for (ZZFriendDomainModel *friendModel in friends)
    {
        if (![aFriendModel.idTbm isEqual:friendModel.idTbm] && [firstName isEqualToString:friendModel.firstName])
            return NO;
    }
    return YES;
}


#pragma mark - Friend video helpers

+ (BOOL)isFriend:(ZZFriendDomainModel*)friendModel hasIncomingVideoWithId:(NSString*)videoID
{
    BOOL hasVideo = NO;
    NSArray* videos = [friendModel.videos copy];
    for (ZZVideoDomainModel* videoModel in videos)
    {
        if ([videoModel.videoID isEqualToString:videoID])
        {
            hasVideo = YES;
        }
    }
    
    return hasVideo;
}

+ (NSInteger)unviewedVideoCountWithFriend:(TBMFriend*)friendEntity
{
    NSInteger i = 0;

    for (TBMVideo *videoEntity in [friendEntity videos])
    {
        if (videoEntity.statusValue == ZZVideoIncomingStatusDownloaded)
        {
            i++;
        }
    }
    return i;
}


+ (NSArray *)_allEverSentFriends
{
    NSPredicate *everSent = [NSPredicate predicateWithFormat:@"%K = %@", TBMFriendAttributes.everSent, @(YES)];
    NSPredicate *creator = [NSPredicate predicateWithFormat:@"%K = %@", TBMFriendAttributes.isFriendshipCreator, @(NO)];
    NSPredicate *filter = [NSCompoundPredicate andPredicateWithSubpredicates:@[everSent, creator]];
    return [TBMFriend MR_findAllWithPredicate:filter inContext:[ZZContentDataAccessor mainThreadContext]];
}

+ (NSArray*)everSentMkeys
{
    NSMutableArray *result = [NSMutableArray array];
    for (TBMFriend *friendEntity in [self _allEverSentFriends])
    {
        [result addObject:friendEntity.mkey];
    }
    return result;
}

@end
