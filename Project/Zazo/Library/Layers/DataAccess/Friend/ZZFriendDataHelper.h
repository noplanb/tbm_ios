//
//  ZZFriendDataHelper.h
//  Zazo
//
//  Created by ANODA on 11/3/15.
//  Copyright © 2015 No Plan B. All rights reserved.
//

@class ZZFriendDomainModel;
@class TBMVideo, TBMFriend;

@interface ZZFriendDataHelper : NSObject

+ (BOOL)isUniqueFirstName:(NSString*)firstName friendID:(NSString*)friendID;


#pragma mark - Friend video helpers

+ (BOOL)isFriend:(ZZFriendDomainModel*)friendModel hasIncomingVideoWithId:(NSString*)videoId;
+ (NSInteger)unviewedVideoCountWithFriend:(TBMFriend*)friendModel;
+ (BOOL)hasOutgoingVideoWithFriend:(TBMFriend*)friendModel;
+ (NSInteger)unviewedVideoCountWithFriendModel:(ZZFriendDomainModel*)friendModel;
+ (BOOL)hasOutgoingVideoWithFriendModel:(ZZFriendDomainModel*)friendModel;
+ (NSArray*)everSentMkeys;

@end
