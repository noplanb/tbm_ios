//
//  ZZFriendDataUpdater.h
//  Zazo
//
//  Created by Oksana Kovalchuk on 9/30/15.
//  Copyright © 2015 No Plan B. All rights reserved.
//

#import "ZZEditFriendEnumsAdditions.h"
#import "ZZFriendDomainModel.h"

@interface ZZFriendDataUpdater : NSObject

#pragma mark Updation

+ (void)updateLastTimeActionFriendWithID:(NSString*)itemID;
+ (void)updateFriendWithID:(NSString *)friendID setLastIncomingVideoStatus:(ZZVideoIncomingStatus)status;
+ (void)updateFriendWithID:(NSString *)friendID setOutgoingVideoStatus:(ZZVideoOutgoingStatus)status;
+ (void)updateFriendWithID:(NSString *)friendID setUploadRetryCount:(NSUInteger)count;
+ (void)updateFriendWithID:(NSString *)friendID setLastVideoStatusEventType:(ZZVideoStatusEventType)eventType;
+ (void)updateFriendWithID:(NSString *)friendID setOutgoingVideoItemID:(NSString *)videoID;
+ (void)updateFriendWithID:(NSString *)friendID setConnectionStatus:(ZZFriendshipStatusType)status;

#pragma mark Batch updation

+ (void)updateEverSentFriendsWithMkeys:(NSArray*)mKeys;

#pragma mark Upsert

+ (ZZFriendDomainModel*)upsertFriend:(ZZFriendDomainModel*)model;

#pragma mark Deletion

+ (void)deleteAllFriends;

#pragma mark Migration

+ (void)fillEntitiesAfterMigration;


@end
