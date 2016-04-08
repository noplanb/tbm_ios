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
@import MagicalRecord;
#import "ZZFriendDataProvider.h"
#import "ZZVideoDomainModel.h"

@implementation ZZFriendDataHelper

+ (BOOL)isUniqueFirstName:(NSString*)firstName friendID:(NSString*)friendID
{
    NSSet <NSString *> *names = [ZZFriendDataProvider allUsernamesExceptFriendWithID:friendID];
    return ![names containsObject:firstName];
}

#pragma mark - Friend video helpers

+ (NSUInteger)unviewedVideoCountWithFriendID:(NSString *)friendID
{
    if (!friendID)
    {
        return 0;
    }
    
    NSNumber *count = ZZDispatchOnMainThreadAndReturn(^id{
        return @([TBMVideo MR_countOfEntitiesWithPredicate:[NSPredicate predicateWithFormat:@"friend.idTbm == %@ && status == %d", friendID, ZZVideoIncomingStatusDownloaded]]);
    });
    
    return count.unsignedIntegerValue;
}

+ (NSArray*)everSentMkeys
{
    NSMutableArray *result = [NSMutableArray array];
    for (ZZFriendDomainModel *friendEntity in [ZZFriendDataProvider allEverSentFriends])
    {
        [result addObject:friendEntity.mKey];
    }
    return result;
}

+ (NSDate *)lastVideoSentTimeFromFriend:(ZZFriendDomainModel *)friendModel
{
    NSString *videoID = friendModel.videos.lastObject.videoID;
    NSTimeInterval timestamp = videoID.doubleValue/1000;
    return [NSDate dateWithTimeIntervalSince1970:timestamp];
}

@end
