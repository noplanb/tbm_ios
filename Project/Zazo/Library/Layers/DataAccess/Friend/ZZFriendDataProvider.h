//
//  ZZFriendDataProvider.h
//  Zazo
//
//  Created by ANODA on 8/10/15.
//  Copyright (c) 2015 ANODA. All rights reserved.
//

@class ZZFriendDomainModel;

@interface ZZFriendDataProvider : NSObject

+ (BOOL)isFriendExistsWithItemID:(NSString*)itemID;
+ (BOOL)isFriendExistsWithMKey:(NSString*)mKey;

#pragma mark - Fetches

+ (NSArray*)loadAllFriends;
//+ (ZZFriendDomainModel*)friendWithOutgoingVideoItemID:(NSString*)videoItemID;
+ (ZZFriendDomainModel*)friendWithItemID:(NSString*)itemID;
+ (ZZFriendDomainModel*)friendWithMKeyValue:(NSString*)mKeyValue;
+ (ZZFriendDomainModel*)lastActionFriendWihoutGrid;
+ (ZZFriendDomainModel*)friendModelWithMobileNumber:(NSString*)mobileNumber;

+ (NSArray*)friendsOnGrid;

#pragma mark - Count

+ (NSInteger)friendsCount;

#pragma mark - CRUD

//+ (void)upsertFriendWithModel:(ZZFriendDomainModel*)model;
//+ (void)deleteFriendWithID:(NSString*)itemID;

+ (void)deleteAllFriendsModels;


@end