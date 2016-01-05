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

#pragma mark - Fetches

+ (NSArray*)loadAllFriends;
+ (ZZFriendDomainModel*)friendWithItemID:(NSString*)itemID;
+ (ZZFriendDomainModel*)friendWithMKeyValue:(NSString*)mKeyValue;
+ (ZZFriendDomainModel*)lastActionFriendWihoutGrid;
+ (ZZFriendDomainModel*)friendModelWithMobileNumber:(NSString*)mobileNumber;

+ (NSArray*)friendsOnGrid;

#pragma mark - Count

+ (NSInteger)friendsCount;


@end