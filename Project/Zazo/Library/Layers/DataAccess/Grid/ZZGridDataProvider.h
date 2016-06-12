//
//  ZZGridDataProvider.h
//  Zazo
//
//  Created by ANODA on 8/10/15.
//  Copyright (c) 2015 ANODA. All rights reserved.
//

@class ZZGridDomainModel;
@class ZZFriendDomainModel;
@class ZZContactDomainModel;

@interface ZZGridDataProvider : NSObject

+ (NSArray *)loadOrCreateGridModelsWithCount:(NSInteger)gridModelsCount;

#pragma mark - Fetches

+ (NSArray <ZZGridDomainModel *> *)loadAllGridsSortByIndex:(BOOL)shouldSortByIndex;

+ (ZZGridDomainModel *)modelWithRelatedUserID:(NSString *)userID;

+ (BOOL)isRelatedUserOnGridWithID:(NSString *)userID;

+ (ZZGridDomainModel *)loadFirstEmptyGridElement;

+ (ZZGridDomainModel *)modelWithEarlierLastActionFriend;

+ (ZZGridDomainModel *)modelWithContact:(ZZContactDomainModel *)contactModel;

@end
