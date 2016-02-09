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
#import "ZZFriendDataProvider.h"

@implementation ZZFriendDataHelper

+ (BOOL)isUniqueFirstName:(NSString*)firstName friendID:(NSString*)friendID
{
    NSArray* friends = [ZZFriendDataProvider allFriendsModels];
    ZZFriendDomainModel* aFriendModel = [ZZFriendDataProvider friendWithItemID: friendID];
    
    for (ZZFriendDomainModel *friendModel in friends)
    {
        if (![aFriendModel.idTbm isEqual:friendModel.idTbm] && [firstName isEqualToString:friendModel.firstName])
            return NO;
    }
    return YES;
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

@end
