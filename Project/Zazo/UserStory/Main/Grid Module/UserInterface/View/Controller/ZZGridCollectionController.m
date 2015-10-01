//
//  ZZGridCollectionController.m
//  Zazo
//
//  Created by ANODA on 12/08/15.
//  Copyright (c) 2015 ANODA. All rights reserved.
//

#import "ZZGridCollectionController.h"
#import "ZZGridCell.h"
#import "ZZGridCenterCell.h"
#import "ZZGridDomainModel.h"
#import "ZZGridCenterCellViewModel.h"
#import "ANRuntimeHelper.h"
#import "ANMemoryStorage.h"
#import "ZZGridCellViewModel.h"
#import "ZZFriendDomainModel.h"
#import "ZZGridDataSource.h"

@interface ZZGridCollectionController () <ANStorageUpdatingInterface>

@property (nonatomic, strong) ZZGridDataSource* dataSource;

@end

@implementation ZZGridCollectionController

- (void)reload
{
    NSArray* items = [self.delegate items];
    [items enumerateObjectsUsingBlock:^(id <ANModelTransfer> _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        ANSectionModel* section = [self.dataSource.storage sectionAtIndex:0];
        if (section)
        {
            NSArray* items = [section objects];
            if (items.count > idx)
            {
                id model = items[idx];
                [obj updateWithModel:model];
            }
        }
    }];
}

- (void)reloadItemAtIndex:(NSInteger)index withModel:(id)model
{
    id<ANModelTransfer> item = (id<ANModelTransfer>)[self.delegate items];
    [item updateWithModel:model];
}

- (void)updateDataSource:(ZZGridDataSource*)dataSource
{
    self.dataSource = dataSource;
    self.dataSource.storage.delegate = self;
}

- (void)storageNeedsReload
{
    [self reload];
}

- (void)storageDidPerformUpdate:(ANStorageUpdate *)update
{
    [self reload]; // TODO: temp
}

- (void)showContainFriendAnimaionWithFriend:(ZZFriendDomainModel*)friendModel
{
//    [[self.collectionView visibleCells] enumerateObjectsUsingBlock:^(UICollectionViewCell* cell, NSUInteger idx, BOOL *stop) {
//        
//        if ([cell isKindOfClass:[ZZGridCell class]])
//        {
//            ZZGridCell* gridCell = (ZZGridCell *)cell;
//            ZZGridCellViewModel* cellModel = [gridCell model];
//            if ([cellModel.item.relatedUser isEqual:friendModel])
//            {
//                [gridCell showContainFriendAnimation];
//            }
//        }
//    }];
}

@end
