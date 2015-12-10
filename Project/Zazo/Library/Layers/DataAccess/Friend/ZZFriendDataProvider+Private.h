//
//  ZZFriendDataProvider+Private.h
//  Zazo
//
//  Created by Vitaly Cherevaty on 12/9/15.
//  Copyright © 2015 No Plan B. All rights reserved.
//

@class TBMFriend;
@class TBMVideo;

@interface ZZFriendDataProvider(Private)

#pragma mark - Entities

+ (TBMFriend*)friendEntityWithItemID:(NSString*)itemID;
+ (TBMFriend*)friendEnityWithMkey:(NSString*)mKey;

#pragma mark - Mapping

+ (ZZFriendDomainModel*)modelFromEntity:(TBMFriend*)entity;
+ (TBMFriend*)entityFromModel:(ZZFriendDomainModel*)model;

@end
