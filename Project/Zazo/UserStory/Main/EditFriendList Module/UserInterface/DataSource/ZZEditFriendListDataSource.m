//
//  ZZEditFriendListDataSource.m
//  Zazo
//
//  Created by ANODA on 1/11/15.
//  Copyright (c) 2015 ANODA. All rights reserved.
//

#import "ZZEditFriendListDataSource.h"
#import "ANMemoryStorage.h"
#import "ZZEditFriendCellViewModel.h"

@interface ZZEditFriendListDataSource () <ZZEditFriendCellViewModelDelegate>

@end

@implementation ZZEditFriendListDataSource

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        self.storage = [ANMemoryStorage storage];
    }
    return self;
}

- (void)setupStorageWithModels:(NSArray *)list
{
    [list enumerateObjectsUsingBlock:^(ZZEditFriendCellViewModel *model, NSUInteger idx, BOOL *stop) {
        model.delegate = self;
    }];

    [self.storage batchUpdateWithBlock:^{
        [self _addSectionWithItems:list];
    }];
}

- (void)updateViewModel:(ZZEditFriendCellViewModel *)model
{
    [self.storage reloadItem:model];
}

#pragma mark - ZZEditFriendCellViewModelDelegate

- (void)switchValueChangedWithModel:(ZZEditFriendCellViewModel *)model
{
    [self.delegate changeContactStatusTypeForModel:model];
}

#pragma mark - Private

- (void)_addSectionWithItems:(NSArray *)items
{
    if (!ANIsEmpty(items))
    {
        [self.storage addItems:items toSection:0];

    }
}

- (void)updateModelWithFriend:(ZZFriendDomainModel *)model
{
    NSArray *items = [self.storage itemsInSection:0];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"item == %@", model];
    NSArray *result = [items filteredArrayUsingPredicate:predicate];

    if (!ANIsEmpty(result))
    {
        ZZEditFriendCellViewModel *updatedModel = [result firstObject];
        updatedModel.isUpdating = NO;
        updatedModel.item = model;
        [self updateViewModel:updatedModel];
    }
}

@end
