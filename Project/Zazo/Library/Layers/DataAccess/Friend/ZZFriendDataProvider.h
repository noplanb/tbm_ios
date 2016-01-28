//
//  ZZFriendDataProvider.h
//  Zazo
//
//  Created by ANODA on 8/10/15.
//  Copyright (c) 2015 ANODA. All rights reserved.
//

@class ZZFriendDomainModel;

@interface ZZFriendDataProvider : NSObject

#pragma mark - Model fetching

+ (NSArray*)allFriendsModels;
+ (NSArray*)allVisibleFriendModels;
+ (NSArray*)allEverSentFriends;
+ (NSArray*)friendsOnGrid;

+ (ZZFriendDomainModel*)friendWithItemID:(NSString*)itemID;
+ (ZZFriendDomainModel*)friendWithMKeyValue:(NSString*)mKeyValue;
+ (ZZFriendDomainModel*)friendWithMobileNumber:(NSString*)mobileNumber;

#pragma mark - Other

+ (NSInteger)friendsCount;
+ (BOOL)isFriendExistsWithItemID:(NSString*)itemID;
+ (ZZFriendDomainModel*)lastActionFriendWithoutGrid;

@end