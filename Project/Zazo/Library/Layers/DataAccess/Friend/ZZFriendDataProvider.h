//
//  ZZFriendDataProvider.h
//  Zazo
//
//  Created by ANODA on 8/10/15.
//  Copyright (c) 2015 ANODA. All rights reserved.
//

#import "ZZFriendDomainModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface ZZFriendDataProvider : NSObject

#pragma mark - Model fetching

+ (NSArray *)allFriendsModels;

+ (NSArray *)allVisibleFriendModels;

+ (NSArray *)allEverSentFriends;

+ (NSArray *)friendsOnGrid;

+ (nullable ZZFriendDomainModel *)friendWithItemID:(NSString *)itemID;

+ (nullable ZZFriendDomainModel *)friendWithMKeyValue:(NSString *)mKeyValue;

+ (nullable ZZFriendDomainModel *)friendWithMobileNumber:(NSString *)mobileNumber;

+ (nullable UIImage *)avatarOfFriendWithID:(nonnull NSString *)friendID;

#pragma mark - Other

+ (NSInteger)friendsCount;

+ (NSSet <NSString *> *)allUsernamesExceptFriendWithID:(NSString *)friendID;

+ (BOOL)isFriendExistsWithItemID:(NSString *)itemID;

+ (nullable ZZFriendDomainModel *)lastActionFriendWithoutGrid;

@end

NS_ASSUME_NONNULL_END
