//
//  ZZEditFriendListDataSource.h
//  Zazo
//
//  Created by ANODA on 1/11/15.
//  Copyright (c) 2015 ANODA. All rights reserved.
//

@class ANMemoryStorage;
@class ZZEditFriendCellViewModel;
@class ZZFriendDomainModel;

@protocol ZZEditFriendListDataSourceDelegate <NSObject>

- (void)changeContactStatusTypeForModel:(ZZEditFriendCellViewModel *)model;

@end

@interface ZZEditFriendListDataSource : NSObject

@property (nonatomic, strong) ANMemoryStorage *storage;
@property (nonatomic, weak) id <ZZEditFriendListDataSourceDelegate> delegate;

- (void)setupStorageWithModels:(NSArray *)list;

- (void)updateViewModel:(ZZEditFriendCellViewModel *)model;

- (void)updateModelWithFriend:(ZZFriendDomainModel *)model;

@end
