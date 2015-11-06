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

+ (BOOL)isFriend:(TBMFriend*)friend hasIncomingVideoWithId:(NSString*)videoId;
+ (NSInteger)unviewedVideoCountWithFriend:(TBMFriend*)friend;
+ (BOOL)hasOutgoingVideoWithFriend:(TBMFriend*)friend;
+ (NSArray*)everSentMkeys;

@end
