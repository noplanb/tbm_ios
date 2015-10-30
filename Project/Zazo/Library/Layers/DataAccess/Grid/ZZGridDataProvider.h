//
//  ZZGridDataProvider.h
//  Zazo
//
//  Created by ANODA on 8/10/15.
//  Copyright (c) 2015 ANODA. All rights reserved.
//

@class ZZGridDomainModel;
@class ZZFriendDomainModel;
@class TBMGridElement;
@class ZZContactDomainModel;
@class TBMFriend;

@interface ZZGridDataProvider : NSObject

+ (NSArray*)loadOrCreateGridModelsWithCount:(NSInteger)gridModelsCount;

#pragma mark - Fetches

+ (NSArray*)loadAllGridsSortByIndex:(BOOL)shouldSortByIndex;
//+ (ZZGridDomainModel*)modelWithIndex:(NSInteger)index;

+ (ZZGridDomainModel*)modelWithRelatedUserID:(NSString*)userID;
+ (BOOL)isRelatedUserOnGridWithID:(NSString*)userID;

+ (ZZGridDomainModel*)loadFirstEmptyGridElement;
+ (ZZGridDomainModel*)modelWithEarlierLastActionFriend;
+ (ZZGridDomainModel*)modelWithContact:(ZZContactDomainModel*)contactModel;


#pragma mark - Mapping

+ (ZZGridDomainModel*)modelFromEntity:(TBMGridElement*)entity;
+ (TBMGridElement*)entityWithItemID:(NSString*)itemID;

+ (TBMGridElement*)findWithIntIndex:(NSInteger)i;
+ (TBMGridElement*)findWithFriend:(TBMFriend *)item;


//#pragma mark - Entities
//
//+ (BOOL)friendIsOnGrid:(TBMFriend *)item;
//+ (BOOL)hasSentVideos:(NSUInteger)index;

@end
