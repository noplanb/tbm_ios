//
//  ZZFriendDataHelper+Private.h
//  Zazo
//
//  Created by Vitaly Cherevaty on 12/9/15.
//  Copyright © 2015 No Plan B. All rights reserved.
//

#import "ZZFriendDataHelper.h"

@class TBMFriend;
@class TBMVideo;

@interface ZZFriendDataHelper (Private)

#pragma mark - Friend video helpers

+ (BOOL)isFriend:(TBMFriend*)friendModel hasIncomingVideoWithId:(NSString*)videoId;
+ (NSInteger)unviewedVideoCountWithFriend:(TBMFriend*)friendModel;
+ (BOOL)hasOutgoingVideoWithFriend:(TBMFriend*)friendModel;

@end
