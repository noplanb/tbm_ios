//
//  ZZFriendDataProvider+Entities.h
//  Zazo
//
//  Created by Rinat on 10.12.15.
//  Copyright © 2015 No Plan B. All rights reserved.
//

#import "ZZFriendDataProvider.h"

@interface ZZFriendDataProvider (Entities)

#pragma mark - Entities

+ (TBMFriend*)friendEntityWithItemID:(NSString*)itemID;
+ (TBMFriend*)friendEnityWithMkey:(NSString*)mKey;

#pragma mark - Mapping

+ (ZZFriendDomainModel*)modelFromEntity:(TBMFriend*)entity;
+ (TBMFriend*)entityFromModel:(ZZFriendDomainModel*)model;

@end