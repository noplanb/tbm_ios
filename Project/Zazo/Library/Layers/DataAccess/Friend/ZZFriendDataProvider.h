//
//  ZZFriendDataProvider.h
//  Zazo
//
//  Created by ANODA on 8/10/15.
//  Copyright (c) 2015 ANODA. All rights reserved.
//

@class ZZFriendDomainModel;

@interface ZZFriendDataProvider : NSObject

#pragma mark - Fetches

+ (NSArray*)loadAllFriends;
+ (ZZFriendDomainModel*)friendWithItemID:(NSString*)itemID;
+ (ZZFriendDomainModel*)friendWithMKeyValue:(NSString*)mKeyValue;
+ (ZZFriendDomainModel*)lastActionFriendWihoutGrid;

+ (NSArray*)friendsOnGrid;

#pragma mark - Count

+ (NSInteger)friendsCount;


#pragma mark - Entities

+ (BOOL)isFriendExistsWithItemID:(NSString*)itemID;
+ (BOOL)isFriendExistsWithMKey:(NSString*)mKey;

#pragma mark - CRUD

+ (void)deleteAllFriendsModels;

@end
