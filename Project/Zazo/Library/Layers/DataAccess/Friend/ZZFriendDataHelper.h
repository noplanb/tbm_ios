//
//  ZZFriendDataHelper.h
//  Zazo
//
//  Created by ANODA on 11/3/15.
//  Copyright © 2015 No Plan B. All rights reserved.
//

@class TBMFriend;
@class TBMVideo;

@interface ZZFriendDataHelper : NSObject

+ (BOOL)isUniqueFirstName:(NSString*)firstName friendID:(NSString*)friendID;


#pragma mark - Friend video helpers

+ (BOOL)isFriendWithId:(NSString*)friendId hasIncomingVideoWithId:(NSString*)videoId;
+ (NSInteger)unviewedVideoCountWithFriendId:(NSString*)friendId;
+ (BOOL)hasOutgoingVideoWithFriendId:(NSString*)friendId;

+ (NSArray*)everSentMkeys;

@end
